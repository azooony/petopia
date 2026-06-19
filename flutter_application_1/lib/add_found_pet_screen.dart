import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'services/lost_found_service.dart';
import 'services/api_client.dart';

class AddFoundPetScreen extends StatefulWidget {
  const AddFoundPetScreen({super.key});

  @override
  State<AddFoundPetScreen> createState() => _AddFoundPetScreenState();
}

class _AddFoundPetScreenState extends State<AddFoundPetScreen> {
  static const _coral = Color(0xFFFF7578);

  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionFocus = FocusNode();
  final _locationFocus = FocusNode();

  Uint8List? _photoBytes;
  String _photoFilename = 'pet.jpg';
  bool _isPetKept = true;
  bool _isSubmitting = false;
  bool _isAnalyzing = false;
  String _petType = 'DOG';
  String? _detectedBreed;

  @override
  void initState() {
    super.initState();
    _descriptionFocus.addListener(() => setState(() {}));
    _locationFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _descriptionFocus.dispose();
    _locationFocus.dispose();
    super.dispose();
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
      _isAnalyzing = true;
      _detectedBreed = null;
    });
    try {
      final res = await ApiClient.multipartPostBytes(
        '/pets/analyze',
        fields: {},
        bytes: bytes,
        filename: picked.name,
        fileField: 'photo',
      );
      final data = res['data'] as Map<String, dynamic>?;
      if (data != null && mounted) {
        final animal = (data['animal'] as String?)?.toUpperCase();
        final breed = data['breed'] as String?;
        setState(() {
          if (animal == 'CAT' || animal == 'DOG') _petType = animal!;
          _detectedBreed = (breed != null && breed.isNotEmpty) ? breed : null;
        });
      }
    } catch (_) {
      // AI failure is non-blocking — breed stays null
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _submit() async {
    if (_descriptionController.text.trim().isEmpty) {
      _showSnack('Please describe the pet you found.');
      return;
    }
    if (_descriptionController.text.trim().length < 10) {
      _showSnack('Description must be at least 10 characters.');
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      _showSnack('Please enter where you found the pet.');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await LostFoundService.reportFoundPet(
        species: _petType,
        description: _descriptionController.text.trim(),
        foundLocation: _locationController.text.trim(),
        isPetStillAtLocation: _isPetKept,
        breed: _detectedBreed,
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
              child: const Icon(Icons.pets_rounded, color: _coral, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Found pet reported!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _coral),
            ),
            const SizedBox(height: 10),
            Text(
              'The found pet has been added to the list. An owner may reach out to you.',
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
                  'View Found Pets',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints.expand(),
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
                'report found pet',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            bottomNavigationBar: Padding(
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
                          'Report Found Pet',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Photo picker ──────────────────────────────────────
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
                                child:
                                    Image.memory(_photoBytes!, fit: BoxFit.cover),
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
                                          color: _coral,
                                          shape: BoxShape.circle),
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

                  _sectionLabel('Pet Type'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _typeChip('DOG', 'Dog', Icons.pets_rounded)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _typeChip('CAT', 'Cat',
                              Icons.catching_pokemon_rounded)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _sectionLabel('Detected Breed'),
                  const SizedBox(height: 10),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFCCCD)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_outlined,
                            size: 18,
                            color: _isAnalyzing
                                ? Colors.grey
                                : _detectedBreed != null
                                    ? _coral
                                    : Colors.grey[400]),
                        const SizedBox(width: 10),
                        if (_isAnalyzing)
                          Row(children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5, color: _coral),
                            ),
                            const SizedBox(width: 8),
                            Text('Detecting breed…',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: const Color(0xFFB0B0B0))),
                          ])
                        else
                          Text(
                            _detectedBreed ?? (_photoBytes != null
                                ? 'Could not detect breed'
                                : 'Upload a photo to detect breed'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: _detectedBreed != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _detectedBreed != null
                                  ? const Color(0xFF1A1919)
                                  : const Color(0xFFB0B0B0),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _sectionLabel('Description'),
                  const SizedBox(height: 10),
                  _multilineField(
                    controller: _descriptionController,
                    focusNode: _descriptionFocus,
                    hint:
                        'Describe the pet (color, size, distinguishing features...)',
                  ),
                  const SizedBox(height: 20),

                  _sectionLabel('Found Location'),
                  const SizedBox(height: 10),
                  _inputField(
                    controller: _locationController,
                    focusNode: _locationFocus,
                    hint: 'e.g. Dokki, Giza',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 20),

                  _sectionLabel('Is the pet currently with you?'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _toggleOption(
                        label: 'Yes, with me',
                        icon: Icons.home_outlined,
                        selected: _isPetKept,
                        onTap: () => setState(() => _isPetKept = true),
                      ),
                      const SizedBox(width: 12),
                      _toggleOption(
                        label: 'No',
                        icon: Icons.store_outlined,
                        selected: !_isPetKept,
                        onTap: () => setState(() => _isPetKept = false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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

  Widget _multilineField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
  }) {
    final focused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
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
        maxLines: 4,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: const Color(0xFF1A1919),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: const Color(0xFFB0B0B0)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label, IconData icon) {
    final selected = _petType == value;
    return GestureDetector(
      onTap: () => setState(() => _petType = value),
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
              Icon(icon,
                  size: 15,
                  color: selected ? _coral : const Color(0xFF9E9E9E)),
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

  Widget _toggleOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFFE5E5)
                : const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _coral : const Color(0xFFE0E0E0),
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 24,
                  color: selected ? _coral : const Color(0xFF9E9E9E)),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? _coral : const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
