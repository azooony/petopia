$root    = Split-Path -Parent $MyInvocation.MyCommand.Definition
$backend = Join-Path $root "petopiafinall-master"
$flutter = Join-Path $root "flutter_application_1"

Write-Host "Starting Petopia Backend + AI service..."
Start-Process cmd -ArgumentList "/k npm run dev" -WorkingDirectory $backend

Write-Host "Waiting 20 seconds for backend and AI model to load..."
Start-Sleep 20

Write-Host "Starting Flutter app..."
Start-Process cmd -ArgumentList "/k flutter run" -WorkingDirectory $flutter
