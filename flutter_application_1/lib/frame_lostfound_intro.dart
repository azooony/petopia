import 'package:flutter/material.dart';
import 'frame5.dart';

class FrameLostFoundIntro extends StatelessWidget {
  const FrameLostFoundIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      body: ListView(
        children: [
          Column(
            children: [
              Container(
                width: 381.66,
                height: 850.32,
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(46)),
                  ),
                ),
                child: Stack(
                  children: [
                    // ── Petopia header image (same as all other frames) ─────
                    Positioned(
                      left: 8.03,
                      top: 87.39,
                      child: Container(
                        width: 367.26,
                        height: 95.11,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/imagee.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // ── Illustration ────────────────────────────────────────
                    Positioned(
                      left: 80,
                      top: 200,
                      child: Container(
                        width: 220,
                        height: 270,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/lost.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // ── Headline text ───────────────────────────────────────
                    Positioned(
                      left: 34,
                      top: 518,
                      child: SizedBox(
                        width: 305.38,
                        height: 91.75,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Reunite with Your ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                  height: 1.30,
                                ),
                              ),
                              TextSpan(
                                text: 'Lost Pet',
                                style: TextStyle(
                                  color: Color(0xFFED6663),
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                  height: 1.30,
                                ),
                              ),
                              TextSpan(
                                text: ' or Help a ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                  height: 1.30,
                                ),
                              ),
                              TextSpan(
                                text: 'Found One',
                                style: TextStyle(
                                  color: Color(0xFFED6663),
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                  height: 1.30,
                                ),
                              ),
                              TextSpan(
                                text: ' Get Home',
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
                    ),

                    // ── Get Started button ──────────────────────────────────
                    Positioned(
                      left: 91,
                      top: 652,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Frame5()),
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
                            child: const Center(
                              child: Text(
                                'Get started',
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
                    ),

                    // ── Dot indicators (4 dots, 4th active) ────────────────
                    Positioned(
                      left: 153,
                      top: 755.66,
                      child: Container(
                        width: 7.06,
                        height: 7.36,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFDFDFDF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.35),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 165,
                      top: 755.66,
                      child: Container(
                        width: 7.06,
                        height: 7.36,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFDFDFDF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.35),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 177,
                      top: 755.66,
                      child: Container(
                        width: 7.06,
                        height: 7.36,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFDFDFDF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.35),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 189,
                      top: 755.66,
                      child: Container(
                        width: 17.06,
                        height: 7.44,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFF9DA0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.35),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
