import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'services/sitting_service.dart';
import 'services/api_client.dart';

class PetSitterRegister extends StatefulWidget {
  const PetSitterRegister({super.key});

  @override
  State<PetSitterRegister> createState() => _PetSitterRegisterState();
}

class _PetSitterRegisterState extends State<PetSitterRegister> {
  Uint8List? _placePhotoBytes;
  Uint8List? _idPhotoBytes;
  bool _isLoading = false;

  static const _coral = Color(0xFFFF7578);

  Future<void> _pickPhoto({required bool isPlace}) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        if (isPlace) {
          _placePhotoBytes = bytes;
        } else {
          _idPhotoBytes = bytes;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    final placePhotoBytes = _placePhotoBytes;
    final idPhotoBytes = _idPhotoBytes;

    if (placePhotoBytes == null) {
      _showError('Please upload a photo of where the pet will stay.');
      return;
    }
    if (idPhotoBytes == null) {
      _showError('Please upload a photo of your national ID.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SittingService.registerSitter(
        nationalIdBytes:     idPhotoBytes,
        nationalIdFilename:  'national_id.jpg',
        venuePhotoBytes:     placePhotoBytes,
        venuePhotoFilename:  'venue_photo.jpg',
      );
      if (!mounted) return;
      _showPendingDialog();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans()),
        backgroundColor: _coral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showPendingDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(28, 28, 28, MediaQuery.of(context).padding.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: Color(0xFFFFF0F0), shape: BoxShape.circle),
              child: const Icon(Icons.hourglass_top_rounded, color: _coral, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Request Submitted!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              'Your photos are under review. You will be able to start pet sitting once an admin approves your request.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF6B6B6B), height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: Text('Got it', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600)),
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
        textTheme: GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E8E8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1A1919)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Become a\nPet Sitter',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload the required photos for admin approval before you can start accepting pets.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF9E9E9E),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Photo of where the pet will stay',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1919),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildUploadBox(
                          bytes: _placePhotoBytes,
                          icon: Icons.home_outlined,
                          label: 'Upload Place Photo',
                          hint: 'Tap to select from gallery',
                          onTap: () => _pickPhoto(isPlace: true),
                          onRemove: () => setState(() => _placePhotoBytes = null),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'National ID photo',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1919),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildUploadBox(
                          bytes: _idPhotoBytes,
                          icon: Icons.badge_outlined,
                          label: 'Upload National ID',
                          hint: 'Tap to select from gallery',
                          onTap: () => _pickPhoto(isPlace: false),
                          onRemove: () => setState(() => _idPhotoBytes = null),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _coral,
                      disabledBackgroundColor: Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            'Submit for Approval',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildUploadBox({
    required Uint8List? bytes,
    required IconData icon,
    required String label,
    required String hint,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 130,
        decoration: BoxDecoration(
          color: bytes != null ? Colors.transparent : const Color(0xFFFFF5F5),
          border: Border.all(
            color: bytes != null ? _coral : const Color(0xFFFFCCCD),
            width: bytes != null ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: bytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(bytes, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 16, color: _coral),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: _coral, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _coral,
                    ),
                  ),
                  Text(
                    hint,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFFB0B0B0)),
                  ),
                ],
              ),
      ),
    );
  }
}
