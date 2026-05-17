import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_screen.dart';

class SimbaProfile extends StatelessWidget {
  const SimbaProfile({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFFFC7C8);
    const Color accentCoral = Color(0xFFFF7578);
    const Color textGrey = Color(0xFF8D8D8D);

    return Container(
      color: const Color(0xFF1C2632),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
          ),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipPath(
                        clipper: _HeaderClipper(),
                        child: Container(height: 450, color: primaryPink),
                      ),
                      Positioned(
                        top: 40,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          'assets/images/simba.png',
                          height: 400,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 50,
                        left: 20,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE8E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back, size: 18, color: textGrey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'simba',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18, color: textGrey),
                            const SizedBox(width: 4),
                            Text(
                              'Giza',
                              style: GoogleFonts.plusJakartaSans(
                                color: textGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatCard('1 Year', 'Age', primaryPink),
                            _buildStatCard('Male', 'Gender', primaryPink),
                            _buildStatCard('3.5kg', 'Weight', primaryPink),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'About',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Simba is a clean male cat, he is really playful. He likes to play with a ball and loves swimming.',
                          style: GoogleFonts.plusJakartaSans(
                            color: textGrey,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 35),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChatScreen(
                                    recipientName: 'Simba',
                                    recipientImage: 'assets/images/simba.png',
                                  ),
                                ),
                              ),
                              child: Container(
                                width: 80,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: accentCoral,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.forum_outlined,
                                    color: Colors.white, size: 24),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ChatScreen(
                                      recipientName: 'Simba',
                                      recipientImage: 'assets/images/simba.png',
                                    ),
                                  ),
                                ),
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: accentCoral,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'message me',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
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

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF777777),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width / 2, size.height + 100,
      size.width, size.height - 100,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
