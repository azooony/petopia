import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor_details.dart';
import 'frame8.dart';
import 'models/doctor_model.dart';
import 'services/appointment_service.dart';
import 'services/api_client.dart';

// Lightweight model for the user's own booked appointments
class _MyAppointment {
  final String id;
  final String vetId;
  final String vetName;
  final String? vetPhoto;
  final String? vetSpec;
  final String petName;
  final DateTime startTime;
  final String status;

  _MyAppointment({
    required this.id,
    required this.vetId,
    required this.vetName,
    this.vetPhoto,
    this.vetSpec,
    required this.petName,
    required this.startTime,
    required this.status,
  });

  factory _MyAppointment.fromJson(Map<String, dynamic> j) {
    final vet        = j['vet']  as Map<String, dynamic>? ?? {};
    final vetProfile = vet['vetProfile'] as Map<String, dynamic>? ?? {};
    final pet        = j['pet']  as Map<String, dynamic>? ?? {};
    return _MyAppointment(
      id:        j['id']           as String,
      vetId:     vet['id']         as String? ?? '',
      vetName:   vet['fullName']   as String? ?? 'Unknown',
      vetPhoto:  vetProfile['photo'] as String?,
      vetSpec:   vetProfile['specialization'] as String?,
      petName:   pet['name']       as String? ?? 'Pet',
      startTime: DateTime.parse(j['startTime'] as String).toLocal(),
      status:    j['status']       as String? ?? 'PENDING',
    );
  }

  String get formattedTime {
    final h = startTime.hour > 12 ? startTime.hour - 12 : (startTime.hour == 0 ? 12 : startTime.hour);
    final m = startTime.minute.toString().padLeft(2, '0');
    final p = startTime.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  String get formattedDate {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[startTime.weekday - 1]}, ${startTime.day}/${startTime.month}/${startTime.year}';
  }
}

class VetAppointments extends StatefulWidget {
  const VetAppointments({super.key});

  @override
  State<VetAppointments> createState() => _VetAppointmentsState();
}

class _VetAppointmentsState extends State<VetAppointments> {
  String? selectedDoctor;
  String? pressedArrowDoctor;
  int _currentIndex = 0;

  List<DoctorModel> _doctors = [];
  List<_MyAppointment> _myAppointments = [];
  Set<String> _bookedVetIds = {};
  bool _isLoading = true;
  String? _error;

