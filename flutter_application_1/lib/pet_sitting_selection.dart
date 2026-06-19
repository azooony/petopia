import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pet_sitter_register.dart';
import 'add_pet_sitting.dart';
import 'pet_sitting.dart';
import 'services/sitting_service.dart';
import 'services/api_client.dart';

class PetSittingSelection extends StatefulWidget {
  final String? typeFilter;
  const PetSittingSelection({super.key, this.typeFilter});

  @override
  State<PetSittingSelection> createState() => _PetSittingSelectionState();
}

class _PetSittingSelectionState extends State<PetSittingSelection> {
  bool _checkingPet    = false;
  bool _checkingSitter = false;

  static const _coral = Color(0xFFFF7578);

  // ── "Need a pet sitter" path ────────────────────────────────────────────────
  Future<void> _onNeedSitter() async {
    if (_checkingPet) return;
    setState(() => _checkingPet = true);

    try {
      final res  = await ApiClient.get('/users/me');
      final data = res['data'] as Map<String, dynamic>? ?? res;
      final pet  = data['pets'] as Map<String, dynamic>?;

      if (!mounted) return;

      final alreadyListed = pet != null && (pet['isAvailableForSitting'] as bool? ?? false);

      if (alreadyListed) {
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => PetSitting(typeFilter: widget.typeFilter)));
      } else {
        final nav   = Navigator.of(context);
        final added = await nav.push<bool>(
          MaterialPageRoute(builder: (_) => const AddPetSittingScreen()),
        );
        if (added == true && mounted) {
          nav.push(MaterialPageRoute(
              builder: (_) => PetSitting(typeFilter: widget.typeFilter)));
        }
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not check your pet status. Please try again.');
    } finally {
      if (mounted) setState(() => _checkingPet = false);
    }
  }

  // ── "Become a pet sitter" path ──────────────────────────────────────────────
  Future<void> _onBecomeSitter() async {
    if (_checkingSitter) return;
    setState(() => _checkingSitter = true);

    String? status;
    try {
      status = await SittingService.getSitterStatus();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(e.message);
      setState(() => _checkingSitter = false);
      return;
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not check your sitter status. Please try again.');
      setState(() => _checkingSitter = false);
      return;
    } finally {
      if (mounted) setState(() => _checkingSitter = false);
    }

    if (!mounted) return;

    if (status == 'PENDING') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Application Under Review',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700, fontSize: 17)),
          content: Text(
            'Your request is being reviewed by our team. You\'ll be notified once it\'s approved.',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, color: const Color(0xFF6B6B6B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('OK',
                  style: GoogleFonts.plusJakartaSans(
                      color: _coral, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      return;
    }

    if (status == 'APPROVED') {
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => PetSitting(typeFilter: widget.typeFilter)));
      return;
    }

    // null or REJECTED → registration form
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PetSitterRegister()));
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

                      // ── Need a sitter ────────────────────────────────────
                      GestureDetector(
                        onTap: _checkingPet ? null : _onNeedSitter,
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
                                Image.asset('assets/images/cat.png',
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
                                    'need a pet sitter',
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
                      ),

                      const SizedBox(height: 10),
                      const Center(
                        child: Text('or',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ),
                      const SizedBox(height: 10),

                      // ── Become a sitter ──────────────────────────────────
                      GestureDetector(
                        onTap: _checkingSitter ? null : _onBecomeSitter,
                        child: AnimatedOpacity(
                          opacity: _checkingSitter ? 0.6 : 1.0,
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
                                if (_checkingSitter)
                                  const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                        color: _coral, strokeWidth: 2),
                                  )
                                else
                                  const Text(
                                    'become a pet sitter',
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
