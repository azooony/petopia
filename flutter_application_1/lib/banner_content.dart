import 'package:flutter/material.dart';
import 'found_pet_list_screen.dart';
import 'add_found_pet_screen.dart';
import 'lost_pet_list_screen.dart';
import 'add_lost_pet_screen.dart';
import 'petmatching.dart';
import 'vetappointmnets.dart';
import 'pet_sitting.dart';
import 'pet_sitter_register.dart';
import 'add_pet_sitting.dart';
import 'services/sitting_service.dart';

/// One entry in the banner rotation.
class BannerData {
  final String text;
  final String buttonLabel;

  /// Called when the user taps the banner button.
  /// [ctx] is the BuildContext of the Home Screen.
  /// [category] is the active category filter ('Dogs', 'Cats', or null).
  final Future<void> Function(BuildContext ctx, String? category) onTap;

  const BannerData({
    required this.text,
    required this.buttonLabel,
    required this.onTap,
  });
}

/// The 9 rotating banner cases, in order.
/// Index is derived from [BannerRotation.bannerIndex].
class BannerContent {
  static final List<BannerData> items = [
    // ── 1. Browse found pets ──────────────────────────────────────────────────
    BannerData(
      text: 'lost your pet?\nThere\'s a chance\nit can be found!',
      buttonLabel: 'browse found pets',
      onTap: (ctx, _) async => Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => const FoundPetListScreen()),
      ),
    ),

    // ── 2. Add a found pet ────────────────────────────────────────────────────
    BannerData(
      text: 'Found a Pet? Help\nits owner find it',
      buttonLabel: 'add a found pet',
      onTap: (ctx, _) async => Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => const AddFoundPetScreen()),
      ),
    ),

    // ── 3. Browse lost pets ───────────────────────────────────────────────────
    BannerData(
      text: 'Help a pet get\nback to its owner',
      buttonLabel: 'browse lost pets',
      onTap: (ctx, _) async => Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => const LostPetListScreen()),
      ),
    ),

    // ── 4. Add a lost pet ─────────────────────────────────────────────────────
    BannerData(
      text: 'lost your pet?\nMaybe someone\ncan recognize it',
      buttonLabel: 'add a lost pet',
      onTap: (ctx, _) async => Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => const AddLostPetScreen()),
      ),
    ),

    // ── 5. Find a match ───────────────────────────────────────────────────────
    BannerData(
      text: 'Some pets are\nlooking for a match!',
      buttonLabel: 'find a match',
      onTap: (ctx, cat) async => Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (_) => PetMatching(
            typeFilter: cat == 'Dogs' ? 'DOG' : cat == 'Cats' ? 'CAT' : null,
          ),
        ),
      ),
    ),

    // ── 6. Add pet for matching ───────────────────────────────────────────────
    BannerData(
      text: 'Do you want to add\nyour pet for matching?',
      buttonLabel: 'add my pet',
      onTap: (ctx, cat) async => Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (_) => PetMatching(
            typeFilter: cat == 'Dogs' ? 'DOG' : cat == 'Cats' ? 'CAT' : null,
          ),
        ),
      ),
    ),

    // ── 7. Find a doctor ──────────────────────────────────────────────────────
    BannerData(
      text: 'Looking for a doctor\nfor your pet?',
      buttonLabel: 'find a doctor',
      onTap: (ctx, _) async => Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => const VetAppointments()),
      ),
    ),

    // ── 8. Pet sitting — conditional on sitter status ────────────────────────
    // Approved sitters → discovery list.  Others → registration screen.
    BannerData(
      text: 'Pets need\nsitting',
      buttonLabel: 'petsit now',
      onTap: (ctx, cat) async {
        final status = await SittingService.getSitterStatus();
        if (!ctx.mounted) return;
        if (status == 'APPROVED') {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => PetSitting(
                typeFilter:
                    cat == 'Dogs' ? 'DOG' : cat == 'Cats' ? 'CAT' : null,
              ),
            ),
          );
        } else {
          Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => const PetSitterRegister()),
          );
        }
      },
    ),

    // ── 9. Add pet for sitting ────────────────────────────────────────────────
    BannerData(
      text: 'Going out? Put your\npet up for sitting',
      buttonLabel: 'add pet for sitting',
      onTap: (ctx, _) async => Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => const AddPetSittingScreen()),
      ),
    ),
  ];
}
