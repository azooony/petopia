import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'services/api_client.dart';
import 'services/sitting_service.dart';

class AddPetSittingScreen extends StatefulWidget {
  const AddPetSittingScreen({super.key});

  @override
  State<AddPetSittingScreen> createState() => _AddPetSittingScreenState();
}

class _AddPetSittingScreenState extends State<AddPetSittingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ownerNameController = TextEditingController();
  final _addressController   = TextEditingController();
  final _petNameController   = TextEditingController();
  final _breedController     = TextEditingController();
  final _ageController       = TextEditingController();
  final _aboutController     = TextEditingController();
  final _priceController     = TextEditingController();
  final _notesController     = TextEditingController();

  final _ownerNameFocus = FocusNode();
  final _addressFocus   = FocusNode();
  final _petNameFocus   = FocusNode();
  final _breedFocus     = FocusNode();
  final _ageFocus       = FocusNode();
  final _aboutFocus     = FocusNode();
  final _priceFocus     = FocusNode();
  final _notesFocus     = FocusNode();

  DateTime? _startDate;
  DateTime? _endDate;

  Uint8List? _petPhotoBytes;
  String? _petPhotoUrl;
  String _gender       = 'MALE';
  String _petType      = 'DOG';
  bool _isLoading      = false;
  bool _isFetchingUser = true;
  bool _isAnalyzing    = false;
  bool _dateError      = false;

  static const _coral = Color(0xFFFF7578);

  int? get _durationDays {
    if (_startDate == null || _endDate == null) return null;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  void initState() {
    super.initState();
    for (final n in [
      _ownerNameFocus, _addressFocus, _petNameFocus, _breedFocus,
      _ageFocus, _aboutFocus, _priceFocus, _notesFocus,
    ]) {
      n.addListener(() => setState(() {}));
    }
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final res = await ApiClient.get('/users/me');
      final data = res['data'] as Map<String, dynamic>? ?? res;
      final pet  = data['pets'] as Map<String, dynamic>?;

      if (mounted) {
        setState(() {
          _ownerNameController.text = (data['fullName'] as String?) ?? '';
          _addressController.text   = (data['address']  as String?) ?? '';

          if (pet != null) {
            _petNameController.text = (pet['name']        as String?) ?? '';
            _breedController.text   = (pet['breed']       as String?) ?? '';
            _ageController.text     = ((pet['age'] as num?)?.toInt())?.toString() ?? '';
            _aboutController.text   = (pet['description'] as String?) ?? '';

            final g = pet['gender'] as String?;
            if (g == 'FEMALE') _gender = 'FEMALE';
            if (g == 'MALE')   _gender = 'MALE';

            final pt = (pet['petType'] as String?)?.toUpperCase();
            if (pt == 'CAT') _petType = 'CAT';
            if (pt == 'DOG') _petType = 'DOG';

            final rawPhoto = pet['photo'] as String?;
            if (rawPhoto != null && rawPhoto.isNotEmpty) {
              _petPhotoUrl = rawPhoto.startsWith('http')
                  ? rawPhoto
                  : '${ApiClient.baseUrl}$rawPhoto';
            }

            final rate = pet['payRatePerDay'] as num?;
            if (rate != null) _priceController.text = rate.toInt().toString();

            final rawNotes = pet['sittingNotes'] as String?;
            if (rawNotes != null && rawNotes.isNotEmpty) {
              final parts = rawNotes.split('\n');
              // Parse stored "YYYY-MM-DD to YYYY-MM-DD" from first line
              final dateRe = RegExp(r'(\d{4}-\d{2}-\d{2}) to (\d{4}-\d{2}-\d{2})');
              final match  = dateRe.firstMatch(parts.first);
              if (match != null) {
                _startDate = DateTime.tryParse(match.group(1)!);
                _endDate   = DateTime.tryParse(match.group(2)!);
              }
              if (parts.length > 1) {
                _notesController.text = parts.skip(1).join('\n').trim();
              }
            }
          }

          _isFetchingUser = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFetchingUser = false);
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      initialDateRange: (_startDate != null && _endDate != null)
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _coral,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null && mounted) {
      setState(() {
        _startDate = range.start;
        _endDate   = range.end;
        _dateError = false;
      });
    }
  }

  @override
  void dispose() {
    for (final c in [
      _ownerNameController, _addressController, _petNameController,
      _breedController, _ageController, _aboutController,
      _priceController, _notesController,
    ]) {
      c.dispose();
    }
    for (final n in [
      _ownerNameFocus, _addressFocus, _petNameFocus, _breedFocus,
      _ageFocus, _aboutFocus, _priceFocus, _notesFocus,
    ]) {
      n.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() { _petPhotoBytes = bytes; _isAnalyzing = true; });

    try {
      final res = await ApiClient.multipartPostBytes(
        '/pets/analyze',
        fields: {},
        bytes: bytes,
        filename: file.name,
        fileField: 'photo',
      );
      final data = res['data'] as Map<String, dynamic>?;
      if (data != null && mounted) {
        final animal = (data['animal'] as String?)?.toUpperCase();
        final breed  = data['breed']  as String?;
        setState(() {
          if (animal == 'CAT' || animal == 'DOG') _petType = animal!;
          if (breed != null && breed.isNotEmpty) _breedController.text = breed;
        });
      }
    } catch (e) {
      debugPrint('[AddPetSitting] analyze error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not detect breed: $e',
              style: GoogleFonts.plusJakartaSans(fontSize: 12)),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 5),
        ));
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _submit() async {
    setState(() => _dateError = _startDate == null || _endDate == null);
    if (!_formKey.currentState!.validate() || _dateError) return;

    final priceVal = double.tryParse(_priceController.text.trim()) ?? 0;
    final days = _durationDays!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('List Your Pet?',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, fontSize: 17)),
        content: Text(
          'Duration: ${_fmt(_startDate!)} → ${_fmt(_endDate!)} ($days days)\nPay rate: ${priceVal.toInt()} EGP/day',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: const Color(0xFF6B6B6B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF9E9E9E))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirm',
                style: GoogleFonts.plusJakartaSans(
                    color: _coral, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      // First line = machine-readable date range; rest = special notes
      final startIso = _startDate!.toIso8601String().substring(0, 10);
      final endIso   = _endDate!.toIso8601String().substring(0, 10);
      final durationLine = '$startIso to $endIso';
      final extraNotes = _notesController.text.trim();
      final combined = extraNotes.isNotEmpty ? '$durationLine\n$extraNotes' : durationLine;

      await SittingService.listPetForSitting(
        petName:      _petNameController.text.trim(),
        breed:        _breedController.text.trim(),
        age:          int.tryParse(_ageController.text.trim()) ?? 0,
        gender:       _gender,
        petType:      _petType,
        payRatePerDay: priceVal,
        sittingNotes: combined,
        photoBytes:   _petPhotoBytes,
        photoFilename: _petPhotoBytes != null ? 'pet_photo.jpg' : null,
      );

      if (!mounted) return;
      _showSuccessSheet();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Connection failed. Is the server running?');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.plusJakartaSans()),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.fromLTRB(
            28, 16, 28, MediaQuery.of(ctx).padding.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 3,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 28),
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F0), shape: BoxShape.circle),
              child: const Icon(Icons.home_rounded, color: _coral, size: 36),
            ),
            const SizedBox(height: 20),
            Text('Your pet is up for sitting!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 20, fontWeight: FontWeight.w700, color: _coral)),
            const SizedBox(height: 10),
            Text(
              'Your pet has been listed. Browse to find the perfect sitter.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: const Color(0xFF9E9E9E), height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                  elevation: 0,
                ),
                child: Text('View Sitting List',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme:
            GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1C2632),
        body: Center(
          child: Container(
            width: 381.66,
            height: 850.32,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(46)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E8E8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 16, color: Color(0xFF1A1919)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_isFetchingUser)
                    const Expanded(
                      child: Center(
                          child: CircularProgressIndicator(color: _coral)),
                    )
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sitting Request',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1919))),
                              const SizedBox(height: 6),
                              Text(
                                'Fill in your pet\'s details so sitters can find and care for them.',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFF9E9E9E),
                                    height: 1.5),
                              ),
                              const SizedBox(height: 24),

                              // Pet photo
                              Text('pet photo', style: _labelStyle()),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: _pickPhoto,
                                child: Container(
                                  width: 110, height: 110,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E0E0),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: _petPhotoBytes != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Image.memory(
                                              _petPhotoBytes!, fit: BoxFit.cover),
                                        )
                                      : _petPhotoUrl != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Image.network(
                                                _petPhotoUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(Icons.pets_rounded,
                                                        size: 36,
                                                        color: Colors.grey[400]),
                                              ),
                                            )
                                          : Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(Icons.add_a_photo_outlined,
                                                    size: 32,
                                                    color: Colors.grey[400]),
                                                Positioned(
                                                  bottom: 8, right: 8,
                                                  child: Container(
                                                    width: 22, height: 22,
                                                    decoration: const BoxDecoration(
                                                        color: _coral,
                                                        shape: BoxShape.circle),
                                                    child: const Icon(Icons.add,
                                                        color: Colors.white,
                                                        size: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              _field(
                                label: 'owner name',
                                controller: _ownerNameController,
                                focus: _ownerNameFocus,
                                readOnly: true,
                              ),
                              const SizedBox(height: 16),

                              _field(
                                label: 'address / city',
                                controller: _addressController,
                                focus: _addressFocus,
                              ),
                              const SizedBox(height: 16),

                              _field(
                                label: 'pet name',
                                controller: _petNameController,
                                focus: _petNameFocus,
                              ),
                              const SizedBox(height: 16),

                              Stack(
                                children: [
                                  _field(
                                    label: 'pet breed',
                                    controller: _breedController,
                                    focus: _breedFocus,
                                  ),
                                  if (_isAnalyzing)
                                    Positioned(
                                      right: 14,
                                      bottom: 13,
                                      child: SizedBox(
                                        width: 16, height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _coral,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _field(
                                label: 'about your pet',
                                controller: _aboutController,
                                focus: _aboutFocus,
                                maxLines: 3,
                                readOnly: true,
                                required: false,
                              ),
                              const SizedBox(height: 16),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _field(
                                      label: 'age',
                                      controller: _ageController,
                                      focus: _ageFocus,
                                      keyboard: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('gender', style: _labelStyle()),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(child: _genderChip('MALE', 'Male')),
                                            const SizedBox(width: 8),
                                            Expanded(child: _genderChip('FEMALE', 'Female')),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // ── Date range picker ──────────────────────────
                              _dateRangeField(),
                              const SizedBox(height: 16),

                              _field(
                                label: 'price per day (max 1000 EGP)',
                                controller: _priceController,
                                focus: _priceFocus,
                                keyboard: TextInputType.number,
                                prefixIcon: Icons.payments_outlined,
                                hint: 'e.g. 150',
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  final n = double.tryParse(v);
                                  if (n == null) return 'Enter a number';
                                  if (n <= 0) return 'Must be > 0';
                                  if (n > 1000) return 'Max 1000 EGP';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _field(
                                label: 'special notes',
                                controller: _notesController,
                                focus: _notesFocus,
                                maxLines: 4,
                                required: false,
                              ),
                              const SizedBox(height: 32),

                              SizedBox(
                                width: double.infinity, height: 54,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _coral,
                                    disabledBackgroundColor: Colors.grey[400],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(28)),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22, height: 22,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : Text('Submit for Sitting',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
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

  Widget _dateRangeField() {
    final hasRange = _startDate != null && _endDate != null;
    final days = _durationDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('duration needed', style: _labelStyle()),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDateRange,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: hasRange ? const Color(0xFFFFF5F5) : Colors.white,
              border: Border.all(
                color: _dateError
                    ? Colors.redAccent
                    : hasRange
                        ? _coral
                        : const Color(0xFFFFCCCD),
                width: hasRange ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: hasRange
                ? Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          size: 18, color: _coral),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(_fmt(_startDate!),
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1A1919))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: Icon(Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: Colors.grey[400]),
                                ),
                                Text(_fmt(_endDate!),
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1A1919))),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text('$days ${days == 1 ? 'day' : 'days'}',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: _coral,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Icon(Icons.edit_calendar_rounded,
                          size: 16, color: Colors.grey[400]),
                    ],
                  )
                : Row(
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          size: 18,
                          color: _dateError
                              ? Colors.redAccent
                              : const Color(0xFFB0B0B0)),
                      const SizedBox(width: 10),
                      Text('Select dates',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: _dateError
                                  ? Colors.redAccent
                                  : const Color(0xFFB0B0B0))),
                    ],
                  ),
          ),
        ),
        if (_dateError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text('Please select a date range',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: Colors.redAccent)),
          ),
      ],
    );
  }

  Widget _genderChip(String value, String label) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 46,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF0F0) : Colors.white,
          border: Border.all(
            color: selected ? _coral : const Color(0xFFFFCCCD),
            width: selected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value == 'MALE' ? Icons.male_rounded : Icons.female_rounded,
                size: 15,
                color: selected ? _coral : const Color(0xFF9E9E9E),
              ),
              const SizedBox(width: 4),
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? _coral : const Color(0xFF9E9E9E))),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF9E9E9E));

  Widget _field({
    required String label,
    required TextEditingController controller,
    required FocusNode focus,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool required = true,
    String? hint,
    IconData? prefixIcon,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    final focused = focus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: readOnly
                ? const Color(0xFFF5F5F5)
                : focused
                    ? const Color(0xFFFFF5F5)
                    : Colors.white,
            border: Border.all(
              color: focused ? _coral : const Color(0xFFFFCCCD),
              width: focused ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focus,
            keyboardType: keyboard,
            maxLines: maxLines,
            readOnly: readOnly,
            style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF1A1919),
                fontSize: 14,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFB0B0B0), fontSize: 13),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 18, color: _coral)
                  : null,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: prefixIcon != null ? 0 : 20,
                  vertical: maxLines > 1 ? 14 : 0),
              border: InputBorder.none,
              errorStyle: const TextStyle(height: 0),
            ),
            validator: validator ??
                (required
                    ? (v) => (v == null || v.isEmpty) ? 'Required' : null
                    : null),
          ),
        ),
      ],
    );
  }
}
