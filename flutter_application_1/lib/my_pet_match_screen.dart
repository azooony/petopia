import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/pet_match_models.dart';
import 'services/pet_matching_service.dart';
import 'pet_match_form.dart';
import 'pet_match_discover.dart';

class MyPetMatchScreen extends StatefulWidget {
  const MyPetMatchScreen({super.key});

  @override
  State<MyPetMatchScreen> createState() => _MyPetMatchScreenState();
}

class _MyPetMatchScreenState extends State<MyPetMatchScreen> {
  static const _coral = Color(0xFFFF7578);

  bool    _isLoading = true;
  String? _error;
  MyPet?           _pet;
  MyMatchProfile?  _matchProfile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await PetMatchingService.getMyPetForMatching();
      if (mounted) {
        setState(() {
          _pet          = data.pet;
          _matchProfile = data.profile;
          _isLoading    = false;
        });
      }
    } on PetMatchingException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to load.'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(30),
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
              title: Text('my match profile',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded,
                      color: Color(0xFF9E9E9E)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PetMatchForm()),
                  ).then((_) => _load()),
                ),
              ],
            ),
            body: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _coral))
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_error!,
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey, fontSize: 14),
                              textAlign: TextAlign.center),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('your pet is listed!',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: const Color(0xFF9E9E9E))),
                            const SizedBox(height: 12),

                            // Pet card — same structure as pet_sitting.dart
                            _buildCard(),

                            const SizedBox(height: 24),

                            // Description from match profile
                            if (_matchProfile?.description != null &&
                                _matchProfile!.description!.isNotEmpty) ...[
                              Text('about',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A1919))),
                              const SizedBox(height: 6),
                              Text(_matchProfile!.description!,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: const Color(0xFF9E9E9E),
                                      height: 1.5)),
                              const SizedBox(height: 24),
                            ],

                            const Spacer(),

                            // Navigate to discover
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const PetMatchDiscover()),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _coral,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: Text('Find a Match',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
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

  Widget _buildCard() {
    final pet = _pet!;
    final mp  = _matchProfile;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withAlpha(50),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Photo block with "Yours" badge
          Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 94,
                    height: 94,
                    color: const Color(0xFFFFB5B5),
                    child: pet.photo != null
                        ? Image.network(
                            pet.photo!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.pets_rounded,
                                color: Colors.white,
                                size: 36),
                          )
                        : const Icon(Icons.pets_rounded,
                            color: Colors.white, size: 36),
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _coral,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Yours',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pet.name,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  _pill(
                      icon: Icons.cake_outlined,
                      label:
                          '${pet.age} year${pet.age == 1 ? '' : 's'} old'),
                  const SizedBox(height: 6),
                  Row(children: [
                    if (pet.gender != null)
                      _pill(
                        icon: pet.gender == 'MALE'
                            ? Icons.male_rounded
                            : Icons.female_rounded,
                        label: pet.gender == 'MALE' ? 'Male' : 'Female',
                        color: pet.gender == 'MALE'
                            ? const Color(0xFF5B9EF7)
                            : _coral,
                      ),
                    if (pet.gender != null &&
                        mp?.address != null &&
                        mp!.address!.isNotEmpty)
                      const SizedBox(width: 8),
                    if (mp?.address != null && mp!.address!.isNotEmpty)
                      _pill(
                          icon: Icons.location_on_outlined,
                          label: mp.address!),
                  ]),
                  if (pet.breed != null && pet.breed!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _pill(
                      icon: Icons.pets_rounded,
                      label: pet.breed!,
                      color: const Color(0xFF2ECC71),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(
      {required IconData icon, required String label, Color? color}) {
    final c = color ?? const Color(0xFF9E9E9E);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: c),
      const SizedBox(width: 3),
      Text(label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 12, color: c, fontWeight: FontWeight.w500)),
    ]);
  }
}
