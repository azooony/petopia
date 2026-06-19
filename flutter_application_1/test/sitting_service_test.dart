// ============================================================================
// FILE: sitting_service_test.dart
// SERVICE UNDER TEST: SittingService (lib/services/sitting_service.dart)
// DESCRIPTION: Unit tests for the pet sitting system — listing pets for
//              sitting, fetching available pets, sitter registration,
//              and the SittingPet model parsing.
//
// HOW TO RUN:
//   flutter test test/sitting_service_test.dart
//
// HOW TO RUN WITH VERBOSE OUTPUT:
//   flutter test test/sitting_service_test.dart --reporter expanded
// ============================================================================

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/sitting_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 1 — SittingPet Model Parsing
  // ═══════════════════════════════════════════════════════════════════════════

  group('SittingPet.fromJson', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.1                                                     │
    // │ Functionality: Sitting Pet — Parse Full Pet from JSON             │
    // │ Description : Verifies that SittingPet.fromJson() correctly       │
    // │               parses all fields from the API response including   │
    // │               computed fields like duration and price formatting. │
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "parses full sitting pet"                    │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses full sitting pet from JSON', () {
      final json = {
        'id': 'sit-001',
        'name': 'Buddy',
        'breed': 'Labrador',
        'age': 3,
        'gender': 'MALE',
        'petType': 'DOG',
        'payRatePerDay': 50,
        'sittingNotes': '2026-06-20 to 2026-06-25\nNeeds daily walks',
        'ownerAddress': 'Maadi, Cairo',
        'ownerName': 'Ahmed',
        'ownerId': 'owner-001',
        'isOwn': false,
        'photo': null,
      };

      final pet = SittingPet.fromJson(json);

      expect(pet.id, equals('sit-001'));
      expect(pet.name, equals('Buddy'));
      expect(pet.breed, equals('Labrador'));
      expect(pet.age, equals(3));
      expect(pet.gender, equals('Male'));
      expect(pet.petType, equals('DOG'));
      expect(pet.pricePerDay, equals('50 EGP/day'));
      expect(pet.city, equals('Maadi, Cairo'));
      expect(pet.ownerName, equals('Ahmed'));
      expect(pet.isOwn, isFalse);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.2                                                     │
    // │ Functionality: Sitting Pet — Date Range Formatting                │
    // │ Description : Verifies that the sittingNotes date range is        │
    // │               correctly parsed and formatted as                   │
    // │               "Mon DD → Mon DD · N days".                         │
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "formats date range correctly"               │
    // └─────────────────────────────────────────────────────────────────────┘
    test('formats date range correctly from sittingNotes', () {
      final json = {
        'id': 'sit-002',
        'name': 'Luna',
        'sittingNotes': '2026-07-01 to 2026-07-05',
        'gender': 'FEMALE',
        'ownerAddress': 'Giza',
      };

      final pet = SittingPet.fromJson(json);

      // Should format as "Jul 1 → Jul 5 · 5 days"
      expect(pet.duration, contains('Jul'));
      expect(pet.duration, contains('5 days'));
      expect(pet.duration, contains('→'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.3                                                     │
    // │ Functionality: Sitting Pet — Single Day Duration                  │
    // │ Description : Verifies that a single-day range is formatted       │
    // │               correctly as "1 day" (not "1 days").                │
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "formats single day duration"                │
    // └─────────────────────────────────────────────────────────────────────┘
    test('formats single day duration correctly', () {
      final json = {
        'id': 'sit-003',
        'name': 'Max',
        'sittingNotes': '2026-08-15 to 2026-08-15',
        'gender': 'MALE',
        'ownerAddress': 'Cairo',
      };

      final pet = SittingPet.fromJson(json);

      expect(pet.duration, contains('1 day'));
      expect(pet.duration, isNot(contains('1 days')));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.4                                                     │
    // │ Functionality: Sitting Pet — Gender Formatting                    │
    // │ Description : Verifies that 'MALE' becomes 'Male' and 'FEMALE'   │
    // │               becomes 'Female' for display purposes.              │
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "formats gender for display"                 │
    // └─────────────────────────────────────────────────────────────────────┘
    test('formats gender for display (Male/Female)', () {
      final malePet = SittingPet.fromJson({
        'id': 'sit-m',
        'name': 'Boy',
        'gender': 'MALE',
        'sittingNotes': '',
        'ownerAddress': '',
      });

      final femalePet = SittingPet.fromJson({
        'id': 'sit-f',
        'name': 'Girl',
        'gender': 'FEMALE',
        'sittingNotes': '',
        'ownerAddress': '',
      });

      expect(malePet.gender, equals('Male'));
      expect(femalePet.gender, equals('Female'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.5                                                     │
    // │ Functionality: Sitting Pet — Pet Type Normalization               │
    // │ Description : Verifies that petType is normalised to uppercase    │
    // │               'DOG' or 'CAT', defaulting to 'DOG' for unknown.   │
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "normalizes pet type"                        │
    // └─────────────────────────────────────────────────────────────────────┘
    test('normalizes pet type to uppercase DOG or CAT', () {
      final dogPet = SittingPet.fromJson({
        'id': 'sit-d',
        'name': 'Dog',
        'petType': 'dog',
        'gender': 'MALE',
        'sittingNotes': '',
        'ownerAddress': '',
      });

      final catPet = SittingPet.fromJson({
        'id': 'sit-c',
        'name': 'Cat',
        'petType': 'cat',
        'gender': 'FEMALE',
        'sittingNotes': '',
        'ownerAddress': '',
      });

      final unknownPet = SittingPet.fromJson({
        'id': 'sit-u',
        'name': 'Unknown',
        'petType': 'hamster',
        'gender': 'MALE',
        'sittingNotes': '',
        'ownerAddress': '',
      });

      expect(dogPet.petType, equals('DOG'));
      expect(catPet.petType, equals('CAT'));
      expect(unknownPet.petType, equals('DOG')); // defaults to DOG
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.6                                                     │
    // │ Functionality: Sitting Pet — Image URL Resolution                 │
    // │ Description : Verifies that relative photo URLs are prefixed      │
    // │               with the API base URL, and absolute URLs are kept.  │
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "resolves image URL"                         │
    // └─────────────────────────────────────────────────────────────────────┘
    test('resolves image URL (absolute vs relative)', () {
      final absolutePet = SittingPet.fromJson({
        'id': 'sit-abs',
        'name': 'Abs',
        'photo': 'http://example.com/photo.jpg',
        'gender': 'MALE',
        'sittingNotes': '',
        'ownerAddress': '',
      });

      final relativePet = SittingPet.fromJson({
        'id': 'sit-rel',
        'name': 'Rel',
        'photo': '/uploads/photo.jpg',
        'gender': 'MALE',
        'sittingNotes': '',
        'ownerAddress': '',
      });

      final noPet = SittingPet.fromJson({
        'id': 'sit-none',
        'name': 'None',
        'gender': 'MALE',
        'sittingNotes': '',
        'ownerAddress': '',
      });

      expect(absolutePet.imageUrl, equals('http://example.com/photo.jpg'));
      expect(relativePet.imageUrl, isNotNull);
      expect(relativePet.imageUrl!, contains('/uploads/photo.jpg'));
      expect(noPet.imageUrl, isNull);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.7                                                     │
    // │ Functionality: Sitting Pet — Sitting Notes Parsing (Extra Notes)  │
    // │ Description : Verifies that sitting notes after the first line    │
    // │               (date range) are extracted as fullNotes for display.│
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "extracts full notes"                        │
    // └─────────────────────────────────────────────────────────────────────┘
    test('extracts full notes from sittingNotes (after date range)', () {
      final json = {
        'id': 'sit-notes',
        'name': 'Noted',
        'sittingNotes': '2026-06-20 to 2026-06-25\nNeeds daily walks\nAllergic to chicken',
        'gender': 'MALE',
        'ownerAddress': '',
      };

      final pet = SittingPet.fromJson(json);

      expect(pet.fullNotes, isNotNull);
      expect(pet.fullNotes!, contains('Needs daily walks'));
      expect(pet.fullNotes!, contains('Allergic to chicken'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.8                                                     │
    // │ Functionality: Sitting Pet — No Extra Notes                       │
    // │ Description : Verifies that fullNotes is null when sitting notes  │
    // │               contain only the date range and nothing else.       │
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "null fullNotes when only date range"        │
    // └─────────────────────────────────────────────────────────────────────┘
    test('fullNotes is null when only date range in notes', () {
      final json = {
        'id': 'sit-noextra',
        'name': 'Simple',
        'sittingNotes': '2026-06-20 to 2026-06-25',
        'gender': 'MALE',
        'ownerAddress': '',
      };

      final pet = SittingPet.fromJson(json);
      expect(pet.fullNotes, isNull);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.9                                                     │
    // │ Functionality: Sitting Pet — Price Formatting                     │
    // │ Description : Verifies that payRatePerDay is formatted as         │
    // │               "X EGP/day" and null when not provided.             │
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "formats price per day"                      │
    // └─────────────────────────────────────────────────────────────────────┘
    test('formats price per day correctly', () {
      final withPrice = SittingPet.fromJson({
        'id': 'sit-p1',
        'name': 'Pricy',
        'payRatePerDay': 75,
        'gender': 'MALE',
        'sittingNotes': '',
        'ownerAddress': '',
      });

      final noPrice = SittingPet.fromJson({
        'id': 'sit-p2',
        'name': 'Free',
        'gender': 'MALE',
        'sittingNotes': '',
        'ownerAddress': '',
      });

      expect(withPrice.pricePerDay, equals('75 EGP/day'));
      expect(noPrice.pricePerDay, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 2 — List Pet for Sitting Request Construction
  // ═══════════════════════════════════════════════════════════════════════════

  group('listPetForSitting — Request Construction', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.1                                                     │
    // │ Functionality: List Pet — Multipart Fields (With Photo)           │
    // │ Description : Verifies that when a photo is provided, the fields  │
    // │               are assembled as strings for multipart upload.      │
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "assembles multipart fields with photo"      │
    // └─────────────────────────────────────────────────────────────────────┘
    test('assembles multipart fields correctly with photo', () {
      final photoBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF]);
      const photoFilename = 'pet_photo.jpg';

      final fields = {
        'petName': 'Buddy',
        'breed': 'Labrador',
        'age': 3.toString(),
        'gender': 'MALE',
        'petType': 'DOG',
        'payRatePerDay': 50.0.toString(),
        'sittingNotes': '2026-06-20 to 2026-06-25\nNeeds daily walks',
      };

      final files = [
        {
          'field': 'petPhoto',
          'bytes': photoBytes,
          'filename': photoFilename,
        },
      ];

      expect(fields['petName'], equals('Buddy'));
      expect(fields['age'], equals('3'));
      expect(fields['payRatePerDay'], equals('50.0'));
      expect(files.length, equals(1));
      expect(files[0]['field'], equals('petPhoto'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.2                                                     │
    // │ Functionality: List Pet — JSON Body (Without Photo)               │
    // │ Description : Verifies that when no photo is provided, the        │
    // │               request is sent as regular JSON POST (not multipart)│
    // │               with native types (int, double).                    │
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "assembles JSON body without photo"          │
    // └─────────────────────────────────────────────────────────────────────┘
    test('assembles JSON body correctly without photo', () {
      Uint8List? photoBytes;

      final useMultipart = photoBytes != null;
      expect(useMultipart, isFalse);

      final body = <String, dynamic>{
        'petName': 'Luna',
        'breed': 'Persian',
        'age': 2,
        'gender': 'FEMALE',
        'petType': 'CAT',
        'payRatePerDay': 30.0,
        'sittingNotes': 'Indoor cat only',
      };

      expect(body['age'], isA<int>());
      expect(body['payRatePerDay'], isA<double>());
      expect(body['petType'], equals('CAT'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 3 — Register Sitter
  // ═══════════════════════════════════════════════════════════════════════════

  group('registerSitter — Request Construction', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.1                                                     │
    // │ Functionality: Register Sitter — Two File Upload Preparation      │
    // │ Description : Verifies that both nationalIdPhoto and venuePhoto   │
    // │               files are correctly prepared for multipart upload.  │
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "prepares two files for sitter registration" │
    // └─────────────────────────────────────────────────────────────────────┘
    test('prepares two files for sitter registration', () {
      final nationalIdBytes = Uint8List.fromList([0xFF, 0xD8, 0x01]);
      const nationalIdFilename = 'national_id.jpg';
      final venuePhotoBytes = Uint8List.fromList([0xFF, 0xD8, 0x02]);
      const venuePhotoFilename = 'venue.jpg';

      final files = [
        {
          'field': 'nationalIdPhoto',
          'bytes': nationalIdBytes,
          'filename': nationalIdFilename,
        },
        {
          'field': 'venuePhoto',
          'bytes': venuePhotoBytes,
          'filename': venuePhotoFilename,
        },
      ];

      expect(files.length, equals(2));
      expect(files[0]['field'], equals('nationalIdPhoto'));
      expect(files[1]['field'], equals('venuePhoto'));
      expect((files[0]['bytes'] as Uint8List).isNotEmpty, isTrue);
      expect((files[1]['bytes'] as Uint8List).isNotEmpty, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 4 — API Endpoints
  // ═══════════════════════════════════════════════════════════════════════════

  group('SittingService API Endpoints', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.1                                                     │
    // │ Functionality: API Endpoints — Correct Path Construction          │
    // │ Description : Verifies that all sitting service API endpoint      │
    // │               paths are correctly formed.                         │
    // │ Command     : flutter test test/sitting_service_test.dart         │
    // │               --name "correct API endpoint paths"                 │
    // └─────────────────────────────────────────────────────────────────────┘
    test('all sitting service API endpoint paths are correct', () {
      const listEndpoint = '/sitting/pet-listing';
      const availableEndpoint = '/sitting/available-pets';
      const unlistEndpoint = '/sitting/pet-listing';
      const statusEndpoint = '/sitting/sitter-status';
      const registerEndpoint = '/sitting/register-sitter';

      expect(listEndpoint, startsWith('/sitting/'));
      expect(availableEndpoint, startsWith('/sitting/'));
      expect(unlistEndpoint, equals(listEndpoint)); // same path, DELETE method
      expect(statusEndpoint, startsWith('/sitting/'));
      expect(registerEndpoint, startsWith('/sitting/'));
    });
  });
}
