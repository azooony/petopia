import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_dashboard.dart';
import 'services/auth_service.dart';
import 'services/api_client.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _obscure = true;
  bool _isLoading = false;

  static const _coral = Color(0xFFFF7578);

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.adminLogin(
        email: _emailController.text.trim(),
        password: _passController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
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
    return Scaffold(
      backgroundColor: const Color(0xFF1C2632),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 32),

                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.lock_outline_rounded, color: _coral, size: 26),
                      ),
                      const SizedBox(height: 20),

                      Text('Admin Panel',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 28, fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1919))),
                      const SizedBox(height: 6),
                      Text('Restricted access only.',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, color: const Color(0xFF9E9E9E))),
                      const SizedBox(height: 36),

                      _label('Email'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        hint: 'admin@petopia.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      _label('Password'),
                      const SizedBox(height: 8),
                      _passwordField(),
                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
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
                              : Text('Sign In',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: const Color(0xFF9E9E9E), letterSpacing: 0.4));

  Widget _inputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final focused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
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
        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF1A1919), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFFB0B0B0), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          errorStyle: const TextStyle(height: 0),
        ),
        validator: (v) => (v == null || v.isEmpty) ? '' : null,
      ),
    );
  }

  Widget _passwordField() {
    final focused = _passFocus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
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
            controller: _passController,
            focusNode: _passFocus,
            obscureText: _obscure,
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF1A1919), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter password',
              hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFFB0B0B0), fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 20, right: 52),
              errorStyle: const TextStyle(height: 0),
            ),
            validator: (v) => (v == null || v.isEmpty) ? '' : null,
          ),
          Positioned(
            right: 8,
            child: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                  color: focused ? _coral : const Color(0xFFB0B0B0), size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ],
      ),
    );
  }
}
