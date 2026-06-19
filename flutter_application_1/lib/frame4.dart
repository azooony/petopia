import 'package:flutter/material.dart';
import 'frame_lostfound_intro.dart';

class Frame4 extends StatelessWidget {
  const Frame4({super.key});

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
            // ── Hero image (dog) ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 90),
                child: Image.asset(
                  "assets/images/dog.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ── Title text ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Access ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1.30,
                      ),
                    ),
                    TextSpan(
                      text: 'Educational Resources',
                      style: TextStyle(
                        color: Color(0xFFED6663),
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1.30,
                      ),
                    ),
                    TextSpan(
                      text: ' for Pet Behavior and Training',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1.30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // ── Get Started button ──
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FrameLostFoundIntro()),
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
                      'Get Started',
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
                    color: const Color(0xFFDFDFDF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 7,
                  height: 7,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFDFDFDF),
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
                    color: const Color(0xFFFF9DA0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 7,
                  height: 7,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEFD2D3),
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
