import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor_appointments.dart';
import 'services/api_client.dart';

class DoctorAppointmentDetail extends StatefulWidget {
  final VetAppointment appointment;

  const DoctorAppointmentDetail({super.key, required this.appointment});

  @override
  State<DoctorAppointmentDetail> createState() => _DoctorAppointmentDetailState();
}

class _DoctorAppointmentDetailState extends State<DoctorAppointmentDetail> {
  bool _isDone     = false;
  bool _submitting = false;
  String? _error;

  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController     = TextEditingController();

  final _diagnosisFocus = FocusNode();
  final _treatmentFocus = FocusNode();
  final _notesFocus     = FocusNode();

  static const _coral     = Color(0xFFFF7578);
  static const _lightPink = Color(0xFFFFE6E6);

  @override
  void initState() {
    super.initState();
    for (final n in [_diagnosisFocus, _treatmentFocus, _notesFocus]) {
      n.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    _diagnosisFocus.dispose();
    _treatmentFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() { _submitting = true; _error = null; });
    try {
      await ApiClient.patch(
        '/vets/appointments/${widget.appointment.id}/complete',
        {
          if (_diagnosisController.text.trim().isNotEmpty)
            'diagnosis': _diagnosisController.text.trim(),
          if (_treatmentController.text.trim().isNotEmpty)
            'treatment': _treatmentController.text.trim(),
          if (_notesController.text.trim().isNotEmpty)
            'notes': _notesController.text.trim(),
        },
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) setState(() { _submitting = false; _error = e.message; });
    } catch (_) {
      if (mounted) setState(() { _submitting = false; _error = 'Failed to update. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final apt = widget.appointment;

    return Scaffold(
      backgroundColor: const Color(0xFF1C2632),
      body: Center(
        child: Container(
          width: 381.66,
          height: 850.32,
          decoration: ShapeDecoration(
            color: const Color(0xFFF6F6F6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(46)),
          ),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            child: Column(
              children: [
                // Header image
                Container(
                  width: double.infinity,
                  height: 220,
                  color: _lightPink,
                  child: Stack(
                    children: [
                      Center(
                        child: apt.petImageUrl != null
                            ? Image.network(
                                apt.petImageUrl!,
                                height: 180,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.pets, color: _coral, size: 90),
                              )
                            : const Icon(Icons.pets, color: _coral, size: 90),
                      ),
                      Positioned(
                        top: 16, left: 20,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context, false),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1919)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pet name + breed badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(apt.petName,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 26, fontWeight: FontWeight.w700, color: const Color(0xFF1A1919))),
                            if (apt.petBreed != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(color: _lightPink, borderRadius: BorderRadius.circular(20)),
                                child: Text(apt.petBreed!,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13, fontWeight: FontWeight.w600, color: _coral)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Owner
                        Row(children: [
                          const Icon(Icons.person_outline, size: 16, color: Color(0xFF888888)),
                          const SizedBox(width: 6),
                          Text('Owner: ${apt.ownerName}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF888888))),
                        ]),
                        const SizedBox(height: 16),

                        // Time + Fee row
                        Row(children: [
                          Expanded(child: _infoChip(Icons.access_time_rounded, apt.formattedTime, apt.formattedDay.split(',').first)),
                          const SizedBox(width: 12),
                          Expanded(child: _infoChip(Icons.attach_money_rounded, '${apt.price.toStringAsFixed(0)} EGP', 'Consultation fee')),
                        ]),
                        const SizedBox(height: 16),

                        // Owner's booking reason (read-only)
                        _sectionLabel('Reason for visit'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFCCCD)),
                          ),
                          child: Text(
                            apt.reason?.isNotEmpty == true ? apt.reason! : 'No reason provided.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF555555), height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Vet notes section
                        _sectionLabel('Your medical notes'),
                        const SizedBox(height: 4),
                        Text(
                          'These will be saved to the pet\'s medical history.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF9E9E9E)),
                        ),
                        const SizedBox(height: 10),
                        _noteField('Diagnosis', _diagnosisController, _diagnosisFocus, maxLines: 2),
                        const SizedBox(height: 10),
                        _noteField('Treatment / Prescription', _treatmentController, _treatmentFocus, maxLines: 2),
                        const SizedBox(height: 10),
                        _noteField('Additional notes', _notesController, _notesFocus, maxLines: 3),
                        const SizedBox(height: 20),

                        // Mark as done
                        GestureDetector(
                          onTap: () => setState(() => _isDone = !_isDone),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _isDone ? const Color(0xFFFFF0F0) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: _isDone ? _coral : const Color(0xFFE0E0E0),
                                  width: _isDone ? 1.5 : 1.0),
                            ),
                            child: Row(children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  color: _isDone ? _coral : Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: _isDone ? _coral : const Color(0xFFCCCCCC), width: 1.5),
                                ),
                                child: _isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
                              ),
                              const SizedBox(width: 14),
                              Text('Mark appointment as done',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15, fontWeight: FontWeight.w600,
                                      color: _isDone ? _coral : const Color(0xFF1A1919))),
                            ]),
                          ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Text(_error!,
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.redAccent)),
                        ],

                        const SizedBox(height: 16),

                        if (_isDone)
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _confirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _coral,
                                disabledBackgroundColor: const Color(0xFFEEEEEE),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                elevation: 0,
                              ),
                              child: _submitting
                                  ? const SizedBox(width: 22, height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Confirm & Done',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String primary, String secondary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: _lightPink, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: _coral, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(primary, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A1919))),
            Text(secondary, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF888888))),
          ],
        )),
      ]),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1A1919)),
  );

  Widget _noteField(String hint, TextEditingController controller, FocusNode focus, {int maxLines = 1}) {
    final focused = focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: focused ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused ? _coral : const Color(0xFFFFCCCD),
          width: focused ? 1.5 : 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focus,
        maxLines: maxLines,
        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF1A1919)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFFBBBBBB)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
