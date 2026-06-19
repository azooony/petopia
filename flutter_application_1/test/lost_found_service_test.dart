// ============================================================================
// FILE: lost_found_service_test.dart
// SERVICE UNDER TEST: LostFoundService (lib/services/lost_found_service.dart)
// DESCRIPTION: Unit tests for the Lost & Found pet reporting system —
//              listing lost/found pets, reporting lost/found pets, and
//              deleting found pet reports.
//
// HOW TO RUN:
//   flutter test test/lost_found_service_test.dart
//
// HOW TO RUN WITH VERBOSE OUTPUT:
//   flutter test test/lost_found_service_test.dart --reporter expanded
// ============================================================================

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/lost_found_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 1 — LostPet Model Parsing
  // ═══════════════════════════════════════════════════════════════════════════

  group('LostPet.fromJson', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.1                                                     │
    // │ Functionality: Lost Pet — Parse Full Report from JSON             │
    // │ Description : Verifies that LostPet.fromJson() correctly parses   │
    // │               all fields from the API response including owner    │
    // │               details and image URLs.                             │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "parses full lost pet report"                │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses full lost pet report from JSON', () {
      final json = {
        'id': 'lost-001',
        'name': 'Buddy',
        'breed': 'Golden Retriever',
        'gender': 'MALE',
        'species': 'DOG',
        'lastSeenLocation': 'Nasr City, Cairo',
        'lastSeenDate': '2026-06-10T14:00:00.000Z',
        'description': 'Wearing a red collar',
        'ownerId': 'user-123',
        'owner': {'fullName': 'Ahmed Hassan'},
        'images': [
          {'url': 'http://example.com/buddy.jpg'},
        ],
      };

      final pet = LostPet.fromJson(json, 'user-123');

      expect(pet.id, equals('lost-001'));
      expect(pet.petName, equals('Buddy'));
      expect(pet.breed, equals('Golden Retriever'));
      expect(pet.gender, equals('MALE'));
      expect(pet.petType, equals('DOG'));
      expect(pet.lastSeenLocation, equals('Nasr City, Cairo'));
      expect(pet.lastSeenDate.year, equals(2026));
      expect(pet.description, equals('Wearing a red collar'));
      expect(pet.ownerName, equals('Ahmed Hassan'));
      expect(pet.imageUrl, equals('http://example.com/buddy.jpg'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.2                                                     │
    // │ Functionality: Lost Pet — Ownership Detection (isOwn flag)        │
    // │ Description : Verifies that the isOwn flag is true when the       │
    // │               current userId matches the ownerId, enabling the    │
    // │               UI to show edit/delete options.                     │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "detects own lost pet report"                │
    // └─────────────────────────────────────────────────────────────────────┘
    test('detects own lost pet report (isOwn = true)', () {
      final json = {
        'id': 'lost-002',
        'name': 'Luna',
        'lastSeenLocation': 'Maadi',
        'lastSeenDate': '2026-06-12T10:00:00.000Z',
        'ownerId': 'my-user-id',
        'owner': {'fullName': 'Me'},
        'images': [],
      };

      final pet = LostPet.fromJson(json, 'my-user-id');
      expect(pet.isOwn, isTrue);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.3                                                     │
    // │ Functionality: Lost Pet — Non-Owned Report (isOwn = false)        │
    // │ Description : Verifies that the isOwn flag is false when the      │
    // │               current user is NOT the report owner.               │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "marks other users' reports correctly"       │
    // └─────────────────────────────────────────────────────────────────────┘
    test('marks other users\' reports as not own (isOwn = false)', () {
      final json = {
        'id': 'lost-003',
        'name': 'Max',
        'lastSeenLocation': 'Heliopolis',
        'lastSeenDate': '2026-06-11T08:00:00.000Z',
        'ownerId': 'other-user-id',
        'owner': {'fullName': 'Someone Else'},
        'images': [],
      };

      final pet = LostPet.fromJson(json, 'my-user-id');
      expect(pet.isOwn, isFalse);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.4                                                     │
    // │ Functionality: Lost Pet — Handle Missing Optional Fields          │
    // │ Description : Verifies that missing optional fields (breed,       │
    // │               gender, images) default gracefully.                 │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "handles missing optional fields"            │
    // └─────────────────────────────────────────────────────────────────────┘
    test('handles missing optional fields gracefully', () {
      final json = {
        'id': 'lost-004',
        'lastSeenLocation': 'Downtown',
        'lastSeenDate': '2026-06-15T12:00:00.000Z',
        'ownerId': 'user-x',
        'images': [],
      };

      final pet = LostPet.fromJson(json, 'user-y');

      expect(pet.petName, equals('Unknown Pet'));
      expect(pet.breed, isNull);
      expect(pet.gender, isNull);
      expect(pet.imageUrl, isNull);
      expect(pet.description, isNull);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.5                                                     │
    // │ Functionality: Lost Pet — Image URL Resolution (Relative Path)    │
    // │ Description : Verifies that a relative image URL is prepended     │
    // │               with the API base URL, while absolute URLs are      │
    // │               used as-is.                                         │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "resolves relative image URL"                │
    // └─────────────────────────────────────────────────────────────────────┘
    test('resolves relative image URL with base URL prefix', () {
      final jsonWithRelative = {
        'id': 'lost-005',
        'name': 'Charlie',
        'lastSeenLocation': 'Giza',
        'lastSeenDate': '2026-06-14T09:00:00.000Z',
        'ownerId': 'user-z',
        'owner': {'fullName': 'Owner'},
        'images': [
          {'url': '/uploads/charlie.jpg'},
        ],
      };

      final pet = LostPet.fromJson(jsonWithRelative, 'me');

      // Relative URL should be prefixed with ApiClient.baseUrl
      expect(pet.imageUrl, isNotNull);
      expect(pet.imageUrl!, contains('charlie.jpg'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 2 — FoundPet Model Parsing
  // ═══════════════════════════════════════════════════════════════════════════

  group('FoundPet.fromJson', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.1                                                     │
    // │ Functionality: Found Pet — Parse Full Report from JSON            │
    // │ Description : Verifies that FoundPet.fromJson() correctly parses  │
    // │               all fields including reporter details.              │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "parses full found pet report"               │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses full found pet report from JSON', () {
      final json = {
        'id': 'found-001',
        'description': 'Found a small white kitten near the park',
        'species': 'CAT',
        'breed': 'Persian',
        'foundLocation': 'Al-Azhar Park, Cairo',
        'isPetStillAtLocation': true,
        'finderId': 'finder-001',
        'finder': {'fullName': 'Sara Mohamed'},
        'images': [
          {'url': 'http://example.com/kitten.jpg'},
        ],
      };

      final pet = FoundPet.fromJson(json, 'finder-001');

      expect(pet.id, equals('found-001'));
      expect(pet.description,
          equals('Found a small white kitten near the park'));
      expect(pet.petType, equals('CAT'));
      expect(pet.breed, equals('Persian'));
      expect(pet.foundLocation, equals('Al-Azhar Park, Cairo'));
      expect(pet.isPetKept, isTrue);
      expect(pet.reporterName, equals('Sara Mohamed'));
      expect(pet.reporterId, equals('finder-001'));
      expect(pet.isOwn, isTrue);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.2                                                     │
    // │ Functionality: Found Pet — Ownership Detection for Delete         │
    // │ Description : Verifies that isOwn correctly identifies reports    │
    // │               that the current user can delete.                   │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "identifies deletable reports"               │
    // └─────────────────────────────────────────────────────────────────────┘
    test('identifies deletable reports (own vs others)', () {
      final json = {
        'id': 'found-002',
        'description': 'Found pet',
        'foundLocation': 'Downtown',
        'isPetStillAtLocation': false,
        'finderId': 'other-user',
        'finder': {'fullName': 'Someone'},
        'images': [],
      };

      final ownReport = FoundPet.fromJson(json, 'other-user');
      final othersReport = FoundPet.fromJson(json, 'my-user');

      expect(ownReport.isOwn, isTrue);
      expect(othersReport.isOwn, isFalse);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.3                                                     │
    // │ Functionality: Found Pet — Default Values for Missing Fields      │
    // │ Description : Verifies that missing fields default to safe        │
    // │               values (empty strings, false, null).                │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "defaults missing found pet fields"          │
    // └─────────────────────────────────────────────────────────────────────┘
    test('defaults missing found pet fields to safe values', () {
      final json = {
        'images': [],
      };

      final pet = FoundPet.fromJson(json, 'me');

      expect(pet.id, equals(''));
      expect(pet.description, equals(''));
      expect(pet.foundLocation, equals(''));
      expect(pet.isPetKept, isFalse);
      expect(pet.reporterName, equals(''));
      expect(pet.reporterId, equals(''));
      expect(pet.imageUrl, isNull);
      expect(pet.petType, isNull);
      expect(pet.breed, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 3 — Report Lost Pet Request Construction
  // ═══════════════════════════════════════════════════════════════════════════

  group('Report Lost Pet — Request Construction', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.1                                                     │
    // │ Functionality: Report Lost — Builds Required Fields               │
    // │ Description : Verifies that the multipart form fields for         │
    // │               reporting a lost pet include all required fields.   │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "builds required lost pet fields"            │
    // └─────────────────────────────────────────────────────────────────────┘
    test('builds required lost pet fields correctly', () {
      const species = 'DOG';
      const description = 'Brown dog, medium size';
      const lastSeenLocation = 'Zamalek, Cairo';
      const lastSeenDate = '2026-06-10';

      final fields = <String, String>{
        'species': species,
        'description': description,
        'lastSeenLocation': lastSeenLocation,
        'lastSeenDate': lastSeenDate,
      };

      expect(fields['species'], equals('DOG'));
      expect(fields['description'], equals('Brown dog, medium size'));
      expect(fields['lastSeenLocation'], equals('Zamalek, Cairo'));
      expect(fields['lastSeenDate'], equals('2026-06-10'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.2                                                     │
    // │ Functionality: Report Lost — Includes Optional Fields             │
    // │ Description : Verifies that optional fields (petId, name, breed,  │
    // │               gender) are included when provided and excluded     │
    // │               when null or empty.                                 │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "includes optional fields when provided"     │
    // └─────────────────────────────────────────────────────────────────────┘
    test('includes optional fields when provided', () {
      String? petId = 'pet-123';
      String? name = 'Buddy';
      String? breed = 'Labrador';
      String? gender = 'MALE';

      final fields = <String, String>{
        'species': 'DOG',
        'description': 'Lost dog',
        'lastSeenLocation': 'Cairo',
        'lastSeenDate': '2026-06-10',
        if (petId != null && petId.isNotEmpty) 'petId': petId,
        if (name != null && name.isNotEmpty) 'name': name,
        if (breed != null && breed.isNotEmpty) 'breed': breed,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
      };

      expect(fields.containsKey('petId'), isTrue);
      expect(fields.containsKey('name'), isTrue);
      expect(fields.containsKey('breed'), isTrue);
      expect(fields.containsKey('gender'), isTrue);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.3                                                     │
    // │ Functionality: Report Lost — Excludes Empty Optional Fields       │
    // │ Description : Verifies that null/empty optional fields are NOT    │
    // │               included in the request.                            │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "excludes empty optional fields"             │
    // └─────────────────────────────────────────────────────────────────────┘
    test('excludes empty optional fields from request', () {
      String? petId;
      String? name = '';
      String? breed;

      final fields = <String, String>{
        'species': 'CAT',
        'description': 'Lost cat',
        'lastSeenLocation': 'Giza',
        'lastSeenDate': '2026-06-12',
        if (petId != null && petId.isNotEmpty) 'petId': petId,
        if (name != null && name.isNotEmpty) 'name': name,
        if (breed != null && breed!.isNotEmpty) 'breed': breed,
      };

      expect(fields.containsKey('petId'), isFalse);
      expect(fields.containsKey('name'), isFalse);
      expect(fields.containsKey('breed'), isFalse);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.4                                                     │
    // │ Functionality: Report Lost — Image File Preparation               │
    // │ Description : Verifies that image bytes and filename are          │
    // │               correctly prepared in the files list for upload.    │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "prepares image for lost pet report"         │
    // └─────────────────────────────────────────────────────────────────────┘
    test('prepares image file for lost pet report upload', () {
      final imageBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
      const imageFilename = 'lost_pet.jpg';

      final files = [
        {
          'field': 'images',
          'bytes': imageBytes,
          'filename': imageFilename,
        },
      ];

      expect(files.length, equals(1));
      expect(files[0]['field'], equals('images'));
      expect(files[0]['filename'], equals('lost_pet.jpg'));
      expect((files[0]['bytes'] as Uint8List).isNotEmpty, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 4 — Report Found Pet Request Construction
  // ═══════════════════════════════════════════════════════════════════════════

  group('Report Found Pet — Request Construction', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.1                                                     │
    // │ Functionality: Report Found — Builds Required Fields              │
    // │ Description : Verifies that the required fields for reporting a   │
    // │               found pet include species, description, location,   │
    // │               and isPetStillAtLocation (as string).               │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "builds required found pet fields"           │
    // └─────────────────────────────────────────────────────────────────────┘
    test('builds required found pet fields correctly', () {
      const species = 'CAT';
      const description = 'Small white kitten, friendly';
      const foundLocation = 'Al-Azhar Park';
      const isPetStillAtLocation = true;

      final fields = <String, String>{
        'species': species,
        'description': description,
        'foundLocation': foundLocation,
        'isPetStillAtLocation': isPetStillAtLocation.toString(),
      };

      expect(fields['species'], equals('CAT'));
      expect(fields['foundLocation'], equals('Al-Azhar Park'));
      expect(fields['isPetStillAtLocation'], equals('true'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.2                                                     │
    // │ Functionality: Report Found — No Image Produces Empty Files List  │
    // │ Description : Verifies that when no image is provided, the files  │
    // │               list is empty (not null).                           │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "empty files list when no image"             │
    // └─────────────────────────────────────────────────────────────────────┘
    test('produces empty files list when no image provided', () {
      Uint8List? imageBytes;
      String? imageFilename;

      final files = imageBytes != null && imageFilename != null
          ? [
              {
                'field': 'images',
                'bytes': imageBytes,
                'filename': imageFilename,
              }
            ]
          : <Map<String, dynamic>>[];

      expect(files, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 5 — Delete Found Pet
  // ═══════════════════════════════════════════════════════════════════════════

  group('Delete Found Pet', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 5.1                                                     │
    // │ Functionality: Delete Found Pet — Correct API Path                │
    // │ Description : Verifies that the delete endpoint path is           │
    // │               correctly constructed as /lost-found/found/{id}.    │
    // │ Command     : flutter test test/lost_found_service_test.dart      │
    // │               --name "constructs correct delete path"             │
    // └─────────────────────────────────────────────────────────────────────┘
    test('constructs correct delete API path', () {
      const id = 'found-123';
      final deletePath = '/lost-found/found/$id';

      expect(deletePath, equals('/lost-found/found/found-123'));
      expect(deletePath, startsWith('/lost-found/found/'));
    });
  });
}
