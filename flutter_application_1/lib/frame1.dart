import 'package:flutter/material.dart';
import 'frame2.dart';

class Frame1 extends StatelessWidget {
  const Frame1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      body: Center(
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  width: 381.66,
                  height: 850.32,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(46),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 19.28,
                        top: 514.39,
                        child: SizedBox(
                          width: 360.09,
                          height: 41.37,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Find Your ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                    height: 1.30,
                                    letterSpacing: -0.41,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Pet happiness',
                                  style: TextStyle(
                                    color: const Color(0xFFED6663),
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                    height: 1.30,
                                    letterSpacing: -0.41,
                                  ),
                                ),
                                TextSpan(
                                  text: ' Here!',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                    height: 1.30,
                                    letterSpacing: -0.41,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 27,
                        top: 549,
                        child: SizedBox(
                          width: 337.49,
                          height: 66.12,
                          child: Opacity(
                            opacity: 0.70,
                            child: Text(
                              'fur-ever care, forever friends',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                                height: 0.67,
                                letterSpacing: -0.41,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 91,
                        top: 651,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Frame2()),
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
                      ),
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
                      Positioned(
                        left: 15.94,
                        top: 176.39,
                        child: Container(
                          width: 352.35,
                          height: 338.24,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/image.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 165.07,
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
                      Positioned(
                        left: 187.12,
                        top: 755.66,
                        child: Container(
                          width: 7.06,
                          height: 7.36,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFEFD2D3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.35),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 199.17,
                        top: 755.66,
                        child: Container(
                          width: 7.06,
                          height: 7.36,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFEFD2D3),
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
      ),
    );
  }
}
