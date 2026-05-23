import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'models/pet_model.dart';
import 'services/api_client.dart';
import 'services/appointment_service.dart';

class BookAppointment extends StatefulWidget {
  final String vetId;
  final String doctorName;
  final String? photoPath;
  final String fee;
  final String startTime;
  final String endTime;

  const BookAppointment({
    super.key,
    required this.vetId,
    required this.doctorName,
    this.photoPath,
    this.fee = '300 EGP',
    this.startTime = '09:00',
    this.endTime = '17:00',
  });

  @override
  State<BookAppointment> createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  int selectedDay = 5;
  late String selectedTime;
  late List<String> _timeSlots;

  List<String> _generateSlots(String start, String end) {
    final sp = start.split(':');
    final ep = end.split(':');
    int cur = int.parse(sp[0]) * 60 + int.parse(sp[1]);
    final last = int.parse(ep[0]) * 60 + int.parse(ep[1]);
    final slots = <String>[];
    while (cur < last) {
      final h = cur ~/ 60;
      final m = cur % 60;
      final period = h < 12 ? 'AM' : 'PM';
      final dh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      slots.add('$dh:${m.toString().padLeft(2, '0')} $period');
      cur += 30;
    }
    return slots;
  }

  @override
  void initState() {
    super.initState();
    _timeSlots = _generateSlots(widget.startTime, widget.endTime);
    selectedTime = _timeSlots.isNotEmpty ? _timeSlots.first : '9:00 AM';
  }

  static const _coral = Color(0xFFFF7578);

  // Maps widget day index → display label and ISO weekday (Mon=1…Sun=7)
  static const _dayNames = {3: 'Sun', 4: 'Mon', 5: 'Tue', 6: 'Wed', 7: 'Thu'};
  static const _dayToWeekday = {3: 7, 4: 1, 5: 2, 6: 3, 7: 4};

