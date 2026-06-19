import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lost_pet_list_screen.dart';
import 'found_pet_list_screen.dart';

class LostFoundSelection extends StatelessWidget {
  final String? typeFilter;
  const LostFoundSelection({super.key, this.typeFilter});

  static const _coral = Color(0xFFFF7578);

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
                        'what are you\nlooking for?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _optionCard(
                        label: 'lost pets',
                        imagePath: 'assets/images/lost.png',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LostPetListScreen(typeFilter: typeFilter)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'or',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _optionCard(
                        label: 'found pets',
                        imagePath: 'assets/images/cat.png',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FoundPetListScreen(typeFilter: typeFilter)),
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

  Widget _optionCard({
    required String label,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5E5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFB5B5), width: 2),
        ),
        child: Column(
          children: [
            Image.asset(imagePath, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _coral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
