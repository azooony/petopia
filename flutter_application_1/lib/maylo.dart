import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MayloProfile extends StatelessWidget {
  const MayloProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // Standard color palette from Figma/design
    const Color primaryPink = Color(0xFFFFC7C8);
    const Color accentCoral = Color(0xFFFF7578);
    const Color textGrey = Color(0xFF8D8D8D);

    return Container(
      color: const Color(0xFF1C2632),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 375,
            maxHeight: 812,
          ),
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
                  // 1. Curved Header Section
                  Stack(
                    children: [
                      ClipPath(
                        clipper: HeaderClipper(),
                        child: Container(
                          height: 450,
                          color: primaryPink,
                        ),
                      ),
                      // Dog Image
                      Positioned(
                        top: 40,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          'assets/images/maylo.png',
                          height: 400,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Back Button (on top of image)
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

                  // 2. Info Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'maylo',
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

                        // Stats Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatCard('8 Years', 'Age', primaryPink),
                            _buildStatCard('Male', 'Gender', primaryPink),
                            _buildStatCard('16kg', 'Weight', primaryPink),
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
                          'maylo is calm boy dog, he is really caring. He like to play alot and loves sleeping.',
                          style: GoogleFonts.plusJakartaSans(
                            color: textGrey,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 35),

                        // 3. Footer Buttons
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                color: accentCoral,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.forum_outlined, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
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

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width / 2, size.height + 100, 
      size.width, size.height - 100
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
