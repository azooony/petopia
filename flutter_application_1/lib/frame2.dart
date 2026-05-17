import 'package:flutter/material.dart';
import 'frame3.dart';

class Frame2 extends StatelessWidget {
  const Frame2({super.key});

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
                  width: 390.67,
                  height: 851.42,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(46),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 91,
                        top: 641,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Frame3()),
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
                        left: 69.88,
                        top: 192,
                        child: Container(
                          width: 227.12,
                          height: 239.22,
                          decoration: ShapeDecoration(
                            image: const DecorationImage(
                              image: AssetImage("assets/images/dr.png"),
                              fit: BoxFit.cover,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(38),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 28.97,
                        top: 517,
                        child: SizedBox(
                          width: 350.04,
                          height: 123.12,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Track ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                    height: 1.30,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Vet Appointments',
                                  style: TextStyle(
                                    color: const Color(0xFFED6663),
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                    height: 1.30,
                                  ),
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                    height: 1.30,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Medication Schedules',
                                  style: TextStyle(
                                    color: const Color(0xFFED6663),
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
                      Positioned(
                        left: -0.25,
                        top: 94,
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
                        left: 203,
                        top: 757,
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
                        left: 215,
                        top: 757,
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
                        left: 237,
                        top: 757,
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
