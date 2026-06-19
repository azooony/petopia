import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'frame6.dart';
import 'services/api_client.dart';

// ── Local models ──────────────────────────────────────────────────────────────

class _PendingVet {
  final String id;
  final String name;
  final String specialization;
  final String clinicName;
  final String clinicAddress;
  final String certificateImage;
  final String photo;
  String status;

  _PendingVet({
    required this.id,
    required this.name,
    required this.specialization,
    required this.clinicName,
    required this.clinicAddress,
    required this.certificateImage,
    required this.photo,
    required this.status,
  });

  factory _PendingVet.fromJson(Map<String, dynamic> j) {
    final user   = j['user']   as Map<String, dynamic>? ?? {};
    final clinic = j['clinic'] as Map<String, dynamic>? ?? {};
    return _PendingVet(
      id:               j['id']                as String,
      name:             user['fullName']        as String? ?? 'Unknown',
      specialization:   j['specialization']     as String? ?? '',
      clinicName:       clinic['name']          as String? ?? '',
      clinicAddress:    clinic['address']       as String? ?? '',
      certificateImage: j['certificateImage']   as String? ?? '',
      photo:            j['photo']              as String? ?? '',
      status:           j['verificationStatus'] as String? ?? 'PENDING',
    );
  }
}

class _PendingSitter {
  final String id;
  final String name;
  final String email;
  final String idCardImageUrl;
  final String venuePhotoUrl;
  String status;

  _PendingSitter({
    required this.id,
    required this.name,
    required this.email,
    required this.idCardImageUrl,
    required this.venuePhotoUrl,
    required this.status,
  });

  factory _PendingSitter.fromJson(Map<String, dynamic> j) {
    final user = j['user'] as Map<String, dynamic>? ?? {};
    return _PendingSitter(
      id:             j['id']                    as String,
      name:           user['fullName']            as String? ?? 'Unknown',
      email:          user['email']               as String? ?? '',
      idCardImageUrl: j['IdCardImage']            as String? ?? '',
      venuePhotoUrl:  j['venuePhotoUrl']          as String? ?? '',
      status:         j['verificationStatus']     as String? ?? 'PENDING',
    );
  }
}

class _PendingPayment {
  final String id;
  final String vetName;
  final String ownerName;
  final String startTime;
  final String amount;
  final String currency;
  final String? clinicName;
  final String? petName;
  final String? reason;
  final String? proofUrl;
  String status;

  _PendingPayment({
    required this.id,
    required this.vetName,
    required this.ownerName,
    required this.startTime,
    required this.amount,
    required this.currency,
    this.clinicName,
    this.petName,
    this.reason,
    required this.proofUrl,
    required this.status,
  });

  factory _PendingPayment.fromJson(Map<String, dynamic> j) {
    final appt  = j['appointment'] as Map<String, dynamic>? ?? {};
    final vet   = appt['vet']      as Map<String, dynamic>? ?? {};
    final owner = appt['owner']    as Map<String, dynamic>? ?? {};
    final pet   = appt['pet']      as Map<String, dynamic>?;
    final proof = j['proofAsset']  as Map<String, dynamic>?;

    final raw = appt['startTime'] as String? ?? '';
    String formatted = raw;
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h  = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m  = dt.minute.toString().padLeft(2, '0');
      final p  = dt.hour < 12 ? 'AM' : 'PM';
      formatted = '${dt.day}/${dt.month}/${dt.year}  $h:$m $p';
    } catch (_) {}

    return _PendingPayment(
      id:          j['id']                    as String,
      vetName:     vet['fullName']             as String? ?? 'Unknown',
      ownerName:   owner['fullName']           as String? ?? 'Unknown',
      startTime:   formatted,
      amount:      (j['amount']  ?? 0).toString(),
      currency:    j['currency'] as String?   ?? 'EGP',
      clinicName:  appt['clinicName']          as String?,
      petName:     pet?['name']                as String?,
      reason:      appt['reason']              as String?,
      proofUrl:    proof?['url']               as String?,
      status:      j['status']  as String?    ?? 'PENDING',
    );
  }
}

