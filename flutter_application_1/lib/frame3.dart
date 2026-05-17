import 'package:flutter/material.dart';
import 'frame4.dart';
class Frame3 extends StatelessWidget {
  const Frame3({super.key});

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
                        left: 28,
                        right: 28,
                        top: 522.34,
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
                      Positioned(
                        left: 91,
                        top: 649,
                        child: Material(
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
                        left: 80.79,
                        top: 196.34,
                        child: Container(
                          width: 221.22,
                          height: 227.27,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/cat.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 165.07,
                        top: 755.66,
                        child: Container(
                          width: 7.06,
                          height: 7.36,
                          decoration: ShapeDecoration(
                            color: Color(0xFFDFDFDF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.35),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 177.12,
                        top: 755.45,
                        child: Container(
                          width: 17.06,
                          height: 7.44,
                          decoration: ShapeDecoration(
                            color: Color(0xFFFF9DA0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.35),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 198,
                        top: 755.87,
                        child: Container(
                          width: 10.50,
                          height: 7.39,
                          decoration: ShapeDecoration(
                            color: Color(0xFFEFD2D3),
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
