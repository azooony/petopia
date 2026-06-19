import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_profile.dart';
import 'pet_match_discover.dart';
import 'services/pet_matching_service.dart';

class PetSelection extends StatelessWidget {
  const PetSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: GoogleFonts.plusJakartaSansTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'select whether\nyou are',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Add Your Pet Option
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => const UserProfile()),
                          );
                          if (result == true && context.mounted) {
                            try {
                              await PetMatchingService.autoRegisterForMatching();
                            } catch (_) {}
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const PetMatchDiscover()),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5E5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFB5B5),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/cat.png',
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'add your pet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF7578),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'or',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Pet Sit Option
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PetMatchDiscover()),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5E5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFB5B5),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/girl.png',
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'match your pet!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF7578),
                                ),
                              ),
                            ],
                          ),
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
}