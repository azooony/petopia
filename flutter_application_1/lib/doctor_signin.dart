import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'frame7.dart';
import 'doctor_appointments.dart';
import 'services/auth_service.dart';
import 'services/api_client.dart';

class DoctorSignIn extends StatefulWidget {
  const DoctorSignIn({super.key});

  @override
  State<DoctorSignIn> createState() => _DoctorSignInState();
}

class _DoctorSignInState extends State<DoctorSignIn> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;

      final role = user['role'] as String;
      if (role != 'VET') {
        _showError('This login is for vets only. Please use the pet owner login.');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DoctorAppointments()),
      );
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme:
            GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 48),
                    child: Text.rich(
                      TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.2,
                        ),
                        children: const [
                          TextSpan(text: 'Welcome,\n'),
                          TextSpan(text: 'Doctor!'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildInputField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      hintText: 'Medical email',
                      errorText: 'Please enter a valid medical email',
                    ),
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildPasswordField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      hintText: 'Password',
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Color(0xFFFF7578),
                          thickness: 1,
                          indent: 24,
                          endIndent: 16,
                        ),
                      ),
                      Text('or',
                          style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFFF7578), fontSize: 12)),
                      const Expanded(
                        child: Divider(
                          color: Color(0xFFFF7578),
                          thickness: 1,
                          indent: 16,
                          endIndent: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSocialButton('assets/images/g.png', 'Google',
                            () => _handleSocialLogin('Google')),
                        _buildSocialButton('assets/images/f.png', 'Facebook',
                            () => _handleSocialLogin('Facebook')),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Frame7()),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF1A1919),
                                  fontSize: 12),
                              children: [
                                TextSpan(
                                  text: 'Register as Doctor',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFFF7578),
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Material(
                      color: _isLoading
                          ? Colors.grey[400]
                          : const Color(0xFFFF7578),
                      borderRadius: BorderRadius.circular(28),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: _isLoading ? null : _handleLogin,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28)),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Text('Sign In',
                                    style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String errorText,
  }) {
    final focused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: focused ? const Color(0xFFFFF5F5) : Colors.white,
        border: Border.all(
          color: focused ? const Color(0xFFFF7578) : const Color(0xFFFFCCCD),
          width: focused ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.left,
        style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1A1919),
            fontSize: 14,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFB0B0B0), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          border: InputBorder.none,
          errorStyle: const TextStyle(height: 0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return errorText;
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
  }) {
    final focused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: focused ? const Color(0xFFFFF5F5) : Colors.white,
        border: Border.all(
          color: focused ? const Color(0xFFFF7578) : const Color(0xFFFFCCCD),
          width: focused ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: !_isPasswordVisible,
            textAlign: TextAlign.left,
            style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF1A1919),
                fontSize: 14,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFB0B0B0), fontSize: 14),
              contentPadding: const EdgeInsets.only(left: 24, right: 56),
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
                color: focused
                    ? const Color(0xFFFF7578)
                    : const Color(0xFFB0B0B0),
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

  Widget _buildSocialButton(
      String imagePath, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFF7578)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 24, height: 24),
            const SizedBox(width: 8),
            Text(text,
                style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFF7578),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _handleSocialLogin(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$platform login coming soon...')),
    );
  }
}