// ── Widget ────────────────────────────────────────────────────────────────────

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _coral  = Color(0xFFFF7578);
  static const _bg     = Color(0xFFF7F7F7);

  // Doctors
  List<_PendingVet> _vets = [];
  bool   _vetsLoading = true;
  String? _vetsError;

  // Sitters
  List<_PendingSitter> _sitters = [];
  bool   _sittersLoading = true;
  String? _sittersError;

  // Payments (real API)
  List<_PendingPayment> _payments = [];
  bool   _paymentsLoading = true;
  String? _paymentsError;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadVets();
    _loadSitters();
    _loadPayments();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ── Loaders ───────────────────────────────────────────────────────────────

  Future<void> _loadVets() async {
    setState(() { _vetsLoading = true; _vetsError = null; });
    try {
      final res  = await ApiClient.get('/admin/vets/pending');
      final list = res['data'] as List<dynamic>;
      if (mounted) {
        setState(() {
          _vets = list.map((e) => _PendingVet.fromJson(e as Map<String, dynamic>)).toList();
          _vetsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() { _vetsError = 'Failed to load. Tap to retry.'; _vetsLoading = false; });
      }
    }
  }

  Future<void> _loadSitters() async {
    setState(() { _sittersLoading = true; _sittersError = null; });
    try {
      final res  = await ApiClient.get('/sitting/admin/pending');
      final list = res['data'] as List<dynamic>;
      if (mounted) {
        setState(() {
          _sitters = list.map((e) => _PendingSitter.fromJson(e as Map<String, dynamic>)).toList();
          _sittersLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() { _sittersError = 'Failed to load. Tap to retry.'; _sittersLoading = false; });
      }
    }
  }

  Future<void> _loadPayments() async {
    setState(() { _paymentsLoading = true; _paymentsError = null; });
    try {
      final res  = await ApiClient.get('/admin/payments/pending');
      final list = res['data'] as List<dynamic>;
      if (mounted) {
        setState(() {
          _payments = list.map((e) => _PendingPayment.fromJson(e as Map<String, dynamic>)).toList();
          _paymentsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() { _paymentsError = 'Failed to load. Tap to retry.'; _paymentsLoading = false; });
      }
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _approveVet(_PendingVet vet) async {
    try {
      await ApiClient.patch('/admin/vets/${vet.id}/approve', {});
      if (mounted) setState(() => vet.status = 'VERIFIED');
    } on ApiException catch (e) { _showSnack(e.message); }
  }

  Future<void> _rejectVet(_PendingVet vet) async {
    try {
      await ApiClient.patch('/admin/vets/${vet.id}/reject', {});
      if (mounted) setState(() => vet.status = 'REJECTED');
    } on ApiException catch (e) { _showSnack(e.message); }
  }

  Future<void> _approveSitter(_PendingSitter s) async {
    try {
      await ApiClient.patch('/sitting/admin/${s.id}/approve', {});
      if (mounted) setState(() => s.status = 'APPROVED');
    } on ApiException catch (e) { _showSnack(e.message); }
  }

  Future<void> _rejectSitter(_PendingSitter s) async {
    try {
      await ApiClient.patch('/sitting/admin/${s.id}/reject', {});
      if (mounted) setState(() => s.status = 'REJECTED');
    } on ApiException catch (e) { _showSnack(e.message); }
  }

  Future<void> _approvePayment(_PendingPayment p) async {
    try {
      await ApiClient.patch('/admin/payments/${p.id}/approve', {});
      if (mounted) setState(() => p.status = 'PAID');
    } on ApiException catch (e) { _showSnack(e.message); }
  }

  Future<void> _rejectPayment(_PendingPayment p) async {
    try {
      await ApiClient.patch('/admin/payments/${p.id}/reject', {});
      if (mounted) setState(() => p.status = 'FAILED');
    } on ApiException catch (e) { _showSnack(e.message); }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.plusJakartaSans()),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pendingDocCount = _vets.where((v) => v.status == 'PENDING').length;
    final pendingSitCount = _sitters.where((s) => s.status == 'PENDING').length;
    final pendingPayCount = _payments.where((p) => p.status == 'PENDING').length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(30),
          ),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: _coral.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: _coral, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text('Admin Panel',
                      style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF1A1919),
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              actions: [
                TextButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text('Log out?',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17)),
                        content: Text('Are you sure you want to log out?',
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF6B6B6B))),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('Cancel',
                                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF9E9E9E))),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('Log out',
                                style: GoogleFonts.plusJakartaSans(
                                    color: Colors.redAccent, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true || !mounted) return;
                    navigator.pushReplacement(
                        MaterialPageRoute(builder: (_) => const Frame6()));
                  },
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFF9E9E9E), size: 18),
                  label: Text('Logout',
                      style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF9E9E9E), fontSize: 12)),
                ),
              ],
              bottom: TabBar(
                controller: _tab,
                indicatorColor: _coral,
                labelColor: _coral,
                unselectedLabelColor: const Color(0xFFB0B0B0),
                labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12),
                tabs: [
                  Tab(text: 'Doctors${pendingDocCount > 0 ? " ($pendingDocCount)" : ""}'),
                  Tab(text: 'Sitters${pendingSitCount > 0 ? " ($pendingSitCount)" : ""}'),
                  Tab(text: 'Payments${pendingPayCount > 0 ? " ($pendingPayCount)" : ""}'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tab,
              children: [
                _buildVetList(),
                _buildSitterList(),
                _buildPaymentList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Doctors tab ───────────────────────────────────────────────────────────

  Widget _buildVetList() {
    if (_vetsLoading) return const Center(child: CircularProgressIndicator(color: _coral));
    if (_vetsError != null) return _empty(_vetsError!, retry: _loadVets);
    if (_vets.isEmpty) return _empty('No pending vet registrations');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _vets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildVetCard(_vets[i]),
    );
  }

  Widget _buildVetCard(_PendingVet vet) {
    final isPending  = vet.status == 'PENDING';
    final isApproved = vet.status == 'VERIFIED';
    final statusColor = isApproved
        ? const Color(0xFF2ECC71)
        : !isPending ? Colors.redAccent : const Color(0xFFF5A623);
    final statusLabel = isApproved ? 'Approved' : isPending ? 'Pending' : 'Rejected';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isApproved
              ? const Color(0xFF2ECC71).withValues(alpha: 0.3)
              : !isPending ? Colors.redAccent.withValues(alpha: 0.3) : const Color(0xFFEEEEEE),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _doctorAvatar(vet.photo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vet.name,
                        style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF1A1919), fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${vet.specialization} · ${vet.clinicName}',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF9E9E9E), fontSize: 12)),
                  ],
                ),
              ),
              _statusBadge(statusLabel, statusColor),
            ],
          ),
          const SizedBox(height: 12),
          // Clinic address
          if (vet.clinicAddress.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(vet.clinicAddress,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF9E9E9E))),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Text('Certificate',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9E9E9E))),
          const SizedBox(height: 6),
          if (vet.certificateImage.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                vet.certificateImage.startsWith('http')
                    ? vet.certificateImage
                    : '${ApiClient.baseUrl}${vet.certificateImage}',
                width: double.infinity, height: 160, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder('Certificate'),
              ),
            )
          else
            _imagePlaceholder('Certificate'),
          if (isPending) ...[
            const SizedBox(height: 14),
            _approveRejectRow(onReject: () => _rejectVet(vet), onApprove: () => _approveVet(vet)),
          ],
        ],
      ),
    );
  }

  // ── Sitters tab ───────────────────────────────────────────────────────────

  Widget _buildSitterList() {
    if (_sittersLoading) return const Center(child: CircularProgressIndicator(color: _coral));
    if (_sittersError != null) return _empty(_sittersError!, retry: _loadSitters);
    if (_sitters.isEmpty) return _empty('No pending sitter requests');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _sitters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildSitterCard(_sitters[i]),
    );
  }

  Widget _buildSitterCard(_PendingSitter s) {
    final isPending  = s.status == 'PENDING';
    final isApproved = s.status == 'APPROVED';
    final statusColor = isApproved
        ? const Color(0xFF2ECC71)
        : !isPending ? Colors.redAccent : const Color(0xFFF5A623);
    final statusLabel = isApproved ? 'Approved' : isPending ? 'Pending' : 'Rejected';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isApproved
              ? const Color(0xFF2ECC71).withValues(alpha: 0.3)
              : !isPending ? Colors.redAccent.withValues(alpha: 0.3) : const Color(0xFFEEEEEE),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: _coral.withValues(alpha: 0.10), shape: BoxShape.circle),
                child: const Icon(Icons.person_outline_rounded, color: _coral, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF1A1919), fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(s.email,
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF9E9E9E), fontSize: 12)),
                  ],
                ),
              ),
              _statusBadge(statusLabel, statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Text('National ID',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9E9E9E))),
          const SizedBox(height: 6),
          if (s.idCardImageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                s.idCardImageUrl.startsWith('http')
                    ? s.idCardImageUrl
                    : '${ApiClient.baseUrl}${s.idCardImageUrl}',
                width: double.infinity, height: 140, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder('ID photo unavailable'),
              ),
            )
          else
            _imagePlaceholder('No ID photo uploaded'),
          const SizedBox(height: 12),
          Text('Venue Photo',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9E9E9E))),
          const SizedBox(height: 6),
          if (s.venuePhotoUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                s.venuePhotoUrl.startsWith('http')
                    ? s.venuePhotoUrl
                    : '${ApiClient.baseUrl}${s.venuePhotoUrl}',
                width: double.infinity, height: 140, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder('Venue photo unavailable'),
              ),
            )
          else
            _imagePlaceholder('No venue photo uploaded'),
          if (isPending) ...[
            const SizedBox(height: 14),
            _approveRejectRow(onReject: () => _rejectSitter(s), onApprove: () => _approveSitter(s)),
          ],
        ],
      ),
    );
  }

  // ── Payments tab (real API) ───────────────────────────────────────────────

  Widget _buildPaymentList() {
    if (_paymentsLoading) return const Center(child: CircularProgressIndicator(color: _coral));
    if (_paymentsError != null) return _empty(_paymentsError!, retry: _loadPayments);
    if (_payments.isEmpty) return _empty('No pending payment requests');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildPaymentCard(_payments[i]),
    );
  }

  Widget _buildPaymentCard(_PendingPayment p) {
    final isPending  = p.status == 'PENDING';
    final isApproved = p.status == 'PAID';
    final statusColor = isApproved
        ? const Color(0xFF2ECC71)
        : isPending ? const Color(0xFFF5A623) : Colors.redAccent;
    final statusLabel = isApproved ? 'Approved' : isPending ? 'Pending' : 'Rejected';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isApproved
              ? const Color(0xFF2ECC71).withValues(alpha: 0.3)
              : !isPending ? Colors.redAccent.withValues(alpha: 0.3) : const Color(0xFFEEEEEE),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: _coral.withValues(alpha: 0.10), shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long_rounded, color: _coral, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr. ${p.vetName}',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1919))),
                    const SizedBox(height: 2),
                    Text('Owner: ${p.ownerName}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF9E9E9E))),
                    Text(p.startTime,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFFB0B0B0))),
                  ],
                ),
              ),
              _statusBadge(statusLabel, statusColor),
            ],
          ),
          const SizedBox(height: 10),
          // Info chips row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _infoChip(Icons.attach_money_rounded, '${p.amount} ${p.currency}', _coral),
              if (p.petName != null && p.petName!.isNotEmpty)
                _infoChip(Icons.pets_rounded, p.petName!, const Color(0xFF6C63FF)),
              if (p.clinicName != null && p.clinicName!.isNotEmpty)
                _infoChip(Icons.local_hospital_outlined, p.clinicName!, const Color(0xFF2ECC71)),
            ],
          ),
          if (p.reason != null && p.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reason for visit',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFFB0B0B0), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(p.reason!,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF1A1919))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text('Payment Screenshot',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9E9E9E))),
          const SizedBox(height: 6),
          if (p.proofUrl != null && p.proofUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                '${ApiClient.baseUrl}${p.proofUrl}',
                width: double.infinity, height: 180, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder('Screenshot unavailable'),
              ),
            )
          else
            _imagePlaceholder('No screenshot uploaded'),
          if (isPending) ...[
            const SizedBox(height: 14),
            _approveRejectRow(
              onReject: () => _rejectPayment(p),
              onApprove: () => _approvePayment(p),
            ),
          ],
        ],
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  Widget _doctorAvatar(String photo) {
    final fallback = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _coral.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person_outline_rounded,
          color: _coral, size: 22),
    );

    if (photo.isEmpty) return fallback;

    final imageUrl = photo.startsWith('http')
        ? photo
        : '${ApiClient.baseUrl}$photo';

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      );

  Widget _imagePlaceholder(String label) => Container(
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, color: Color(0xFFB0B0B0), size: 26),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.plusJakartaSans(color: const Color(0xFFB0B0B0), fontSize: 11)),
          ],
        ),
      );

  Widget _statusBadge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: GoogleFonts.plusJakartaSans(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  Widget _approveRejectRow({required VoidCallback onReject, required VoidCallback onApprove}) =>
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onReject,
              icon: const Icon(Icons.close_rounded, size: 16),
              label: Text('Reject', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onApprove,
              icon: const Icon(Icons.check_rounded, size: 16),
              label: Text('Approve', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      );

  Widget _empty(String msg, {VoidCallback? retry}) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(msg, style: GoogleFonts.plusJakartaSans(color: const Color(0xFFB0B0B0), fontSize: 14)),
            if (retry != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: retry,
                child: Text('Retry',
                    style: GoogleFonts.plusJakartaSans(color: _coral, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      );
}
