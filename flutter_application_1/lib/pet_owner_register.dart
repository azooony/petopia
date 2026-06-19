import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'frame6.dart';
import 'frame8.dart';
import 'services/auth_service.dart';
import 'services/api_client.dart';

class PetOwnerRegister extends StatefulWidget {
  const PetOwnerRegister({super.key});

  @override
  State<PetOwnerRegister> createState() => _PetOwnerRegisterState();
}

class _PetOwnerRegisterState extends State<PetOwnerRegister> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _ageFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _agreedToTerms = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedGender = 'MALE';

  static const _coral = Color(0xFFFF7578);

  @override
  void initState() {
    super.initState();
    for (final n in [
      _nameFocus,
      _emailFocus,
      _phoneFocus,
      _ageFocus,
      _passwordFocus,
    ]) {
      n.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _emailController,
      _phoneController,
      _ageController,
      _passwordController,
    ]) {
      c.dispose();
    }
    for (final n in [
      _nameFocus,
      _emailFocus,
      _phoneFocus,
      _ageFocus,
      _passwordFocus,
    ]) {
      n.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to Terms and Privacy Policy',
              style: GoogleFonts.plusJakartaSans()),
          backgroundColor: _coral,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.registerPetOwner(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Frame8()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Registration failed. Check your connection.');
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
            Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
                          TextSpan(text: 'Create\n'),
                          TextSpan(text: 'Account'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fill in your details to get started',
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
                      controller: _emailController,
                      focusNode: _emailFocus,
                      hintText: 'Email',
                      errorText: 'Please enter your email',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
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

                    // Age field
                    _buildInputField(
                      controller: _ageController,
                      focusNode: _ageFocus,
                      hintText: 'Age',
                      errorText: 'Please enter your age',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      extraValidator: (value) {
                        final n = int.tryParse(value ?? '');
                        if (n == null || n < 1 || n > 120) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Gender toggle
                    _buildGenderSelector(),
                    const SizedBox(height: 14),

                    _buildPasswordField(),
                    const SizedBox(height: 24),

                    // Terms
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) =>
                                setState(() => _agreedToTerms = value ?? false),
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
                                  color: const Color(0xFF1A1919),
                                  fontSize: 12),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: _coral,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF1A1919),
                                      fontSize: 12),
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: _coral,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
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
                            text: 'Already have an account? ',
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
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text('Create Account',
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
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _genderOption('MALE', 'Male')),
            const SizedBox(width: 12),
            Expanded(child: _genderOption('FEMALE', 'Female')),
          ],
        ),
      ],
    );
  }

  Widget _genderOption(String value, String label) {
    final bool selected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF0F0) : Colors.white,
          border: Border.all(
            color: selected ? _coral : const Color(0xFFFFCCCD),
            width: selected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
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
              contentPadding: const EdgeInsets.only(
                  left: 20, right: 56, top: 16, bottom: 16),
              border: InputBorder.none,
              errorStyle: const TextStyle(height: 0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
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
