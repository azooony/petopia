import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'services/api_client.dart';
import 'services/lost_found_service.dart';

class AddLostPetScreen extends StatefulWidget {
  const AddLostPetScreen({super.key});

  @override
  State<AddLostPetScreen> createState() => _AddLostPetScreenState();
}

class _AddLostPetScreenState extends State<AddLostPetScreen> {
  static const _coral = Color(0xFFFF7578);

  final _locationController = TextEditingController();
  final _locationFocus = FocusNode();

  Uint8List? _photoBytes;
  String _photoFilename = 'pet.jpg';
  DateTime? _lastSeenDate;

  bool _isFetching = true;
  bool _isSubmitting = false;

  String _petName = '';
  String? _petId;
  String? _breed;
  String? _gender;
  int? _age;
  String _petType = 'DOG';

  @override
  void initState() {
    super.initState();
    _locationFocus.addListener(() => setState(() {}));
    _fetchPetData();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  Future<void> _fetchPetData() async {
    try {
      final res = await ApiClient.get('/users/me');
      final data = res['data'] as Map<String, dynamic>? ?? res;
      final pet = data['pets'] as Map<String, dynamic>?;
      if (mounted) {
        setState(() {
          if (pet != null) {
            _petId   = pet['id'] as String?;
            _petName = (pet['name'] as String?) ?? '';
            _breed   = pet['breed'] as String?;
            _gender  = pet['gender'] as String?;
            _age     = (pet['age'] as num?)?.toInt();
            _petType = ((pet['petType'] ?? pet['type']) as String?)
                    ?.toUpperCase() ??
                'DOG';
          }
          _isFetching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _photoBytes = bytes;
      _photoFilename = picked.name.isNotEmpty ? picked.name : 'pet.jpg';
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _coral),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _lastSeenDate = picked);
  }

  String _buildDescription() {
    final parts = <String>['Lost $_petType'.toLowerCase()];
    if (_petName.isNotEmpty) parts.add('named $_petName');
    if (_breed != null && _breed!.isNotEmpty) parts.add('($_breed)');
    final loc = _locationController.text.trim();
    if (loc.isNotEmpty) parts.add('last seen at $loc');
    return parts.join(' ');
  }

  Future<void> _submit() async {
    if (_petName.isEmpty) {
      _showSnack('No pet found. Please add a pet from your profile first.');
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      _showSnack('Please enter the last seen location.');
      return;
    }
    if (_lastSeenDate == null) {
      _showSnack('Please select the last seen date.');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await LostFoundService.reportLostPet(
        species: _petType,
        description: _buildDescription(),
        lastSeenLocation: _locationController.text.trim(),
        lastSeenDate: _lastSeenDate!.toIso8601String(),
        petId: _petId,
        name: _petName,
        breed: _breed,
        gender: _gender,
        imageBytes: _photoBytes,
        imageFilename: _photoBytes != null ? _photoFilename : null,
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
        await _showSuccessSheet();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSnack(e.toString().contains(':')
            ? e.toString().split(':').last.trim()
            : 'Failed to report pet. Please try again.');
      }
    }
  }

  Future<void> _showSuccessSheet() {
    return showModalBottomSheet(
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
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 28),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F0), shape: BoxShape.circle),
              child: const Icon(Icons.location_on_rounded,
                  color: _coral, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Pet reported as lost!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _coral),
            ),
            const SizedBox(height: 10),
            Text(
              'Your pet has been added to the lost list. We hope you find them soon.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF9E9E9E),
                  height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                  elevation: 0,
                ),
                child: Text(
                  'View Lost Pets',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.plusJakartaSans()),
      backgroundColor: _coral,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

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
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 80,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'report lost pet',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            bottomNavigationBar: _isFetching || _petName.isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _coral,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Report Lost Pet',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
            body: _isFetching
                ? const Center(
                    child: CircularProgressIndicator(color: _coral))
                : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    if (_petName.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.pets_rounded,
                size: 64, color: Color(0xFFFFB5B5)),
            const SizedBox(height: 16),
            Text(
              'No pet registered',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please add your pet from your profile before reporting it as lost.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF9E9E9E),
              ),
              textAlign: TextAlign.center,
            ),
          ]),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo picker ─────────────────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _photoBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.memory(_photoBytes!, fit: BoxFit.cover),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.image_outlined,
                              size: 30, color: Colors.grey[400]),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                  color: _coral, shape: BoxShape.circle),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 12),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Text(
                              'pet',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Pet info (read-only, auto-filled from profile) ────────────
          _sectionLabel('Your Pet'),
          const SizedBox(height: 10),
          _infoTile(Icons.pets_rounded, 'Name', _petName),
          if (_breed != null)
            _infoTile(Icons.info_outline_rounded, 'Breed', _breed!),
          if (_gender != null)
            _infoTile(
              (_gender == 'Male' || _gender == 'MALE')
                  ? Icons.male_rounded
                  : Icons.female_rounded,
              'Gender',
              _gender!,
            ),
          if (_age != null)
            _infoTile(Icons.cake_outlined, 'Age', '$_age years'),
          const SizedBox(height: 24),

          // ── Last seen location ────────────────────────────────────────
          _sectionLabel('Last Seen Location'),
          const SizedBox(height: 10),
          _inputField(
            controller: _locationController,
            focusNode: _locationFocus,
            hint: 'e.g. Maadi, Cairo',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 20),

          // ── Last seen date ────────────────────────────────────────────
          _sectionLabel('Last Seen Date'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickDate,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 50,
              decoration: BoxDecoration(
                color: _lastSeenDate != null
                    ? const Color(0xFFFFF5F5)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _lastSeenDate != null
                      ? _coral
                      : const Color(0xFFFFCCCD),
                  width: _lastSeenDate != null ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: _lastSeenDate != null
                        ? _coral
                        : const Color(0xFF9E9E9E),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _lastSeenDate != null
                        ? _fmtDate(_lastSeenDate!)
                        : 'Select date',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: _lastSeenDate != null
                          ? const Color(0xFF1A1919)
                          : const Color(0xFFB0B0B0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      );

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9E9E9E)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF9E9E9E),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
  }) {
    final focused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 50,
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
        focusNode: focusNode,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: const Color(0xFF1A1919),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: const Color(0xFFB0B0B0)),
          prefixIcon: Icon(icon, size: 18, color: _coral),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 46, minHeight: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
