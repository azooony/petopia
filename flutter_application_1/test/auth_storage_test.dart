// ============================================================================
// FILE: auth_storage_test.dart
// SERVICE UNDER TEST: AuthStorage (lib/services/auth_storage.dart)
// DESCRIPTION: Unit tests for local session persistence — saving, retrieving,
//              and clearing authentication tokens using SharedPreferences.
//
// HOW TO RUN:
//   flutter test test/auth_storage_test.dart
//
// HOW TO RUN WITH VERBOSE OUTPUT:
//   flutter test test/auth_storage_test.dart --reporter expanded
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/services/auth_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 1 — saveSession
  // ═══════════════════════════════════════════════════════════════════════════

  group('AuthStorage.saveSession', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.1                                                     │
    // │ Functionality: Save Session — Persists Token, UserId, and Role    │
    // │ Description : Verifies that saveSession() correctly stores all    │
    // │               three values (auth_token, user_id, user_role) in    │
    // │               SharedPreferences.                                  │
    // │ Command     : flutter test test/auth_storage_test.dart            │
    // │               --name "persists token, userId, and role"           │
    // └─────────────────────────────────────────────────────────────────────┘
    test('persists token, userId, and role', () async {
      await AuthStorage.saveSession(
        token: 'test-jwt-token',
        userId: 'user-abc-123',
        role: 'PET_OWNER',
      );

      expect(await AuthStorage.getToken(), equals('test-jwt-token'));
      expect(await AuthStorage.getUserId(), equals('user-abc-123'));
      expect(await AuthStorage.getRole(), equals('PET_OWNER'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.2                                                     │
    // │ Functionality: Save Session — Overwrites Previous Session         │
    // │ Description : Verifies that calling saveSession() a second time   │
    // │               replaces the old values (e.g., after re-login).     │
    // │ Command     : flutter test test/auth_storage_test.dart            │
    // │               --name "overwrites previous session"                │
    // └─────────────────────────────────────────────────────────────────────┘
    test('overwrites previous session', () async {
      await AuthStorage.saveSession(
        token: 'old-token',
        userId: 'old-user',
        role: 'PET_OWNER',
      );

      await AuthStorage.saveSession(
        token: 'new-token',
        userId: 'new-user',
        role: 'VET',
      );

      expect(await AuthStorage.getToken(), equals('new-token'));
      expect(await AuthStorage.getUserId(), equals('new-user'));
      expect(await AuthStorage.getRole(), equals('VET'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 2 — getToken / getUserId / getRole
  // ═══════════════════════════════════════════════════════════════════════════

  group('AuthStorage getters', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.1                                                     │
    // │ Functionality: Get Token — Returns Null When No Session Exists    │
    // │ Description : Verifies that getToken() returns null before any    │
    // │               session has been saved (fresh install scenario).    │
    // │ Command     : flutter test test/auth_storage_test.dart            │
    // │               --name "getToken returns null when empty"           │
    // └─────────────────────────────────────────────────────────────────────┘
    test('getToken returns null when empty', () async {
      expect(await AuthStorage.getToken(), isNull);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.2                                                     │
    // │ Functionality: Get UserId — Returns Null When No Session Exists   │
    // │ Description : Verifies that getUserId() returns null before any   │
    // │               session has been saved.                             │
    // │ Command     : flutter test test/auth_storage_test.dart            │
    // │               --name "getUserId returns null when empty"          │
    // └─────────────────────────────────────────────────────────────────────┘
    test('getUserId returns null when empty', () async {
      expect(await AuthStorage.getUserId(), isNull);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.3                                                     │
    // │ Functionality: Get Role — Returns Null When No Session Exists     │
    // │ Description : Verifies that getRole() returns null before any     │
    // │               session has been saved.                             │
    // │ Command     : flutter test test/auth_storage_test.dart            │
    // │               --name "getRole returns null when empty"            │
    // └─────────────────────────────────────────────────────────────────────┘
    test('getRole returns null when empty', () async {
      expect(await AuthStorage.getRole(), isNull);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.4                                                     │
    // │ Functionality: Get Token — Returns Saved Token                    │
    // │ Description : Verifies that getToken() returns the correct        │
    // │               token after a session is saved.                     │
    // │ Command     : flutter test test/auth_storage_test.dart            │
    // │               --name "getToken returns saved token"               │
    // └─────────────────────────────────────────────────────────────────────┘
    test('getToken returns saved token', () async {
      await AuthStorage.saveSession(
        token: 'my-jwt',
        userId: 'uid',
        role: 'PET_OWNER',
      );
      expect(await AuthStorage.getToken(), equals('my-jwt'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 3 — isLoggedIn
  // ═══════════════════════════════════════════════════════════════════════════

  group('AuthStorage.isLoggedIn', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.1                                                     │
    // │ Functionality: Is Logged In — Returns False Before Login          │
    // │ Description : Verifies that isLoggedIn() returns false when no    │
    // │               token is stored (app freshly installed).            │
    // │ Command     : flutter test test/auth_storage_test.dart            │
    // │               --name "returns false when no token"                │
    // └─────────────────────────────────────────────────────────────────────┘
    test('returns false when no token is stored', () async {
      expect(await AuthStorage.isLoggedIn(), isFalse);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.2                                                     │
    // │ Functionality: Is Logged In — Returns True After Login            │
    // │ Description : Verifies that isLoggedIn() returns true after a     │
    // │               valid session has been saved.                       │
    // │ Command     : flutter test test/auth_storage_test.dart            │
    // │               --name "returns true after saving session"          │
    // └─────────────────────────────────────────────────────────────────────┘
    test('returns true after saving session', () async {
      await AuthStorage.saveSession(
        token: 'valid-token',
        userId: 'user-1',
        role: 'VET',
      );
      expect(await AuthStorage.isLoggedIn(), isTrue);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.3                                                     │
    // │ Functionality: Is Logged In — Returns False After Empty Token     │
    // │ Description : Verifies edge case where an empty string token is   │
    // │               stored (should still be treated as not logged in).  │
    // │ Command     : flutter test test/auth_storage_test.dart            │
    // │               --name "returns false for empty string token"       │
    // └─────────────────────────────────────────────────────────────────────┘
    test('returns false for empty string token', () async {
      SharedPreferences.setMockInitialValues({'auth_token': ''});
      expect(await AuthStorage.isLoggedIn(), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 4 — clear
  // ═══════════════════════════════════════════════════════════════════════════

  group('AuthStorage.clear', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.1                                                     │
    // │ Functionality: Clear Session — Removes All Auth Data              │
    // │ Description : Verifies that clear() removes the token, userId,    │
    // │               and role from SharedPreferences (logout scenario).  │
    // │ Command     : flutter test test/auth_storage_test.dart            │
    // │               --name "removes all auth data"                      │
    // └─────────────────────────────────────────────────────────────────────┘
    test('removes all auth data', () async {
      await AuthStorage.saveSession(
        token: 'token-to-clear',
        userId: 'user-to-clear',
        role: 'PET_OWNER',
      );

      await AuthStorage.clear();

      expect(await AuthStorage.getToken(), isNull);
      expect(await AuthStorage.getUserId(), isNull);
      expect(await AuthStorage.getRole(), isNull);
      expect(await AuthStorage.isLoggedIn(), isFalse);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.2                                                     │
    // │ Functionality: Clear Session — Safe When Already Empty            │
    // │ Description : Verifies that calling clear() when no session       │
    // │               exists does not throw an error.                     │
    // │ Command     : flutter test test/auth_storage_test.dart            │
    // │               --name "does not throw when already empty"          │
    // └─────────────────────────────────────────────────────────────────────┘
    test('does not throw when already empty', () async {
      // Should not throw even when nothing is stored
      await expectLater(AuthStorage.clear(), completes);
    });
  });
}
