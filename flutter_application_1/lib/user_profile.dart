import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'services/api_client.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _formKey = GlobalKey<FormState>();

  final _ownerNameController = TextEditingController();
  final _addressController   = TextEditingController();
  final _petNameController   = TextEditingController();
  final _breedController     = TextEditingController();
  final _ageController       = TextEditingController();
  final _aboutController     = TextEditingController();

  final _ownerNameFocus = FocusNode();
  final _addressFocus   = FocusNode();
  final _petNameFocus   = FocusNode();
  final _breedFocus     = FocusNode();
  final _ageFocus       = FocusNode();
  final _aboutFocus     = FocusNode();

  Uint8List? _avatarBytes;
  String? _existingAvatarUrl;

  Uint8List? _petPhotoBytes;
  String? _existingPetImageUrl;
  String _gender      = 'Male';
  String _petType     = 'DOG';
  bool _isLoading    = false;
  bool _initialLoad  = true;
  bool _isAnalyzing  = false;
  String? _petId;

  static const _coral = Color(0xFFFF7578);

  @override
  void initState() {
    super.initState();
    for (final n in [
      _ownerNameFocus, _addressFocus, _petNameFocus, _breedFocus,
      _ageFocus, _aboutFocus,
    ]) {
      n.addListener(() => setState(() {}));
    }
    _loadProfile();
  }

  @override
  void dispose() {
    for (final c in [
      _ownerNameController, _addressController, _petNameController,
      _breedController, _ageController, _aboutController,
    ]) {
      c.dispose();
    }
    for (final n in [
      _ownerNameFocus, _addressFocus, _petNameFocus, _breedFocus,
      _ageFocus, _aboutFocus,
    ]) {
      n.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _initialLoad = true);
    try {
      final results = await Future.wait([
        ApiClient.get('/users/me'),
        ApiClient.get('/pets'),
      ]);

      final user    = results[0]['data'] as Map<String, dynamic>;
      final profile = user['profile'] as Map<String, dynamic>? ?? {};

      _ownerNameController.text = user['fullName'] as String? ?? '';
      _addressController.text   = profile['address'] as String? ?? '';

      final avatarRaw = user['profilePicture'] as String?;
      if (avatarRaw != null && avatarRaw.isNotEmpty) {
        _existingAvatarUrl = avatarRaw.startsWith('http')
            ? avatarRaw
            : '${ApiClient.baseUrl}$avatarRaw';
      }

      final gender = user['gender'] as String?;
      if (gender == 'FEMALE') _gender = 'Female';

      final petsData = results[1]['data'];
      final List<dynamic> pets = petsData is List
          ? petsData
          : (petsData as Map<String, dynamic>?)?['pets'] as List<dynamic>? ?? [];

      if (pets.isNotEmpty) {
        final pet = pets.first as Map<String, dynamic>;
        _petId = pet['id'] as String?;
        _petNameController.text  = pet['name'] as String? ?? '';
        _breedController.text    = pet['breed'] as String? ?? '';
        _ageController.text      = (pet['age'] as num?)?.toString() ?? '';
        _aboutController.text    = pet['description'] as String? ?? '';
        final petGender = pet['gender'] as String?;
        if (petGender == 'FEMALE') _gender = 'Female';

        final pt = (pet['petType'] as String?)?.toUpperCase();
        if (pt == 'CAT') _petType = 'CAT';
        if (pt == 'DOG') _petType = 'DOG';

        // Load existing pet photo URL directly from the pet record
        final rawUrl = pet['photo'] as String?;
        if (rawUrl != null && rawUrl.isNotEmpty) {
          _existingPetImageUrl = rawUrl.startsWith('http')
              ? rawUrl
              : '${ApiClient.baseUrl}$rawUrl';
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _initialLoad = false);
    }
  }

  Future<void> _pickAvatar() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _avatarBytes = bytes);
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
      debugPrint('[UserProfile] analyze error: $e');
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ApiClient.put('/users/me', {
        'fullName': _ownerNameController.text.trim(),
        'address':  _addressController.text.trim(),
        'gender':   _gender == 'Male' ? 'MALE' : 'FEMALE',
      });

      final age = int.tryParse(_ageController.text.trim()) ?? 0;
      final petPayload = {
        'name':        _petNameController.text.trim(),
        'breed':       _breedController.text.trim(),
        'age':         age,
        'gender':      _gender == 'Male' ? 'MALE' : 'FEMALE',
        'petType':     _petType,
        'description': _aboutController.text.trim(),
      };

      if (_petId != null) {
        final res = await ApiClient.patch('/pets/$_petId', petPayload);
        _petId = (res['data'] as Map<String, dynamic>?)?['id'] as String? ?? _petId;
      } else {
        final res = await ApiClient.post('/pets', petPayload);
        _petId = (res['data'] as Map<String, dynamic>?)?['id'] as String?;
      }

      // Upload user avatar if a new one was picked
      if (_avatarBytes != null) {
        final res = await ApiClient.multipartPostBytes(
          '/users/me/avatar',
          fields: {},
          bytes: _avatarBytes!,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          fileField: 'avatar',
        );
        final url = (res['data'] as Map<String, dynamic>?)?['profilePicture'] as String?;
        if (url != null && mounted) {
          setState(() { _existingAvatarUrl = url; _avatarBytes = null; });
        }
      }

      // Upload pet photo — blocking so any failure shows a clear error
      if (_petPhotoBytes != null && _petId != null) {
        final res = await ApiClient.multipartPostBytes(
          '/pets/$_petId/photo',
          fields: {},
          bytes: _petPhotoBytes!,
          filename: 'pet_${DateTime.now().millisecondsSinceEpoch}.jpg',
          fileField: 'photo',
        );
        final url = (res['data'] as Map<String, dynamic>?)?['photoUrl'] as String?;
        if (url != null && mounted) {
          setState(() { _existingPetImageUrl = url; _petPhotoBytes = null; });
        }
      }

      if (_petId != null) {
        await _syncExistingMatchProfile();
      }

      if (!mounted) return;
      _showAddedDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 12)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 8),
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _syncExistingMatchProfile() async {
    final petId = _petId;
    if (petId == null) return;

    final profileRes = await ApiClient.get('/matching/profile/$petId');
    final profileData = profileRes['data'] as Map<String, dynamic>?;
    final profile = profileData?['profile'] as Map<String, dynamic>?;
    if (profile == null) return;

    await ApiClient.post('/matching/profile', {
      'petId': petId,
      'description': _aboutController.text.trim(),
      'address': _addressController.text.trim(),
      'preferredBreed': _breedController.text.trim(),
    });
  }

  void _showAddedDialog() {
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
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets_rounded, color: _coral, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Profile Saved!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _coral,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your profile and pet details have been saved. Your vet will be able to see your pet\'s information when reviewing appointments.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF9E9E9E),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Done',
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
        body: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(46),
              ),
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
                                  width: 36,
                                  height: 36,
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
                                  Text(
                                    'Edit profile',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1919),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Keep your personal details private. Information you add here is visible to anyone who can view your profile.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: const Color(0xFF9E9E9E),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Photos
                                  Text('photos', style: _labelStyle()),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: _pickAvatar,
                                        child: _buildPhotoBox(
                                          bytes: _avatarBytes,
                                          networkUrl: _existingAvatarUrl,
                                          size: 100,
                                          label: 'you',
                                          icon: Icons.person_outline,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: _pickPhoto,
                                        child: _buildPhotoBox(
                                          bytes: _petPhotoBytes,
                                          networkUrl: _existingPetImageUrl,
                                          size: 100,
                                          label: 'pet',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),

                                  _buildLabeledField(
                                    label: 'owner name',
                                    controller: _ownerNameController,
                                    focusNode: _ownerNameFocus,
                                    errorText: 'Required',
                                  ),
                                  const SizedBox(height: 16),

                                  _buildLabeledField(
                                    label: 'address / city',
                                    controller: _addressController,
                                    focusNode: _addressFocus,
                                    errorText: 'Required',
                                  ),
                                  const SizedBox(height: 16),

                                  _buildLabeledField(
                                    label: 'pet name',
                                    controller: _petNameController,
                                    focusNode: _petNameFocus,
                                    errorText: 'Required',
                                  ),
                                  const SizedBox(height: 16),

                                  Stack(
                                    children: [
                                      _buildLabeledField(
                                        label: 'pet breed',
                                        controller: _breedController,
                                        focusNode: _breedFocus,
                                        errorText: 'Required',
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

                                  // ── Pet type ──────────────────────────────
                                  Text('pet type', style: _labelStyle()),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(child: _petTypeChip('DOG', 'Dog')),
                                      const SizedBox(width: 10),
                                      Expanded(child: _petTypeChip('CAT', 'Cat')),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildLabeledField(
                                          label: 'age',
                                          controller: _ageController,
                                          focusNode: _ageFocus,
                                          errorText: 'Required',
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('gender', style: _labelStyle()),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Expanded(child: _genderChip('Male')),
                                                const SizedBox(width: 8),
                                                Expanded(child: _genderChip('Female')),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  _buildLabeledField(
                                    label: 'about your pet',
                                    controller: _aboutController,
                                    focusNode: _aboutFocus,
                                    errorText: 'Required',
                                    maxLines: 4,
                                  ),
                                  const SizedBox(height: 32),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _coral,
                                        disabledBackgroundColor: Colors.grey[400],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(28),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white, strokeWidth: 2),
                                            )
                                          : Text(
                                              'Confirm',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
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

  Widget _buildPhotoBox({
    required Uint8List? bytes,
    String? networkUrl,
    required double size,
    required String label,
    IconData icon = Icons.image_outlined,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: bytes != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.memory(bytes, fit: BoxFit.cover),
            )
          : networkUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.network(
                    networkUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(icon, color: const Color(0xFFFF7578), size: 36),
                  ),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, size: 30, color: Colors.grey[400]),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                            color: _coral, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 12),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _petTypeChip(String value, String label) {
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
          child: Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? _coral : const Color(0xFF9E9E9E))),
        ),
      ),
    );
  }

  Widget _genderChip(String label) {
    final selected = _gender == label;
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
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
                label == 'Male' ? Icons.male_rounded : Icons.female_rounded,
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
        color: const Color(0xFF9E9E9E),
      );

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String errorText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    final focused = focusNode.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: focused ? const Color(0xFFFFF5F5) : Colors.white,
            border: Border.all(
              color: focused ? _coral : const Color(0xFFFFCCCD),
              width: focused ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF1A1919),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: maxLines > 1 ? 14 : 0,
              ),
              border: InputBorder.none,
              errorStyle: const TextStyle(height: 0),
            ),
            validator: (value) {
              if (required && (value == null || value.isEmpty)) return errorText;
              return null;
            },
          ),
        ),
      ],
    );
  }
}
