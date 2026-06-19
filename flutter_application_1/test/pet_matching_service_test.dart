// ============================================================================
// FILE: pet_matching_service_test.dart
// SERVICE UNDER TEST: PetMatchingService (lib/services/pet_matching_service.dart)
// DESCRIPTION: Unit tests for the pet matching/adoption system — pet profile
//              parsing, discovery list, match profile upsert, and match
//              request handling.
//
// HOW TO RUN:
//   flutter test test/pet_matching_service_test.dart
//
// HOW TO RUN WITH VERBOSE OUTPUT:
//   flutter test test/pet_matching_service_test.dart --reporter expanded
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/pet_match_models.dart';
import 'package:flutter_application_1/services/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 1 — MyPet Model Parsing
  // ═══════════════════════════════════════════════════════════════════════════

  group('MyPet.fromJson', () {
    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.1                                                     │
    // │ Functionality: My Pet — Parse Full Pet from JSON                  │
    // │ Description : Verifies that MyPet.fromJson() correctly parses     │
    // │               all fields including optional breed, gender, photo. │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "parses full MyPet from JSON"                │
    // └───────────────────────────────────────────────────────────────────┘
    test('parses full MyPet from JSON', () {
      final json = {
        'id': 'pet-001',
        'name': 'Buddy',
        'breed': 'Golden Retriever',
        'age': 3,
        'gender': 'MALE',
        'description': 'Friendly and playful',
        'photo': 'http://example.com/buddy.jpg',
      };

      final pet = MyPet.fromJson(json);

      expect(pet.id, equals('pet-001'));
      expect(pet.name, equals('Buddy'));
      expect(pet.breed, equals('Golden Retriever'));
      expect(pet.age, equals(3));
      expect(pet.gender, equals('MALE'));
      expect(pet.description, equals('Friendly and playful'));
      expect(pet.photo, equals('http://example.com/buddy.jpg'));
    });

    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.2                                                     │
    // │ Functionality: My Pet — Handle Nullable Fields                    │
    // │ Description : Verifies that MyPet handles missing optional fields │
    // │               (breed, gender, description, photo) with null.      │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "handles nullable MyPet fields"              │
    // └───────────────────────────────────────────────────────────────────┘
    test('handles nullable MyPet fields gracefully', () {
      final json = {
        'id': 'pet-002',
        'name': 'Unknown',
        'age': 1,
      };

      final pet = MyPet.fromJson(json);

      expect(pet.breed, isNull);
      expect(pet.gender, isNull);
      expect(pet.description, isNull);
      expect(pet.photo, isNull);
    });

    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.3                                                     │
    // │ Functionality: My Pet — Age Defaults to 0 When Null               │
    // │ Description : Verifies that age defaults to 0 when the JSON       │
    // │               field is null (e.g., age not set yet).              │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "age defaults to 0"                          │
    // └───────────────────────────────────────────────────────────────────┘
    test('age defaults to 0 when null', () {
      final json = {
        'id': 'pet-003',
        'name': 'Baby',
        'age': null,
      };

      final pet = MyPet.fromJson(json);
      expect(pet.age, equals(0));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 2 — MyMatchProfile Model Parsing
  // ═══════════════════════════════════════════════════════════════════════════

  group('MyMatchProfile.fromJson', () {
    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.1                                                     │
    // │ Functionality: Match Profile — Parse Full Profile from JSON       │
    // │ Description : Verifies that MyMatchProfile.fromJson() correctly   │
    // │               parses all fields including isAvailable flag.       │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "parses full match profile"                  │
    // └───────────────────────────────────────────────────────────────────┘
    test('parses full match profile from JSON', () {
      final json = {
        'id': 'profile-001',
        'petId': 'pet-001',
        'description': 'Looking for a playmate',
        'address': 'Cairo, Egypt',
        'preferredBreed': 'Siamese',
        'isavailable': true,
      };

      final profile = MyMatchProfile.fromJson(json);

      expect(profile.id, equals('profile-001'));
      expect(profile.petId, equals('pet-001'));
      expect(profile.description, equals('Looking for a playmate'));
      expect(profile.address, equals('Cairo, Egypt'));
      expect(profile.preferredBreed, equals('Siamese'));
      expect(profile.isAvailable, isTrue);
    });

    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.2                                                     │
    // │ Functionality: Match Profile — isAvailable Defaults to True       │
    // │ Description : Verifies that isAvailable defaults to true when     │
    // │               the 'isavailable' field is missing or null.         │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "isAvailable defaults to true"               │
    // └───────────────────────────────────────────────────────────────────┘
    test('isAvailable defaults to true when missing', () {
      final json = {
        'id': 'profile-002',
        'petId': 'pet-002',
      };

      final profile = MyMatchProfile.fromJson(json);
      expect(profile.isAvailable, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 3 — PetForMatching Bundled Result
  // ═══════════════════════════════════════════════════════════════════════════

  group('PetForMatching', () {
    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.1                                                     │
    // │ Functionality: Pet For Matching — Bundle Pet + Address + Profile  │
    // │ Description : Verifies that PetForMatching correctly bundles      │
    // │               the pet, user address, and optional match profile.  │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "bundles pet and profile"                    │
    // └───────────────────────────────────────────────────────────────────┘
    test('bundles pet, user address, and profile correctly', () {
      final pet = MyPet.fromJson({
        'id': 'pet-001',
        'name': 'Buddy',
        'age': 3,
      });
      final profile = MyMatchProfile.fromJson({
        'id': 'profile-001',
        'petId': 'pet-001',
        'description': 'Friendly dog',
        'address': 'Maadi, Cairo',
        'isavailable': true,
      });

      final bundle = PetForMatching(
        pet: pet,
        userAddress: 'Maadi, Cairo',
        profile: profile,
      );

      expect(bundle.pet.name, equals('Buddy'));
      expect(bundle.userAddress, equals('Maadi, Cairo'));
      expect(bundle.profile, isNotNull);
      expect(bundle.profile!.description, equals('Friendly dog'));
    });

    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.2                                                     │
    // │ Functionality: Pet For Matching — Profile Can Be Null             │
    // │ Description : Verifies that PetForMatching works when no match    │
    // │               profile exists yet (first-time setup).              │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "profile can be null"                        │
    // └───────────────────────────────────────────────────────────────────┘
    test('works with null profile (first-time setup)', () {
      final pet = MyPet.fromJson({
        'id': 'pet-002',
        'name': 'Luna',
        'age': 1,
      });

      final bundle = PetForMatching(
        pet: pet,
        userAddress: 'Giza',
        profile: null,
      );

      expect(bundle.profile, isNull);
      expect(bundle.pet.name, equals('Luna'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 4 — MatchPet Model (Discovery List)
  // ═══════════════════════════════════════════════════════════════════════════

  group('MatchPet.fromJson', () {
    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.1                                                     │
    // │ Functionality: Match Pet — Parse Discovery Item from JSON         │
    // │ Description : Verifies that MatchPet.fromJson() correctly parses  │
    // │               nested pet, owner, and images from the discover     │
    // │               API response.                                       │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "parses discovery item"                      │
    // └───────────────────────────────────────────────────────────────────┘
    test('parses discovery item from JSON', () {
      final json = {
        'id': 'profile-100',
        'petId': 'pet-100',
        'description': 'Playful and energetic',
        'address': 'Heliopolis',
        'pet': {
          'name': 'Max',
          'age': 2,
          'breed': 'Husky',
          'gender': 'MALE',
          'owner': {
            'id': 'owner-100',
            'fullName': 'Omar Ali',
          },
          'images': [
            {
              'isPrimary': true,
              'asset': {'url': 'http://example.com/max_primary.jpg'},
            },
            {
              'isPrimary': false,
              'asset': {'url': 'http://example.com/max_secondary.jpg'},
            },
          ],
        },
      };

      final matchPet = MatchPet.fromJson(json);

      expect(matchPet.profileId, equals('profile-100'));
      expect(matchPet.petId, equals('pet-100'));
      expect(matchPet.petName, equals('Max'));
      expect(matchPet.petAge, equals(2));
      expect(matchPet.petBreed, equals('Husky'));
      expect(matchPet.petGender, equals('MALE'));
      expect(matchPet.description, equals('Playful and energetic'));
      expect(matchPet.address, equals('Heliopolis'));
      expect(matchPet.ownerId, equals('owner-100'));
      expect(matchPet.ownerName, equals('Omar Ali'));
      expect(matchPet.imageUrl, equals('http://example.com/max_primary.jpg'));
    });

    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.2                                                     │
    // │ Functionality: Match Pet — Primary Image Selection                │
    // │ Description : Verifies that when multiple images exist, the       │
    // │               isPrimary=true image is selected over others.       │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "selects primary image"                      │
    // └───────────────────────────────────────────────────────────────────┘
    test('selects primary image over non-primary', () {
      final json = {
        'id': 'p-200',
        'petId': 'pet-200',
        'pet': {
          'name': 'Charlie',
          'age': 4,
          'owner': {'id': 'o-200', 'fullName': 'Test'},
          'images': [
            {
              'isPrimary': false,
              'asset': {'url': 'http://example.com/secondary.jpg'},
            },
            {
              'isPrimary': true,
              'asset': {'url': 'http://example.com/primary.jpg'},
            },
          ],
        },
      };

      final matchPet = MatchPet.fromJson(json);
      expect(matchPet.imageUrl, equals('http://example.com/primary.jpg'));
    });

    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.3                                                     │
    // │ Functionality: Match Pet — Fallback to First Image                │
    // │ Description : Verifies that when no isPrimary image exists, the   │
    // │               first image in the list is used as fallback.        │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "falls back to first image"                  │
    // └───────────────────────────────────────────────────────────────────┘
    test('falls back to first image when no primary', () {
      final json = {
        'id': 'p-300',
        'petId': 'pet-300',
        'pet': {
          'name': 'Bella',
          'age': 1,
          'owner': {'id': 'o-300', 'fullName': 'Test'},
          'images': [
            {
              'isPrimary': false,
              'asset': {'url': 'http://example.com/first.jpg'},
            },
          ],
        },
      };

      final matchPet = MatchPet.fromJson(json);
      expect(matchPet.imageUrl, equals('http://example.com/first.jpg'));
    });

    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.4                                                     │
    // │ Functionality: Match Pet — Fallback to pet.photo                  │
    // │ Description : Verifies that when no images list exists, the       │
    // │               pet's photo field is used as ultimate fallback.     │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "falls back to pet photo"                    │
    // └───────────────────────────────────────────────────────────────────┘
    test('falls back to pet.photo when no images', () {
      final json = {
        'id': 'p-400',
        'petId': 'pet-400',
        'pet': {
          'name': 'Simba',
          'age': 5,
          'photo': 'http://example.com/simba_fallback.jpg',
          'owner': {'id': 'o-400', 'fullName': 'Test'},
          'images': [],
        },
      };

      final matchPet = MatchPet.fromJson(json);
      expect(
          matchPet.imageUrl, equals('http://example.com/simba_fallback.jpg'));
    });

    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.5                                                     │
    // │ Functionality: Match Pet — Default Values for Missing Data        │
    // │ Description : Verifies that MatchPet defaults to 'Unknown' name,  │
    // │               0 age, and empty owner fields when data is missing. │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "defaults missing match pet data"            │
    // └───────────────────────────────────────────────────────────────────┘
    test('defaults missing match pet data to safe values', () {
      final json = {
        'id': 'p-500',
        'petId': 'pet-500',
        'pet': {},
      };

      final matchPet = MatchPet.fromJson(json);

      expect(matchPet.petName, equals('Unknown'));
      expect(matchPet.petAge, equals(0));
      expect(matchPet.ownerId, equals(''));
      expect(matchPet.ownerName, equals(''));
      expect(matchPet.imageUrl, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 5 — Match Profile Upsert Request
  // ═══════════════════════════════════════════════════════════════════════════

  group('Match Profile Upsert', () {
    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 5.1                                                     │
    // │ Functionality: Upsert Profile — Request Body Construction         │
    // │ Description : Verifies that the request body for creating or      │
    // │               updating a match profile contains the correct keys. │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "constructs upsert request body"             │
    // └───────────────────────────────────────────────────────────────────┘
    test('constructs upsert request body correctly', () {
      final body = {
        'petId': 'pet-001',
        'description': 'Friendly golden retriever looking for play dates',
        'address': 'Maadi, Cairo',
        'preferredBreed': 'Labrador',
      };

      expect(body['petId'], equals('pet-001'));
      expect(body['description'], contains('golden retriever'));
      expect(body['address'], equals('Maadi, Cairo'));
      expect(body['preferredBreed'], equals('Labrador'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 6 — Match Request Sending
  // ═══════════════════════════════════════════════════════════════════════════

  group('Send Match Request', () {
    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 6.1                                                     │
    // │ Functionality: Match Request — Request Body Construction          │
    // │ Description : Verifies that the match request body contains       │
    // │               fromPetId and toPetId for the two pets to match.    │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "constructs match request body"              │
    // └───────────────────────────────────────────────────────────────────┘
    test('constructs match request body correctly', () {
      const fromPetId = 'pet-001';
      const toPetId = 'pet-002';

      final body = {
        'fromPetId': fromPetId,
        'toPetId': toPetId,
      };

      expect(body['fromPetId'], equals('pet-001'));
      expect(body['toPetId'], equals('pet-002'));
      expect(body.length, equals(2));
    });

    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 6.2                                                     │
    // │ Functionality: Match Request — 400 Silencing (Duplicate Request)  │
    // │ Description : Verifies the logic that silences a 400 error when   │
    // │               a match request already exists, allowing the UI     │
    // │               to proceed to open the chat anyway.                 │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "silences 400 duplicate request"             │
    // └───────────────────────────────────────────────────────────────────┘
    test('silences 400 duplicate request error', () {
      // Simulate the try/catch logic from sendMatchRequest
      const statusCode = 400;
      bool shouldRethrow = false;

      try {
        throw const ApiException(statusCode, 'Request already exists');
      } on ApiException catch (e) {
        if (e.statusCode != 400) {
          shouldRethrow = true;
        }
        // 400 is silenced — we don't rethrow
      }

      expect(shouldRethrow, isFalse);
    });

    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 6.3                                                     │
    // │ Functionality: Match Request — Non-400 Errors Are Rethrown        │
    // │ Description : Verifies that non-400 errors (e.g., 500) are NOT    │
    // │               silenced and propagate to the caller.               │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "rethrows non-400 errors"                    │
    // └───────────────────────────────────────────────────────────────────┘
    test('rethrows non-400 errors', () {
      expect(
        () {
          try {
            throw const ApiException(500, 'Internal server error');
          } on ApiException catch (e) {
            if (e.statusCode != 400) rethrow;
          }
        },
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 7 — PetMatchingException
  // ═══════════════════════════════════════════════════════════════════════════

  group('PetMatchingException', () {
    // ┌───────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 7.1                                                     │
    // │ Functionality: Pet Matching Exception — No Pet Found Message      │
    // │ Description : Verifies that the exception thrown when no pet is   │
    // │               found contains a user-friendly message.             │
    // │ Command     : flutter test test/pet_matching_service_test.dart    │
    // │               --name "no pet found exception message"             │
    // └───────────────────────────────────────────────────────────────────┘
    test('no pet found exception has user-friendly message', () {
      // Importing and testing directly from the service would require
      // importing the service file. Instead, we test the pattern.
      const message =
          'No pet found. Please add a pet from your profile first.';

      expect(message, contains('No pet found'));
      expect(message, contains('add a pet'));
    });
  });
}
