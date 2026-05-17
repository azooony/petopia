import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor_profile_edit.dart';
import 'doctor_appointment_detail.dart';
import 'frame6.dart';
import 'services/api_client.dart';
import 'services/auth_storage.dart';
import 'services/chat_service.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class VetAppointment {
  final String id;
  final String petName;
  final String? petBreed;
  final String? petImageUrl;
  final String ownerName;
  final DateTime startTime;
  final String? reason;
  final double price;

  VetAppointment({
    required this.id,
    required this.petName,
    this.petBreed,
    this.petImageUrl,
    required this.ownerName,
    required this.startTime,
    this.reason,
    required this.price,
  });

  factory VetAppointment.fromJson(Map<String, dynamic> j) {
    final pet   = j['pet']   as Map<String, dynamic>? ?? {};
    final owner = j['owner'] as Map<String, dynamic>? ?? {};

    final rawPhoto = pet['photo'] as String?;
    String? imageUrl;
    if (rawPhoto != null && rawPhoto.isNotEmpty) {
      imageUrl = rawPhoto.startsWith('http') ? rawPhoto : '${ApiClient.baseUrl}$rawPhoto';
    }

    return VetAppointment(
      id:          j['id']           as String,
      petName:     pet['name']       as String? ?? 'Unknown',
      petBreed:    pet['breed']      as String?,
      petImageUrl: imageUrl,
      ownerName:  owner['fullName']  as String? ?? 'Unknown',
      startTime:  DateTime.parse(j['startTime'] as String).toLocal(),
      reason:     j['reason']        as String?,
      price:      (j['price'] as num).toDouble(),
    );
  }

  String get formattedTime {
    final h = startTime.hour > 12
        ? startTime.hour - 12
        : (startTime.hour == 0 ? 12 : startTime.hour);
    final m = startTime.minute.toString().padLeft(2, '0');
    final p = startTime.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  String get formattedDay {
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return '${days[startTime.weekday - 1]}, ${startTime.day}/${startTime.month}/${startTime.year}';
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class DoctorAppointments extends StatefulWidget {
  const DoctorAppointments({super.key});

  @override
  State<DoctorAppointments> createState() => _DoctorAppointmentsState();
}

class _DoctorAppointmentsState extends State<DoctorAppointments> {
  List<VetAppointment> _appointments = [];
  bool   _isLoading = true;
  String? _error;
  String? _filterDay;

  static const _coral = Color(0xFFFF7578);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res  = await ApiClient.get('/vets/appointments');
      final list = res['data'] as List<dynamic>;
      if (mounted) {
        setState(() {
          _appointments = list
              .map((e) => VetAppointment.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to load appointments.'; _isLoading = false; });
    }
  }

  Future<void> _logout() async {
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
    ChatService.disconnect();
    await AuthStorage.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Frame6()),
      (_) => false,
    );
  }

  List<VetAppointment> get _filtered => _filterDay == null
      ? _appointments
      : _appointments.where((a) => a.formattedDay.startsWith(_filterDay!)).toList();

  void _showFilter() {
    final days = _appointments.map((a) {
      const d = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
      return d[a.startTime.weekday - 1];
    }).toSet().toList()..sort();

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          alignment: Alignment.bottomCenter,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4,
                      decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text('Filter by day', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1A1919))),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: [
                      _filterChip('All', _filterDay == null, () { setS(() {}); setState(() => _filterDay = null); }),
                      ...days.map((d) => _filterChip(d, _filterDay == d, () { setS(() {}); setState(() => _filterDay = d); })),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(backgroundColor: _coral, foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 0),
                      child: Text('Apply', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _coral : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _coral : const Color(0xFFFFCCCD), width: selected ? 1.5 : 1.0),
        ),
        child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF888888))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2632),
      body: Center(
        child: Container(
          width: 381.66,
          height: 850.32,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(46)),
          ),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorProfileEdit())),
                        child: Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF8D8D8D), width: 2)),
                          child: const Icon(Icons.person_rounded, color: Color(0xFF8D8D8D), size: 26),
                        ),
                      ),
                      Row(
                        children: [
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.menu_rounded, color: Color(0xFF8D8D8D), size: 26),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            onSelected: (v) { if (v == 'logout') _logout(); },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(children: [
                                  const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                                  const SizedBox(width: 10),
                                  Text('Logout', style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                                ]),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _showFilter,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(Icons.tune_rounded, color: _filterDay != null ? _coral : const Color(0xFF8D8D8D), size: 28),
                                if (_filterDay != null)
                                  Positioned(top: -2, right: -2,
                                    child: Container(width: 8, height: 8,
                                        decoration: const BoxDecoration(color: _coral, shape: BoxShape.circle))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('your appointments',
                      style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF1A1919))),
                  const SizedBox(height: 16),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: _coral));

    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        Text(_error!, style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _load,
            style: ElevatedButton.styleFrom(backgroundColor: _coral, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: Text('Retry', style: GoogleFonts.plusJakartaSans(color: Colors.white))),
      ]));
    }

    if (_filtered.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.event_available_rounded, size: 56, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text(_filterDay != null ? 'No appointments on $_filterDay' : 'No upcoming appointments',
            style: GoogleFonts.plusJakartaSans(fontSize: 15, color: Colors.grey[400], fontWeight: FontWeight.w500)),
      ]));
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final apt = _filtered[i];
        return _buildCard(apt, onTap: () async {
          final done = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => DoctorAppointmentDetail(appointment: apt)),
          );
          if (done == true) {
            setState(() => _appointments.removeWhere((a) => a.id == apt.id));
          }
        });
      },
    );
  }

  Widget _buildCard(VetAppointment apt, {required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(color: const Color(0xFFFFE6E6), borderRadius: BorderRadius.circular(16)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: apt.petImageUrl != null
                        ? Image.network(apt.petImageUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.pets, color: Color(0xFFFF7578), size: 36))
                        : const Icon(Icons.pets, color: Color(0xFFFF7578), size: 36),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(apt.petName,
                          style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1A1919))),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.person_outline, size: 14, color: Color(0xFF888888)),
                        const SizedBox(width: 4),
                        Text(apt.ownerName, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF888888))),
                      ]),
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF888888)),
                        const SizedBox(width: 4),
                        Text(apt.formattedTime, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF888888))),
                        const SizedBox(width: 8),
                        Text('· ${apt.formattedDay.split(',').first}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF888888))),
                      ]),
                    ],
                  ),
                ),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: _coral, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
