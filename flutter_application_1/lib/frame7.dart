import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'frame6.dart';
import 'services/auth_service.dart';
import 'services/api_client.dart';

class Frame7 extends StatefulWidget {
  const Frame7({super.key});

  @override
  State<Frame7> createState() => _Frame7State();
}

class _Frame7State extends State<Frame7> {
  final _formKey = GlobalKey<FormState>();
  final _nameController     = TextEditingController();
  final _phoneController    = TextEditingController();
  final _emailController    = TextEditingController();
  final _clinicNameController     = TextEditingController();
  final _clinicLocationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController      = TextEditingController();

  final _nameFocus     = FocusNode();
  final _phoneFocus    = FocusNode();
  final _emailFocus    = FocusNode();
  final _clinicNameFocus     = FocusNode();
  final _clinicLocationFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _ageFocus      = FocusNode();

  bool _agreedToTerms      = false;
  bool _isPasswordVisible  = false;
  bool _isLoading          = false;
  String _selectedGender   = 'MALE';

  Uint8List? _certificateBytes;
  String    _certificateFilename = 'certificate.jpg';

  static const _coral = Color(0xFFFF7578);

  @override
  void initState() {
    super.initState();
    for (final n in [
      _nameFocus, _phoneFocus, _emailFocus,
      _clinicNameFocus, _clinicLocationFocus,
      _passwordFocus, _ageFocus,
    ]) {
      n.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameController, _phoneController, _emailController,
      _clinicNameController, _clinicLocationController,
      _passwordController, _ageController,
    ]) {
      c.dispose();
    }
    for (final n in [
      _nameFocus, _phoneFocus, _emailFocus,
      _clinicNameFocus, _clinicLocationFocus,
      _passwordFocus, _ageFocus,
    ]) {
      n.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCertificate() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _certificateBytes    = bytes;
        _certificateFilename = file.name;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_certificateBytes == null) {
      _showSnack('Please upload your certificate', isError: false);
      return;
    }
    if (!_agreedToTerms) {
      _showSnack('Please agree to Terms and Privacy Policy', isError: false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.registerVet(
        fullName:              _nameController.text.trim(),
        email:                 _emailController.text.trim(),
        phone:                 _phoneController.text.trim(),
        password:              _passwordController.text,
        age:                   int.parse(_ageController.text.trim()),
        gender:                _selectedGender,
        clinicName:            _clinicNameController.text.trim(),
        clinicAddress:         _clinicLocationController.text.trim(),
        certificateBytes:      _certificateBytes!,
        certificateFilename:   _certificateFilename,
      );
      if (!mounted) return;
      _showPendingDialog();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Registration failed. Check your connection.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.plusJakartaSans()),
      backgroundColor: isError ? Colors.redAccent : _coral,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
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
              width: 72, height: 72,
              decoration: const BoxDecoration(color: Color(0xFFFFF0F0), shape: BoxShape.circle),
              child: const Icon(Icons.hourglass_top_rounded, color: _coral, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Registration Submitted!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              'Your certificate is currently under review. You will be able to access your account once an admin approves your registration.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: const Color(0xFF6B6B6B), height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Frame6()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: Text('Got it',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, fontWeight: FontWeight.w600)),
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
        backgroundColor: const Color(0xFF1C2632),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              width: 360,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.2,
                        ),
                        children: const [
                          TextSpan(text: 'Doctor\n'),
                          TextSpan(text: 'Registration'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fill in your details to create an account',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: const Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(height: 32),

                    _buildInputField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      hintText: 'Full Name',
                      errorText: 'Please enter your full name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),

                    _buildInputField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      hintText: 'Phone Number',
                      errorText: 'Please enter your phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),

                    _buildEmailField(),
                    const SizedBox(height: 14),

                    _buildInputField(
                      controller: _clinicNameController,
                      focusNode: _clinicNameFocus,
                      hintText: 'Clinic Name',
                      errorText: 'Please enter your clinic name',
                      icon: Icons.local_hospital_outlined,
                    ),
                    const SizedBox(height: 14),

                    _buildInputField(
                      controller: _clinicLocationController,
                      focusNode: _clinicLocationFocus,
                      hintText: 'Clinic Location',
                      errorText: 'Please enter your clinic location',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 14),

                    // Age + Gender side by side
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _ageController,
                            focusNode: _ageFocus,
                            hintText: 'Age',
                            errorText: 'Required',
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            extraValidator: (v) {
                              final n = int.tryParse(v ?? '');
                              if (n == null || n < 18 || n > 100) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _buildGenderSelector()),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildPasswordField(),
                    const SizedBox(height: 24),

                    // Certificate upload
                    Text(
                      'Medical Certificate',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1919)),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickCertificate,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 120,
                        decoration: BoxDecoration(
                          color: _certificateBytes != null
                              ? Colors.transparent
                              : const Color(0xFFFFF5F5),
                          border: Border.all(
                            color: _certificateBytes != null
                                ? _coral
                                : const Color(0xFFFFCCCD),
                            width: _certificateBytes != null ? 1.5 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _certificateBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.memory(_certificateBytes!, fit: BoxFit.cover),
                                    Positioned(
                                      top: 8, right: 8,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _certificateBytes = null),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle),
                                          child: const Icon(Icons.close,
                                              size: 16, color: _coral),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.upload_file_outlined,
                                      color: _coral, size: 32),
                                  const SizedBox(height: 8),
                                  Text('Upload Certificate',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _coral)),
                                  Text('Tap to select from gallery',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: const Color(0xFFB0B0B0))),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Terms
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24, height: 24,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (v) =>
                                setState(() => _agreedToTerms = v ?? false),
                            activeColor: _coral,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'I Agree to the ',
                              style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF1A1919), fontSize: 12),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: _coral,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                  recognizer: TapGestureRecognizer()..onTap = () {},
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF1A1919), fontSize: 12),
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: _coral,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                  recognizer: TapGestureRecognizer()..onTap = () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Frame6()),
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: 'Have an account? ',
                            style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF1A1919), fontSize: 12),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: GoogleFonts.plusJakartaSans(
                                    color: _coral,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
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
                            : Text('Register',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9E9E9E))),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _genderOption('MALE', 'Male')),
            const SizedBox(width: 8),
            Expanded(child: _genderOption('FEMALE', 'Female')),
          ],
        ),
      ],
    );
  }

  Widget _genderOption(String value, String label) {
    final selected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
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
                  fontWeight: FontWeight.w500,
                  color: selected ? _coral : const Color(0xFFB0B0B0))),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String errorText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? extraValidator,
  }) {
    final focused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
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
        style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1A1919),
            fontSize: 14,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFB0B0B0), fontSize: 14),
          prefixIcon: icon != null
              ? Icon(icon,
                  color: focused ? _coral : const Color(0xFFB0B0B0), size: 20)
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          errorStyle: const TextStyle(height: 0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return errorText;
          return extraValidator?.call(value);
        },
      ),
    );
  }

  Widget _buildEmailField() {
    final focused = _emailFocus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: focused ? const Color(0xFFFFF5F5) : Colors.white,
        border: Border.all(
          color: focused ? _coral : const Color(0xFFFFCCCD),
          width: focused ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _emailController,
        focusNode: _emailFocus,
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1A1919),
            fontSize: 14,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Email Address',
          hintStyle: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFB0B0B0), fontSize: 14),
          prefixIcon: Icon(Icons.email_outlined,
              color: focused ? _coral : const Color(0xFFB0B0B0), size: 20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          errorStyle: const TextStyle(height: 0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter your email';
          if (!value.contains('@')) return 'Enter a valid email';
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    final focused = _passwordFocus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: focused ? const Color(0xFFFFF5F5) : Colors.white,
        border: Border.all(
          color: focused ? _coral : const Color(0xFFFFCCCD),
          width: focused ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: !_isPasswordVisible,
            style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF1A1919),
                fontSize: 14,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFB0B0B0), fontSize: 14),
              prefixIcon: Icon(Icons.lock_outline,
                  color: focused ? _coral : const Color(0xFFB0B0B0), size: 20),
              contentPadding:
                  const EdgeInsets.only(left: 20, right: 56, top: 16, bottom: 16),
              border: InputBorder.none,
              errorStyle: const TextStyle(height: 0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 6) return 'Min 6 characters';
              return null;
            },
          ),
          Positioned(
            right: 12,
            child: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: focused ? _coral : const Color(0xFFB0B0B0),
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ],
      ),
    );
  }
}