  static const _coral = Color(0xFFFF7578);

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        AppointmentService.fetchDoctors(),
        ApiClient.get('/appointments/my'),
      ]);

      final doctors = results[0] as List<DoctorModel>;
      final myRaw   = (results[1] as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
      final myApts  = myRaw.map((e) => _MyAppointment.fromJson(e as Map<String, dynamic>)).toList();

      if (mounted) {
        setState(() {
          _doctors        = doctors;
          _myAppointments = myApts;
          _bookedVetIds   = myApts.map((a) => a.vetId).toSet();
          _isLoading      = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to load. Check your connection.'; _isLoading = false; });
    }
  }

  ImageProvider _resolvePhoto(String? photo) {
    if (photo == null || photo.isEmpty) return const AssetImage('assets/images/vet1.png');
    if (photo.startsWith('http')) return NetworkImage(photo);
    return NetworkImage('${ApiClient.baseUrl}$photo');
  }

  // ── My Appointments section ──────────────────────────────────────────────────

  Widget _buildMyAppointmentsSection() {
    if (_myAppointments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Text(
            'Your Appointments',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1919)),
          ),
        ),
        ..._myAppointments.map(_buildMyAppointmentCard),
        const Divider(height: 24, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildMyAppointmentCard(_MyAppointment apt) {
    final isPending = apt.status == 'PENDING';
    final statusColor = isPending ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
    final statusLabel = isPending ? 'Awaiting approval' : 'Confirmed';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _coral.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: _resolvePhoto(apt.vetPhoto), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apt.vetName,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1919)),
                ),
                const SizedBox(height: 2),
                Text('${apt.petName} · ${apt.formattedDate}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600])),
                Text(apt.formattedTime, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(statusLabel, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ],
      ),
    );
  }

  // ── Vet card ─────────────────────────────────────────────────────────────────

  Widget _buildVetCard(BuildContext context, DoctorModel doctor) {
    final bool isSelected = selectedDoctor == doctor.id;
    final bool alreadyBooked = _bookedVetIds.contains(doctor.id);

    return GestureDetector(
      onTap: () => setState(() => selectedDoctor = isSelected ? null : doctor.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: alreadyBooked ? const Color(0xFFFFF5F5) : (isSelected ? const Color(0xFFFFE5E5) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: alreadyBooked ? Border.all(color: _coral.withValues(alpha: 0.4)) : null,
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.07), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: _resolvePhoto(doctor.vetProfile.photo), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(doctor.fullName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C2632))),
                      ),
                      if (alreadyBooked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _coral.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                          child: Text('Booked', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: _coral)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(doctor.workingHours, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ]),
                  const SizedBox(height: 4),
                  Text('Fee: ${doctor.displayFee}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Arrow — greyed out + disabled when already booked
            GestureDetector(
              onTapDown: alreadyBooked ? null : (_) => setState(() => pressedArrowDoctor = doctor.id),
              onTapUp: alreadyBooked ? null : (_) {
                setState(() => pressedArrowDoctor = null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorDetails(
                      vetId: doctor.id,
                      name: doctor.fullName,
                      specialty: doctor.vetProfile.specialization ?? 'Veterinarian',
                      photoPath: doctor.vetProfile.photo,
                      clinicLocation: '${doctor.vetProfile.clinic.name}, ${doctor.vetProfile.clinic.address}',
                      description: doctor.vetProfile.description ?? 'No description available.',
                      fee: doctor.displayFee,
                      startTime: doctor.vetProfile.startTime,
                      endTime: doctor.vetProfile.endTime,
                    ),
                  ),
                );
              },
              onTapCancel: alreadyBooked ? null : () => setState(() => pressedArrowDoctor = null),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: alreadyBooked ? Colors.grey[300] : const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_forward, color: alreadyBooked ? Colors.grey[500] : Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(0, _buildIconWithCircle(0), onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Frame8()));
          }),
          _navItem(1, _buildImageIconWithCircle(1, 'assets/images/chat_grey.png')),
          _navItem(2, _buildImageIconWithCircle(2, 'assets/images/pet_walking.png')),
        ],
      ),
    );
  }

  Widget _buildIconWithCircle(int index) {
    final bool isActive = _currentIndex == index;
    if (isActive) {
      return Container(
        width: 68, height: 68,
        decoration: const BoxDecoration(color: _coral, shape: BoxShape.circle),
        child: const Icon(Icons.home_rounded, color: Colors.white, size: 38),
      );
    }
    return Icon(Icons.home_outlined, color: Colors.grey[400], size: 42);
  }

  Widget _buildImageIconWithCircle(int index, String imagePath) {
    final bool isActive = _currentIndex == index;
    if (isActive) {
      return Container(
        width: 68, height: 68,
        decoration: const BoxDecoration(color: _coral, shape: BoxShape.circle),
        child: Center(child: Image.asset(imagePath, width: 38, height: 38, color: Colors.white)),
      );
    }
    return Image.asset(imagePath, width: 42, height: 42, color: Colors.grey[400]);
  }

  Widget _navItem(int index, Widget child, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(width: 70, height: 75, child: Center(child: child)),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(30),
          ),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              centerTitle: false,
              title: const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text('Vet Appointments', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            body: Stack(
              children: [
                _buildBody(),
                Positioned(
                  bottom: 12, left: 20, right: 20,
                  child: _buildBottomNav(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: _coral));

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 48),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadAll,
                style: ElevatedButton.styleFrom(backgroundColor: _coral, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_doctors.isEmpty && _myAppointments.isEmpty) {
      return const Center(
        child: Text('No verified vets available at the moment.', style: TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      children: [
        _buildMyAppointmentsSection(),
        if (_doctors.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, _myAppointments.isEmpty ? 8 : 0, 16, 10),
            child: Text(
              'Available doctors',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1919)),
            ),
          ),
        ..._doctors.map((d) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildVetCard(context, d),
        )),
      ],
    );
  }
}
