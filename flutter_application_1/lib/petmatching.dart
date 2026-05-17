import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pet_match_form.dart';
import 'pet_match_discover.dart';
import 'services/pet_matching_service.dart';

class PetMatching extends StatefulWidget {
  final String? typeFilter;
  const PetMatching({super.key, this.typeFilter});

  @override
  State<PetMatching> createState() => _PetMatchingState();
}

class _PetMatchingState extends State<PetMatching> {
  bool _checkingPet = false;

  static const _coral = Color(0xFFFF7578);

  Future<void> _onAddPet() async {
    if (_checkingPet) return;
    setState(() => _checkingPet = true);

    try {
      final data = await PetMatchingService.getMyPetForMatching();

      // Pet exists — auto-register if no match profile yet, then go to list
      if (data.profile == null) {
        await PetMatchingService.upsertMatchProfile(
          petId:          data.pet.id,
          description:    data.pet.description ?? '',
          address:        data.userAddress,
          preferredBreed: data.pet.breed ?? '',
        );
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PetMatchDiscover(typeFilter: widget.typeFilter),
        ),
      );
    } on PetMatchingException catch (_) {
      if (!mounted) return;
      // No pet at all — show the form once to create one
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PetMatchForm()),
      );
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not check your profile. Please try again.');
    } finally {
      if (mounted) setState(() => _checkingPet = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.plusJakartaSans()),
      backgroundColor: _coral,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C2632),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
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

                      // ── Add your pet ──────────────────────────────────────
                      GestureDetector(
                        onTap: _checkingPet ? null : _onAddPet,
                        child: AnimatedOpacity(
                          opacity: _checkingPet ? 0.6 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5E5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFFFFB5B5), width: 2),
                            ),
                            child: Column(
                              children: [
                                Image.asset('assets/images/girl.png',
                                    height: 200, fit: BoxFit.contain),
                                const SizedBox(height: 16),
                                if (_checkingPet)
                                  const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                        color: _coral, strokeWidth: 2),
                                  )
                                else
                                  const Text(
                                    'add your pet',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: _coral,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Center(
                        child: Text('or',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey)),
                      ),
                      const SizedBox(height: 10),

                      // ── Find a match ──────────────────────────────────────
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PetMatchDiscover(typeFilter: widget.typeFilter),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5E5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFFFB5B5), width: 2),
                          ),
                          child: Column(
                            children: [
                              Image.asset('assets/images/cat.png',
                                  height: 200, fit: BoxFit.contain),
                              const SizedBox(height: 16),
                              const Text(
                                'find a match',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: _coral,
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
