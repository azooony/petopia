import '../models/pet_match_models.dart';
import 'api_client.dart';

// Thrown when the user has no pet record — guides them to Add Your Pet first.
class PetMatchingException implements Exception {
  final String message;
  const PetMatchingException(this.message);
  @override
  String toString() => message;
}

class PetMatchingService {
  // ── Form pre-fill ─────────────────────────────────────────────────────────

  /// Fetches the current user's pet and any existing match profile.
  /// Controllers should be seeded from [PetForMatching] using the priority:
  ///   profile field → pet/user default → empty string.
  static Future<PetForMatching> getMyPetForMatching() async {
    final userRes   = await ApiClient.get('/users/me');
    final userData  = userRes['data'] as Map<String, dynamic>;
    final userAddress = userData['address'] as String? ?? '';

    // pets is a single object (one-to-one relation), not a list
    final petJson = userData['pets'] as Map<String, dynamic>?;
    if (petJson == null) {
      throw const PetMatchingException(
        'No pet found. Please add a pet from your profile first.',
      );
    }

    final pet = MyPet.fromJson(petJson);

    MyMatchProfile? profile;
    try {
      final profRes  = await ApiClient.get('/matching/profile/${pet.id}');
      final profData = profRes['data'] as Map<String, dynamic>?;
      final profJson = profData?['profile'] as Map<String, dynamic>?;
      if (profJson != null) profile = MyMatchProfile.fromJson(profJson);
    } catch (_) {
      // Profile may not exist yet — that's fine.
    }

    return PetForMatching(
      pet:         pet,
      userAddress: userAddress,
      profile:     profile,
    );
  }

  // ── Discovery ─────────────────────────────────────────────────────────────

  /// Returns all available match candidates, excluding the current user's pet.
  static Future<List<MatchPet>> getAvailableMatches(String petId) async {
    final res  = await ApiClient.get('/matching/discover/$petId');
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => MatchPet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns all available match candidates without excluding any pet.
  /// Used when the current user has no registered pet yet.
  static Future<List<MatchPet>> getAllAvailableMatches({String? petType}) async {
    final query = petType != null ? '?type=$petType' : '';
    final res  = await ApiClient.get('/matching/discover$query');
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => MatchPet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Delete profile ────────────────────────────────────────────────────────

  static Future<void> deleteMatchProfile(String petId) async {
    await ApiClient.delete('/matching/profile/$petId');
  }

  // ── Delete pet entirely from the database ─────────────────────────────────

  static Future<void> deletePet(String petId) async {
    await ApiClient.delete('/pets/$petId');
  }

  // ── Auto-register ─────────────────────────────────────────────────────────

  /// Called after saving the user profile so the pet is immediately visible
  /// in the discover list. Uses existing profile values where available.
  static Future<void> autoRegisterForMatching() async {
    final data = await getMyPetForMatching();
    await upsertMatchProfile(
      petId:          data.pet.id,
      description:    data.profile?.description ?? data.pet.description ?? '',
      address:        data.profile?.address      ?? data.userAddress,
      preferredBreed: data.profile?.preferredBreed ?? data.pet.breed ?? '',
    );
  }

  // ── Profile upsert ────────────────────────────────────────────────────────

  /// Creates or updates the match profile. The backend treats POST as upsert.
  static Future<void> upsertMatchProfile({
    required String petId,
    required String description,
    required String address,
    required String preferredBreed,
  }) async {
    await ApiClient.post('/matching/profile', {
      'petId':          petId,
      'description':    description,
      'address':        address,
      'preferredBreed': preferredBreed,
    });
  }

  // ── Match request ─────────────────────────────────────────────────────────

  /// Sends a match request. A 400 "Request already exists" is silenced so
  /// tapping "Message Me" on a previously liked pet still opens the chat.
  static Future<void> sendMatchRequest(
      String fromPetId, String toPetId) async {
    try {
      await ApiClient.post('/matching/request', {
        'fromPetId': fromPetId,
        'toPetId':   toPetId,
      });
    } on ApiException catch (e) {
      if (e.statusCode != 400) rethrow;
    }
  }
}
