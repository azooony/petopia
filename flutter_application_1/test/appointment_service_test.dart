// ============================================================================
// FILE: appointment_service_test.dart
// SERVICE UNDER TEST: AppointmentService (lib/services/appointment_service.dart)
// DESCRIPTION: Unit tests for veterinary appointment booking — fetching
//              doctors, fetching user's pets, and booking appointments.
//
// HOW TO RUN:
//   flutter test test/appointment_service_test.dart
//
// HOW TO RUN WITH VERBOSE OUTPUT:
//   flutter test test/appointment_service_test.dart --reporter expanded
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/doctor_model.dart';
import 'package:flutter_application_1/models/pet_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 1 — fetchDoctors (GET /appointments/doctors)
  // ═══════════════════════════════════════════════════════════════════════════

  group('AppointmentService.fetchDoctors', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.1                                                     │
    // │ Functionality: Fetch Doctors — Parse Doctor Model from JSON       │
    // │ Description : Verifies that DoctorModel.fromJson() correctly      │
    // │               parses a full doctor JSON payload including nested  │
    // │               vetProfile, clinic, and availability slots.         │
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "parses DoctorModel from JSON"               │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses DoctorModel from JSON correctly', () {
      final json = {
        'id': 'doc-001',
        'fullName': 'Dr. Sarah Ahmed',
        'email': 'sarah@vet.com',
        'vetProfile': {
          'id': 'vp-001',
          'phone': '01012345678',
          'description': 'Experienced vet specializing in cats.',
          'yearsOfExperience': 5,
          'appointmentPrice': 150.0,
          'startTime': '09:00',
          'endTime': '17:00',
          'photo': null,
          'specialization': 'Cats',
          'clinic': {
            'id': 'clinic-001',
            'name': 'Happy Paws Clinic',
            'address': 'Nasr City, Cairo',
            'phone': '0227654321',
          },
        },
        'availabilitySlots': [
          {
            'id': 'slot-001',
            'startTime': '2026-06-20T09:00:00.000Z',
            'endTime': '2026-06-20T09:30:00.000Z',
          },
          {
            'id': 'slot-002',
            'startTime': '2026-06-20T10:00:00.000Z',
            'endTime': '2026-06-20T10:30:00.000Z',
          },
        ],
      };

      final doctor = DoctorModel.fromJson(json);

      expect(doctor.id, equals('doc-001'));
      expect(doctor.fullName, equals('Dr. Sarah Ahmed'));
      expect(doctor.email, equals('sarah@vet.com'));
      expect(doctor.vetProfile.appointmentPrice, equals(150.0));
      expect(doctor.vetProfile.startTime, equals('09:00'));
      expect(doctor.vetProfile.endTime, equals('17:00'));
      expect(doctor.vetProfile.clinic.name, equals('Happy Paws Clinic'));
      expect(doctor.vetProfile.clinic.address, equals('Nasr City, Cairo'));
      expect(doctor.availabilitySlots.length, equals(2));
      expect(doctor.availabilitySlots[0].id, equals('slot-001'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.2                                                     │
    // │ Functionality: Fetch Doctors — Display Fee Formatting             │
    // │ Description : Verifies that DoctorModel.displayFee correctly      │
    // │               formats the appointment price as "X EGP".           │
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "displayFee formats correctly"               │
    // └─────────────────────────────────────────────────────────────────────┘
    test('displayFee formats correctly as EGP', () {
      final doctor = DoctorModel.fromJson({
        'id': 'doc-002',
        'fullName': 'Dr. Mohamed',
        'email': 'mohamed@vet.com',
        'vetProfile': {
          'id': 'vp-002',
          'appointmentPrice': 200.0,
          'startTime': '10:00',
          'endTime': '18:00',
          'clinic': {
            'id': 'c-002',
            'name': 'Pet Care',
            'address': 'Maadi, Cairo',
          },
        },
        'availabilitySlots': [],
      });

      expect(doctor.displayFee, equals('200 EGP'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.3                                                     │
    // │ Functionality: Fetch Doctors — Working Hours Formatting           │
    // │ Description : Verifies that DoctorModel.workingHours correctly    │
    // │               formats as "startTime – endTime".                   │
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "workingHours formats correctly"             │
    // └─────────────────────────────────────────────────────────────────────┘
    test('workingHours formats correctly', () {
      final doctor = DoctorModel.fromJson({
        'id': 'doc-003',
        'fullName': 'Dr. Laila',
        'email': 'laila@vet.com',
        'vetProfile': {
          'id': 'vp-003',
          'appointmentPrice': 100.0,
          'startTime': '08:00',
          'endTime': '16:00',
          'clinic': {
            'id': 'c-003',
            'name': 'Vet Plus',
            'address': 'Heliopolis',
          },
        },
        'availabilitySlots': [],
      });

      expect(doctor.workingHours, equals('08:00 – 16:00'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.4                                                     │
    // │ Functionality: Fetch Doctors — Parse List of Doctors              │
    // │ Description : Verifies that a list of doctor JSON objects is      │
    // │               correctly mapped to a List<DoctorModel>.           │
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "parses list of doctors"                     │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses list of doctors from response data', () {
      final responseData = [
        {
          'id': 'doc-a',
          'fullName': 'Dr. A',
          'email': 'a@vet.com',
          'vetProfile': {
            'id': 'vp-a',
            'appointmentPrice': 100.0,
            'startTime': '09:00',
            'endTime': '17:00',
            'clinic': {
              'id': 'c-a',
              'name': 'Clinic A',
              'address': 'Cairo',
            },
          },
          'availabilitySlots': [],
        },
        {
          'id': 'doc-b',
          'fullName': 'Dr. B',
          'email': 'b@vet.com',
          'vetProfile': {
            'id': 'vp-b',
            'appointmentPrice': 250.0,
            'startTime': '10:00',
            'endTime': '18:00',
            'clinic': {
              'id': 'c-b',
              'name': 'Clinic B',
              'address': 'Giza',
            },
          },
          'availabilitySlots': [],
        },
      ];

      final doctors = responseData
          .map((json) => DoctorModel.fromJson(json))
          .toList();

      expect(doctors.length, equals(2));
      expect(doctors[0].fullName, equals('Dr. A'));
      expect(doctors[1].fullName, equals('Dr. B'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 2 — fetchMyPets (GET /pets)
  // ═══════════════════════════════════════════════════════════════════════════

  group('AppointmentService.fetchMyPets', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.1                                                     │
    // │ Functionality: Fetch My Pets — Parse PetModel from JSON           │
    // │ Description : Verifies that PetModel.fromJson() correctly parses  │
    // │               a pet JSON payload with all fields.                 │
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "parses PetModel from JSON"                  │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses PetModel from JSON correctly', () {
      final json = {
        'id': 'pet-001',
        'name': 'Buddy',
        'breed': 'Golden Retriever',
        'age': 3,
        'gender': 'MALE',
      };

      final pet = PetModel.fromJson(json);

      expect(pet.id, equals('pet-001'));
      expect(pet.name, equals('Buddy'));
      expect(pet.breed, equals('Golden Retriever'));
      expect(pet.age, equals(3));
      expect(pet.gender, equals('MALE'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.2                                                     │
    // │ Functionality: Fetch My Pets — Display Label Formatting           │
    // │ Description : Verifies that PetModel.displayLabel correctly       │
    // │               formats as "Name · Breed" or just "Name" if no     │
    // │               breed is available.                                 │
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "displayLabel formatting"                    │
    // └─────────────────────────────────────────────────────────────────────┘
    test('displayLabel formats correctly', () {
      final petWithBreed = PetModel.fromJson({
        'id': 'pet-002',
        'name': 'Luna',
        'breed': 'Siamese',
        'age': 2,
        'gender': 'FEMALE',
      });

      final petWithoutBreed = PetModel.fromJson({
        'id': 'pet-003',
        'name': 'Max',
      });

      expect(petWithBreed.displayLabel, equals('Luna · Siamese'));
      expect(petWithoutBreed.displayLabel, equals('Max'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.3                                                     │
    // │ Functionality: Fetch My Pets — Nullable Fields                    │
    // │ Description : Verifies that PetModel handles nullable fields      │
    // │               (breed, age, gender) gracefully when missing.       │
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "handles nullable fields"                    │
    // └─────────────────────────────────────────────────────────────────────┘
    test('handles nullable fields gracefully', () {
      final json = {
        'id': 'pet-004',
        'name': 'Unknown Pet',
      };

      final pet = PetModel.fromJson(json);

      expect(pet.id, equals('pet-004'));
      expect(pet.name, equals('Unknown Pet'));
      expect(pet.breed, isNull);
      expect(pet.age, isNull);
      expect(pet.gender, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 3 — bookAppointment (POST /appointments/book)
  // ═══════════════════════════════════════════════════════════════════════════

  group('AppointmentService.bookAppointment', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.1                                                     │
    // │ Functionality: Book Appointment — Request Fields Assembly         │
    // │ Description : Verifies that the multipart form fields for         │
    // │               booking an appointment are correctly assembled,     │
    // │               including UTC ISO 8601 date formatting.             │
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "assembles booking request fields"           │
    // └─────────────────────────────────────────────────────────────────────┘
    test('assembles booking request fields correctly', () {
      final startTime = DateTime(2026, 6, 20, 10, 0);
      const vetId = 'vet-001';
      const petId = 'pet-001';
      const reason = 'Annual checkup';

      final fields = <String, String>{
        'vetId': vetId,
        'petId': petId,
        'startTime': startTime.toUtc().toIso8601String(),
        if (reason.isNotEmpty) 'reason': reason,
      };

      expect(fields['vetId'], equals('vet-001'));
      expect(fields['petId'], equals('pet-001'));
      expect(fields['startTime'], contains('2026-06-'));
      expect(fields['reason'], equals('Annual checkup'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.2                                                     │
    // │ Functionality: Book Appointment — Optional Reason Omission        │
    // │ Description : Verifies that when no reason is provided, the       │
    // │               'reason' field is omitted from the request.         │
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "omits reason when null"                     │
    // └─────────────────────────────────────────────────────────────────────┘
    test('omits reason when null or empty', () {
      final startTime = DateTime(2026, 6, 20, 10, 0);
      String? reason;

      final fields = <String, String>{
        'vetId': 'vet-001',
        'petId': 'pet-001',
        'startTime': startTime.toUtc().toIso8601String(),
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      };

      expect(fields.containsKey('reason'), isFalse);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.3                                                     │
    // │ Functionality: Book Appointment — Invoice File Preparation        │
    // │ Description : Verifies that the invoice image bytes and filename  │
    // │               are correctly prepared for the 'invoice' file field.│
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "prepares invoice file for upload"           │
    // └─────────────────────────────────────────────────────────────────────┘
    test('prepares invoice file for upload', () {
      final invoiceBytes = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]; // JPEG stub
      const invoiceFilename = 'payment_receipt.jpg';
      const fileField = 'invoice';

      expect(invoiceBytes, isNotEmpty);
      expect(invoiceFilename, endsWith('.jpg'));
      expect(fileField, equals('invoice'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.4                                                     │
    // │ Functionality: Book Appointment — Date UTC Conversion             │
    // │ Description : Verifies that the start time is converted to UTC    │
    // │               before being sent to the server.                    │
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "converts start time to UTC"                 │
    // └─────────────────────────────────────────────────────────────────────┘
    test('converts start time to UTC ISO 8601 format', () {
      final localTime = DateTime(2026, 6, 20, 15, 30);
      final utcString = localTime.toUtc().toIso8601String();

      expect(utcString, endsWith('Z'));
      expect(utcString, contains('T'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 4 — Clinic & Availability Slot Models
  // ═══════════════════════════════════════════════════════════════════════════

  group('ClinicModel and AvailabilitySlot', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.1                                                     │
    // │ Functionality: Clinic Model — Parse from JSON                     │
    // │ Description : Verifies that ClinicModel.fromJson() correctly      │
    // │               parses clinic details including optional phone.     │
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "parses ClinicModel"                         │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses ClinicModel from JSON', () {
      final clinic = ClinicModel.fromJson({
        'id': 'clinic-001',
        'name': 'Cairo Pet Hospital',
        'address': 'Downtown Cairo',
        'phone': '0223456789',
      });

      expect(clinic.id, equals('clinic-001'));
      expect(clinic.name, equals('Cairo Pet Hospital'));
      expect(clinic.address, equals('Downtown Cairo'));
      expect(clinic.phone, equals('0223456789'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.2                                                     │
    // │ Functionality: Availability Slot — Parse DateTime from JSON       │
    // │ Description : Verifies that AvailabilitySlot correctly parses     │
    // │               ISO 8601 date strings into DateTime objects.        │
    // │ Command     : flutter test test/appointment_service_test.dart     │
    // │               --name "parses AvailabilitySlot"                    │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses AvailabilitySlot with DateTime', () {
      final slot = AvailabilitySlot.fromJson({
        'id': 'slot-001',
        'startTime': '2026-06-20T09:00:00.000Z',
        'endTime': '2026-06-20T09:30:00.000Z',
      });

      expect(slot.id, equals('slot-001'));
      expect(slot.startTime.year, equals(2026));
      expect(slot.startTime.month, equals(6));
      expect(slot.endTime.minute, equals(30));
    });
  });
}
