import 'package:flutter/material.dart';
import 'frame4.dart';

class Frame3 extends StatelessWidget {
  const Frame3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ── Petopia header image ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(
                "assets/images/imagee.png",
                width: double.infinity,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            // ── Hero image (cat) ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Image.asset(
                  "assets/images/cat.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ── Title text ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Find Trusted',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1.30,
                      ),
                    ),
                    TextSpan(
                      text: ' Pet Sitters ',
                      style: TextStyle(
                        color: Color(0xFFED6663),
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1.30,
                      ),
                    ),
                    TextSpan(
                      text: 'and ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1.30,
                      ),
                    ),
                    TextSpan(
                      text: 'Match Your Pet',
                      style: TextStyle(
                        color: Color(0xFFED6663),
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1.30,
                      ),
                    ),
                    TextSpan(
                      text: ' for Socialization!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1.30,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 32),
            // ── Continue button ──
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Frame4()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  width: 200,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7578),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ── Dot indicators ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: ShapeDecoration(
                    color: Color(0xFFDFDFDF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 17,
                  height: 7,
                  decoration: ShapeDecoration(
                    color: Color(0xFFFF9DA0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 10,
                  height: 7,
                  decoration: ShapeDecoration(
                    color: Color(0xFFEFD2D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
