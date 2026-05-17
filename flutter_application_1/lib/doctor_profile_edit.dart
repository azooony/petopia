import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'services/api_client.dart';

class DoctorProfileEdit extends StatefulWidget {
  const DoctorProfileEdit({super.key});

  @override
  State<DoctorProfileEdit> createState() => _DoctorProfileEditState();
}

class _DoctorProfileEditState extends State<DoctorProfileEdit> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _surnameController   = TextEditingController();
  final _emailController     = TextEditingController();
  final _phoneController     = TextEditingController();
  final _clinicController    = TextEditingController();
  final _specController      = TextEditingController();
  final _feesController      = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _surnameFocus   = FocusNode();
  final _emailFocus     = FocusNode();
  final _phoneFocus     = FocusNode();
  final _clinicFocus    = FocusNode();
  final _specFocus      = FocusNode();
  final _feesFocus      = FocusNode();

  Uint8List? _photoBytes;
  String? _existingPhotoUrl;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  bool _initialLoad = true;
  bool _isLoading   = false;
  String? _saveError;

  static const _coral = Color(0xFFFF7578);

  @override
  void initState() {
    super.initState();
    for (final n in [_firstNameFocus, _surnameFocus, _emailFocus, _phoneFocus, _clinicFocus, _specFocus, _feesFocus]) {
      n.addListener(() => setState(() {}));
    }
    _loadProfile();
  }

  @override
  void dispose() {
    for (final c in [_firstNameController, _surnameController, _emailController, _phoneController, _clinicController, _specController, _feesController]) {
      c.dispose();
    }
    for (final n in [_firstNameFocus, _surnameFocus, _emailFocus, _phoneFocus, _clinicFocus, _specFocus, _feesFocus]) {
      n.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _initialLoad = true);
    try {
      final res     = await ApiClient.get('/vets/profile');
      final profile = res['data'] as Map<String, dynamic>;
      final clinic  = profile['clinic']  as Map<String, dynamic>? ?? {};
      final user    = profile['user']    as Map<String, dynamic>? ?? {};

      _firstNameController.text = profile['firstName'] as String? ?? '';
      _surnameController.text   = profile['surname']   as String? ?? '';
      _emailController.text     = user['email']        as String? ?? '';
      _phoneController.text     = profile['phone']     as String? ?? '';
      _clinicController.text    = clinic['address']    as String? ?? '';
      _specController.text      = profile['specialization'] as String? ?? '';

      final price = profile['appointmentPrice'];
      if (price != null) {
        _feesController.text = (price as num).toStringAsFixed(0);
      }

      _fromTime = _parseHHmm(profile['startTime'] as String?);
      _toTime   = _parseHHmm(profile['endTime']   as String?);

      final photo = profile['photo'] as String?;
      if (photo != null && photo.isNotEmpty) {
        _existingPhotoUrl = photo.startsWith('http')
            ? photo
            : '${ApiClient.baseUrl}$photo';
      }
    } catch (_) {
      // Silently continue — user can fill in manually
    } finally {
      if (mounted) setState(() => _initialLoad = false);
    }
  }

  TimeOfDay? _parseHHmm(String? value) {
    if (value == null || !value.contains(':')) return null;
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _toHHmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => _photoBytes = bytes);
    }
  }

  Future<void> _pickTime({required bool isFrom}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom
          ? (_fromTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_toTime   ?? const TimeOfDay(hour: 17, minute: 0)),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _coral),
          dialogTheme: const DialogThemeData(constraints: BoxConstraints(maxWidth: 320)),
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        ),
      ),
    );
    if (picked != null) setState(() => isFrom ? _fromTime = picked : _toTime = picked);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _saveError = null; });
    try {
      final payload = <String, dynamic>{};
      if (_firstNameController.text.trim().isNotEmpty) {
        payload['firstName'] = _firstNameController.text.trim();
      }
      if (_surnameController.text.trim().isNotEmpty) {
        payload['surname'] = _surnameController.text.trim();
      }
      if (_phoneController.text.trim().isNotEmpty) {
        payload['phone'] = _phoneController.text.trim();
      }
      if (_clinicController.text.trim().isNotEmpty) {
        payload['clinicAddress'] = _clinicController.text.trim();
      }
      if (_specController.text.trim().isNotEmpty) {
        payload['specialization'] = _specController.text.trim();
      }
      if (_feesController.text.trim().isNotEmpty) {
        payload['appointmentPrice'] = double.tryParse(_feesController.text.trim()) ?? 0;
      }
      if (_fromTime != null) { payload['startTime'] = _toHHmm(_fromTime!); }
      if (_toTime   != null) { payload['endTime']   = _toHHmm(_toTime!); }

      await ApiClient.patch('/vets/profile', payload);

      // Update email on the user record if provided
      final email = _emailController.text.trim();
      if (email.isNotEmpty) {
        await ApiClient.put('/users/me', {'email': email});
      }

      // Upload new profile photo if one was picked — failure is non-blocking
      if (_photoBytes != null) {
        try {
          final res = await ApiClient.multipartPostBytes(
            '/vets/profile/photo',
            fields: {},
            bytes: _photoBytes!,
            filename: 'vet_${DateTime.now().millisecondsSinceEpoch}.jpg',
            fileField: 'photo',
          );
          final url = (res['data'] as Map<String, dynamic>?)?['photoUrl'] as String?;
          if (url != null && mounted) {
            setState(() { _existingPhotoUrl = url; _photoBytes = null; });
          }
        } catch (_) {
          // Photo upload failed — show warning but don't block success
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Profile saved, but photo upload failed.',
                  style: GoogleFonts.plusJakartaSans()),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          }
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile saved!', style: GoogleFonts.plusJakartaSans()),
        backgroundColor: _coral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) setState(() { _saveError = e.message; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _saveError = 'Failed to save. Check your connection.'; _isLoading = false; });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
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
              child: _initialLoad
                  ? const Center(child: CircularProgressIndicator(color: _coral))
                  : Column(
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
                                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1A1919)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Edit profile',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700, color: const Color(0xFF1A1919))),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Keep your personal details private. Information you add here is visible to anyone who can view your profile.',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF9E9E9E), height: 1.5),
                                  ),
                                  const SizedBox(height: 24),

                                  // Photo
                                  Text('photo', style: _labelStyle()),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: _pickPhoto,
                                    child: Container(
                                      width: 90, height: 90,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E0E0),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: _photoBytes != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Image.memory(_photoBytes!, fit: BoxFit.cover),
                                            )
                                          : _existingPhotoUrl != null
                                              ? Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(16),
                                                      child: Image.network(
                                                        _existingPhotoUrl!,
                                                        width: 90, height: 90,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, size: 40, color: Colors.grey[400]),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 6, right: 6,
                                                      child: Container(
                                                        width: 22, height: 22,
                                                        decoration: const BoxDecoration(color: _coral, shape: BoxShape.circle),
                                                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 13),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(Icons.person_rounded, size: 40, color: Colors.grey[400]),
                                                Positioned(
                                                  bottom: 8, right: 8,
                                                  child: Container(
                                                    width: 22, height: 22,
                                                    decoration: const BoxDecoration(color: _coral, shape: BoxShape.circle),
                                                    child: const Icon(Icons.add, color: Colors.white, size: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // First name + Surname
                                  Row(
                                    children: [
                                      Expanded(child: _buildLabeledField(label: 'first name', controller: _firstNameController, focusNode: _firstNameFocus)),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildLabeledField(label: 'surname', controller: _surnameController, focusNode: _surnameFocus)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  _buildLabeledField(label: 'email', controller: _emailController, focusNode: _emailFocus, keyboardType: TextInputType.emailAddress),
                                  const SizedBox(height: 16),

                                  _buildLabeledField(label: 'phone number', controller: _phoneController, focusNode: _phoneFocus, keyboardType: TextInputType.phone),
                                  const SizedBox(height: 16),

                                  _buildLabeledField(label: 'clinic address', controller: _clinicController, focusNode: _clinicFocus),
                                  const SizedBox(height: 16),

                                  _buildLabeledField(label: 'specialization', controller: _specController, focusNode: _specFocus),
                                  const SizedBox(height: 16),

                                  _buildLabeledField(label: 'consultation fees (EGP)', controller: _feesController, focusNode: _feesFocus, keyboardType: TextInputType.number),
                                  const SizedBox(height: 24),

                                  // Available hours
                                  Text('available hours', style: _labelStyle()),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(child: _buildTimePicker(label: 'from', isFrom: true)),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildTimePicker(label: 'to', isFrom: false)),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  if (_saveError != null) ...[
                                    Text(_saveError!, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.redAccent)),
                                    const SizedBox(height: 12),
                                  ],

                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _coral,
                                        disabledBackgroundColor: Colors.grey[400],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Text('Save', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
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

  TextStyle _labelStyle() => GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF9E9E9E));

  Widget _buildTimePicker({required String label, required bool isFrom}) {
    final time = isFrom ? _fromTime : _toTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickTime(isFrom: isFrom),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: time != null ? const Color(0xFFFFF5F5) : Colors.white,
              border: Border.all(color: time != null ? _coral : const Color(0xFFFFCCCD), width: time != null ? 1.5 : 1.0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: time != null ? _coral : const Color(0xFFB0B0B0)),
                const SizedBox(width: 8),
                Text(
                  time != null ? _formatTime(time) : '--:-- --',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: time != null ? const Color(0xFF1A1919) : const Color(0xFFB0B0B0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final focused = focusNode.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: focused ? const Color(0xFFFFF5F5) : Colors.white,
            border: Border.all(color: focused ? _coral : const Color(0xFFFFCCCD), width: focused ? 1.5 : 1.0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF1A1919), fontSize: 14, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              border: InputBorder.none,
              errorStyle: TextStyle(height: 0),
            ),
          ),
        ),
      ],
    );
  }
}
