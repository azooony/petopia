param()
$ErrorActionPreference = 'SilentlyContinue'
$BASE         = 'http://localhost:3000'
$script:PASS  = 0
$script:FAIL  = 0

function ok($lbl)        { Write-Host "  [PASS] $lbl" -ForegroundColor Green;  $script:PASS++ }
function fail($lbl,$det) { Write-Host "  [FAIL] $lbl`n        $det" -ForegroundColor Red; $script:FAIL++ }
function section($t)     { Write-Host "`n=== $t ===" -ForegroundColor Cyan }

function Req($method, $path, $body, $token) {
    $h = @{ 'Content-Type' = 'application/json' }
    if ($token) { $h['Authorization'] = "Bearer $token" }
    $params = @{ Uri = "$BASE$path"; Method = $method; Headers = $h; ErrorAction = 'Stop' }
    if ($body) { $params['Body'] = ($body | ConvertTo-Json -Depth 10) }
    try   { return Invoke-RestMethod @params }
    catch {
        $resp = $_.Exception.Response
        if ($resp) {
            $stream = $resp.GetResponseStream()
            $reader = [System.IO.StreamReader]::new($stream)
            $raw    = $reader.ReadToEnd()
            try { return $raw | ConvertFrom-Json } catch { return @{ success = $false; raw = $raw } }
        }
        return @{ success = $false; raw = $_.Exception.Message }
    }
}

# ── 0. Health ─────────────────────────────────────────────────────────────────
section '0 — Health check'
$h = Req GET '/' $null $null
if ($h.data.status -eq 'ok') { ok 'Server is up' } else { fail 'Health' ($h | ConvertTo-Json) }

# ── 1. Register ───────────────────────────────────────────────────────────────
section '1 — Register a test owner'
$ts    = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$email = "notif_test_$ts@petopia.test"
$pw    = 'Test1234!'

$reg = Req POST '/auth/register-owner' @{
    email    = $email
    password = $pw
    fullName = "Notif Tester $ts"
    age      = 25
    gender   = 'MALE'
    phone    = '01000000000'
    address  = 'Cairo'
} $null

if ($reg.success) { ok "Owner registered  ($email)" }
else { fail 'Register' ($reg | ConvertTo-Json -Depth 5) }

# ── 2. Login ──────────────────────────────────────────────────────────────────
section '2 — Login'
$loginResp = Req POST '/auth/login' @{ email = $email; password = $pw } $null
$tok = $loginResp.data.token
if ($tok) { ok 'Login OK — JWT received' }
else      { fail 'Login' ($loginResp | ConvertTo-Json -Depth 5) }

# ── 3. Empty list ─────────────────────────────────────────────────────────────
section '3 — GET /notifications (should be empty)'
$r = Req GET '/notifications' $null $tok
if ($r.success -and ($r.data -is [array] -or $r.data -eq $null)) {
    ok "Endpoint returns array  (count=$( if ($r.data) { $r.data.Count } else { 0 } ))"
} else { fail 'GET /notifications' ($r | ConvertTo-Json) }

# ── 4. Seed notifications ─────────────────────────────────────────────────────
section '4 — Seed 2 notifications directly into DB'
$seedLines = node 'test-seed-notif.cjs' $email 2>&1
# dotenv may emit a progress line to stdout; grab the line that starts with '{'
$jsonLine  = ($seedLines | ForEach-Object { "$_" } | Where-Object { $_ -match '^\{' } | Select-Object -Last 1)
try {
    $seeded  = $jsonLine | ConvertFrom-Json
    $notifId = $seeded.id1
    if ($notifId) { ok "Seeded  id1=$notifId  id2=$($seeded.id2)" }
    else          { fail 'Seed' ($seedLines -join ' | ') }
} catch { fail 'Seed parse' ($seedLines -join ' | ') }

