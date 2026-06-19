import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'frame6.dart';

import 'doctor_signin.dart';

class Frame5 extends StatefulWidget {
  const Frame5({super.key});

  @override
  State<Frame5> createState() => _Frame5State();
}

class _Frame5State extends State<Frame5> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'select whether\nyou are',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),

                // Pet owner option
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      setState(() {
                        _selectedRole = 'pet_owner';
                      });
                      final navigator = Navigator.of(context);
                      await Future.delayed(const Duration(milliseconds: 250));
                      if (!mounted) return;
                      navigator.push(
                        MaterialPageRoute(builder: (context) => const Frame6()),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _selectedRole == 'pet_owner'
                            ? const Color(0xFFFF7578)
                            : Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage("assets/images/cat.png"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _selectedRole == 'pet_owner'
                                    ? const Color(0xFFFF7578)
                                    : const Color(0xFFFFC7C8),
                                width: _selectedRole == 'pet_owner' ? 3 : 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'pet owner',
                            style: TextStyle(
                              color: Color(0xFFFF7578),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // OR separator with lines
                Row(
                  children: const [
                    Expanded(
                      child: Divider(
                        color: Colors.black26,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'or',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.black26,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Doctor option
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      setState(() {
                        _selectedRole = 'doctor';
                      });
                      final navigator = Navigator.of(context);
                      await Future.delayed(const Duration(milliseconds: 250));
                      if (!mounted) return;
                      navigator.push(
                        MaterialPageRoute(builder: (context) => const DoctorSignIn()),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _selectedRole == 'doctor'
                            ? const Color(0xFFFF7578)
                            : Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage("assets/images/dr.png"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _selectedRole == 'doctor'
                                    ? const Color(0xFFFF7578)
                                    : const Color(0xFFFFC7C8),
                                width: _selectedRole == 'doctor' ? 3 : 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'doctor',
                            style: TextStyle(
                              color: Color(0xFFFF7578),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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
    );
  }
}