  /// Builds the DateTime for the selected day+time in local time.
  DateTime _buildDateTime() {
    final now = DateTime.now();
    final targetWeekday = _dayToWeekday[selectedDay]!;
    int daysUntil = targetWeekday - now.weekday;
    if (daysUntil <= 0) daysUntil += 7;
    final date = now.add(Duration(days: daysUntil));

    final parts = selectedTime.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    if (parts[1] == 'PM' && hour != 12) hour += 12;
    if (parts[1] == 'AM' && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetCtx) => _PaymentSheet(
        vetId: widget.vetId,
        doctorName: widget.doctorName,
        day: '${_dayNames[selectedDay]}, $selectedDay',
        time: selectedTime,
        fee: widget.fee,
        appointmentDateTime: _buildDateTime(),
        onBooked: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => _ConfirmationDialog(
              doctorName: widget.doctorName,
              day: '${_dayNames[selectedDay]}, $selectedDay',
              time: selectedTime,
              onDone: () => Navigator.of(context).pop(),
            ),
          );
        },
      ),
    );
  }

  ImageProvider _resolvePhoto() {
    final p = widget.photoPath;
    if (p == null || p.isEmpty) return const AssetImage('assets/images/vet1.png');
    if (p.startsWith('http')) return NetworkImage(p);
    return NetworkImage('${ApiClient.baseUrl}$p');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C2632),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _showPaymentSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _coral,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: Text('Confirm',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── OVERLAPPING HEADER (Stack) ──────────────────────────
                  // Total SizedBox height = 280 px image + 40 px lower half
                  // of the info card, so the card straddles the boundary.
                  SizedBox(
                    height: 320,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ── Doctor photo (top 280 px, rounded bottom) ──
                        Positioned(
                          top: 0, left: 0, right: 0, bottom: 40,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(32),
                              bottomRight: Radius.circular(32),
                            ),
                            child: Image(
                              image: _resolvePhoto(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // ── Floating name/title card overlapping image ──
                        // bottom: 0 anchors it to the SizedBox base so the
                        // upper half sits on the image and the lower half
                        // extends into the content, creating the overlap.
                        Positioned(
                          bottom: 0, left: 24, right: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 20),
                            decoration: BoxDecoration(
                              color: _coral,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _coral.withValues(alpha: 0.28),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.doctorName.startsWith('Dr') ? widget.doctorName : 'Dr. ${widget.doctorName}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Senior Cardiologist and Surgeon',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: Colors.white
                                          .withValues(alpha: 0.88)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // ── Circular white back button ──
                        Positioned(
                          top: 48, left: 16,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, size: 18),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Appointment',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDayBox('Sun', 3),
                            _buildDayBox('Mon', 4),
                            _buildDayBox('Tue', 5),
                            _buildDayBox('Wed', 6),
                            _buildDayBox('Thu', 7),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text('Available Time',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _timeSlots
                              .map((t) => _buildTimeChip(t))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayBox(String day, int date) {
    final bool isSelected = selectedDay == date;
    return GestureDetector(
      onTap: () => setState(() => selectedDay = date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _coral : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: isSelected ? _coral : Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(day,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('$date',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(String time) {
    final bool isSelected = selectedTime == time;
    return GestureDetector(
      onTap: () => setState(() => selectedTime = time),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? _coral : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? _coral : Colors.grey.shade300),
        ),
        child: Text(time,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87)),
      ),
    );
  }
}

// ── Payment bottom sheet ──────────────────────────────────────────────────────

class _PaymentSheet extends StatefulWidget {
  final String vetId;
  final String doctorName;
  final String day;
  final String time;
  final String fee;
  final DateTime appointmentDateTime;
  final VoidCallback onBooked;

  const _PaymentSheet({
    required this.vetId,
    required this.doctorName,
    required this.day,
    required this.time,
    required this.fee,
    required this.appointmentDateTime,
    required this.onBooked,
  });

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  static const _coral = Color(0xFFFF7578);
  static const _instapayNumber = '01012345678';
  static const _accountName = 'PetsCare App';

  XFile? _invoiceFile;
  Uint8List? _previewBytes;
  bool _submitting = false;
  String? _submitError;

  // Pet selection
  List<PetModel> _pets = [];
  PetModel? _selectedPet;
  bool _loadingPets = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      final pets = await AppointmentService.fetchMyPets();
      if (mounted) {
        setState(() {
          _pets = pets;
          _selectedPet = pets.isNotEmpty ? pets.first : null;
          _loadingPets = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPets = false);
    }
  }

  Future<void> _pickScreenshot() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      if (mounted) setState(() { _invoiceFile = file; _previewBytes = bytes; });
    }
  }

  Future<void> _submit() async {
    if (_invoiceFile == null || _selectedPet == null) return;
    setState(() { _submitting = true; _submitError = null; });

    try {
      await AppointmentService.bookAppointment(
        vetId: widget.vetId,
        petId: _selectedPet!.id,
        startTime: widget.appointmentDateTime,
        invoiceBytes: _previewBytes!,
        invoiceFilename: _invoiceFile!.name,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onBooked();
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _submitting = false; _submitError = e.message; });
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _submitError = 'Submission failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final canSubmit = !_submitting && _invoiceFile != null && _selectedPet != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 3,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),

            Text('Complete Payment',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1919))),
            const SizedBox(height: 4),
            Text('Pay via InstaPay then upload your screenshot',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: const Color(0xFF9E9E9E))),
            const SizedBox(height: 20),

            // Appointment summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow(Icons.person_outline_rounded, widget.doctorName.startsWith('Dr') ? widget.doctorName : 'Dr. ${widget.doctorName}'),
                  const SizedBox(height: 8),
                  _summaryRow(Icons.calendar_today_rounded, widget.day),
                  const SizedBox(height: 8),
                  _summaryRow(Icons.access_time_rounded, widget.time),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1919))),
                      Text(widget.fee,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _coral)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pet selector
            Text('Select Pet',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9E9E9E))),
            const SizedBox(height: 8),
            _loadingPets
                ? const SizedBox(
                    height: 44,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: _coral, strokeWidth: 2),
                      ),
                    ),
                  )
                : _pets.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No pets found. Please add a pet to your profile first.',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<PetModel>(
                            value: _selectedPet,
                            isExpanded: true,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13, color: const Color(0xFF1A1919)),
                            onChanged: (pet) =>
                                setState(() => _selectedPet = pet),
                            items: _pets
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p.displayLabel),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
            const SizedBox(height: 16),

            // InstaPay details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFCCCD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_rounded,
                          color: _coral, size: 18),
                      const SizedBox(width: 8),
                      Text('InstaPay Details',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _coral)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Send to this number:',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: const Color(0xFF9E9E9E))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(_instapayNumber,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1919),
                              letterSpacing: 1.5)),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              const ClipboardData(text: _instapayNumber));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Number copied!',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13)),
                            backgroundColor: _coral,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _coral,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Copy',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Account: $_accountName',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF9E9E9E))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Screenshot upload
            Text('Payment Screenshot',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9E9E9E))),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: _pickScreenshot,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: _previewBytes != null ? 180 : 90,
                decoration: BoxDecoration(
                  color: _previewBytes != null
                      ? Colors.transparent
                      : const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _previewBytes != null
                        ? _coral
                        : const Color(0xFFEEEEEE),
                    width: _previewBytes != null ? 1.5 : 1.0,
                  ),
                ),
                child: _previewBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child:
                            Image.memory(_previewBytes!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_rounded,
                              color: Colors.grey[400], size: 28),
                          const SizedBox(height: 6),
                          Text('Tap to upload screenshot',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFFB0B0B0))),
                        ],
                      ),
              ),
            ),

            if (_submitError != null) ...[
              const SizedBox(height: 10),
              Text(_submitError!,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: Colors.redAccent)),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _coral,
                  disabledBackgroundColor: const Color(0xFFEEEEEE),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Submit Payment',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: canSubmit
                                ? Colors.white
                                : const Color(0xFFB0B0B0))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9E9E9E)),
          const SizedBox(width: 8),
          Text(text,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: const Color(0xFF1A1919))),
        ],
      );
}

// ── Post-booking confirmation dialog ─────────────────────────────────────────

class _ConfirmationDialog extends StatelessWidget {
  final String doctorName;
  final String day;
  final String time;
  final VoidCallback onDone;

  static const _coral = Color(0xFFFF7578);

  const _ConfirmationDialog({
    required this.doctorName,
    required this.day,
    required this.time,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    color: _coral, strokeWidth: 2.5),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Awaiting Approval',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1919)),
            ),
            const SizedBox(height: 10),
            Text(
              'Your payment screenshot has been submitted. '
              'Please wait while the admin verifies your InstaPay payment '
              'for your appointment with ${doctorName.startsWith('Dr') ? doctorName : 'Dr. $doctorName'} on $day at $time.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDone();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _coral,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: Text('Done',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