# ── 5. List shows seeded notifications ────────────────────────────────────────
section '5 — GET /notifications shows seeded entries'
$r2 = Req GET '/notifications' $null $tok
$found = if ($r2.data) { $r2.data | Where-Object { $_.id -eq $notifId } } else { $null }
if ($found) {
    ok "Seeded notification appears in list"
    if ($found.isRead -eq $false) { ok 'isRead = false' } else { fail 'isRead should be false' '' }
    if ($r2.meta.unreadCount -ge 2) { ok "unreadCount = $($r2.meta.unreadCount) (>= 2)" }
    else { fail 'unreadCount' "expected >= 2, got $($r2.meta.unreadCount)" }
} else { fail 'Notification not in list' ($r2 | ConvertTo-Json -Depth 5) }

# ── 6. Mark single as read ────────────────────────────────────────────────────
section '6 — PATCH /notifications/:id/read'
if ($notifId) {
    $r3 = Req PATCH "/notifications/$notifId/read" $null $tok
    if ($r3.success) { ok 'PATCH /:id/read succeeded' }
    else             { fail 'PATCH /:id/read' ($r3 | ConvertTo-Json) }

    $r4 = Req GET '/notifications' $null $tok
    $updated = if ($r4.data) { $r4.data | Where-Object { $_.id -eq $notifId } } else { $null }
    if ($updated -and $updated.isRead -eq $true) { ok 'isRead flipped to true' }
    else { fail 'isRead should be true after PATCH' ($updated | ConvertTo-Json) }

    $unread = $r4.meta.unreadCount
    if ($unread -eq 1) { ok "unreadCount dropped to 1 (second notif still unread)" }
    else { fail "unreadCount after single read" "expected 1, got $unread" }
}

# ── 7. Mark all as read ───────────────────────────────────────────────────────
section '7 — PATCH /notifications/read-all'
$r5 = Req PATCH '/notifications/read-all' $null $tok
if ($r5.success) { ok 'PATCH /read-all succeeded' }
else             { fail 'PATCH /read-all' ($r5 | ConvertTo-Json) }

$r6 = Req GET '/notifications' $null $tok
if ($r6.meta.unreadCount -eq 0) { ok 'unreadCount = 0 after read-all' }
else { fail 'unreadCount after read-all' "expected 0, got $($r6.meta.unreadCount)" }

# ── 8. Delete notification ────────────────────────────────────────────────────
section '8 — DELETE /notifications/:id'
if ($notifId) {
    $r7 = Req DELETE "/notifications/$notifId" $null $tok
    if ($r7.success) { ok 'DELETE /:id succeeded' }
    else             { fail 'DELETE /:id' ($r7 | ConvertTo-Json) }

    $r8 = Req GET '/notifications' $null $tok
    $gone = if ($r8.data) { $r8.data | Where-Object { $_.id -eq $notifId } } else { $null }
    if (-not $gone) { ok 'Deleted notification is gone from list' }
    else            { fail 'Notification still present after delete' '' }
}

# ── 9. Auth guard ─────────────────────────────────────────────────────────────
section '9 — Auth guard (no token should be rejected)'
$r9 = Req GET '/notifications' $null $null
if (-not $r9.success -or $r9.raw) { ok 'Unauthenticated request correctly rejected' }
else { fail 'Auth guard' 'Expected rejection, got success' }

# ── 10. Pagination ────────────────────────────────────────────────────────────
section '10 — Pagination (?page=1&limit=1)'
$r10 = Req GET '/notifications?page=1&limit=1' $null $tok
if ($r10.success -and $r10.meta.limit -eq 1) { ok "Pagination respected  (limit=$($r10.meta.limit))" }
else { fail 'Pagination' ($r10 | ConvertTo-Json) }

# ── Summary ───────────────────────────────────────────────────────────────────
$total = $script:PASS + $script:FAIL
$color = if ($script:FAIL -eq 0) { 'Green' } else { 'Yellow' }
Write-Host "`n==========================================" -ForegroundColor $color
Write-Host "  PASSED : $($script:PASS) / $total" -ForegroundColor $color
if ($script:FAIL -gt 0) { Write-Host "  FAILED : $($script:FAIL) / $total" -ForegroundColor Red }
Write-Host "==========================================`n" -ForegroundColor $color
