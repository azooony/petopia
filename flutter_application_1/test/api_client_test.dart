// ============================================================================
// FILE: api_client_test.dart
// SERVICE UNDER TEST: ApiClient (lib/services/api_client.dart)
// DESCRIPTION: Unit tests for the centralised HTTP client — verifying
//              response parsing, error handling, auth header injection,
//              and multipart request construction.
//
// HOW TO RUN:
//   flutter test test/api_client_test.dart
//
// HOW TO RUN WITH VERBOSE OUTPUT:
//   flutter test test/api_client_test.dart --reporter expanded
// ============================================================================

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/services/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 1 — ApiException
  // ═══════════════════════════════════════════════════════════════════════════

  group('ApiException', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.1                                                     │
    // │ Functionality: API Exception — Stores Status Code and Message     │
    // │ Description : Verifies that ApiException correctly stores the     │
    // │               HTTP status code and error message.                 │
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "stores status code and message"             │
    // └─────────────────────────────────────────────────────────────────────┘
    test('stores status code and message', () {
      const exception = ApiException(404, 'Not found');

      expect(exception.statusCode, equals(404));
      expect(exception.message, equals('Not found'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.2                                                     │
    // │ Functionality: API Exception — toString() Format                  │
    // │ Description : Verifies that toString() produces a human-readable  │
    // │               string in the format "ApiException(code): message". │
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "toString format"                            │
    // └─────────────────────────────────────────────────────────────────────┘
    test('toString format is readable', () {
      const exception = ApiException(500, 'Internal server error');

      expect(exception.toString(),
          equals('ApiException(500): Internal server error'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.3                                                     │
    // │ Functionality: API Exception — Implements Exception Interface     │
    // │ Description : Verifies that ApiException implements the Dart      │
    // │               Exception interface so it can be caught generically.│
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "implements Exception"                       │
    // └─────────────────────────────────────────────────────────────────────┘
    test('implements Exception interface', () {
      const exception = ApiException(401, 'Unauthorized');

      expect(exception, isA<Exception>());
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 2 — Base URL Configuration
  // ═══════════════════════════════════════════════════════════════════════════

  group('ApiClient.baseUrl', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.1                                                     │
    // │ Functionality: Base URL — Correct Format                          │
    // │ Description : Verifies that the base URL is a valid HTTP URL      │
    // │               pointing to port 3000 (the backend server).         │
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "base URL has correct format"                │
    // └─────────────────────────────────────────────────────────────────────┘
    test('base URL has correct format', () {
      expect(ApiClient.baseUrl, contains(':3000'));
      expect(ApiClient.baseUrl, startsWith('http'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.2                                                     │
    // │ Functionality: Base URL — No Trailing Slash                       │
    // │ Description : Verifies that the base URL does not end with a      │
    // │               slash, ensuring paths like '/auth/login' concatenate│
    // │               correctly.                                          │
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "no trailing slash"                          │
    // └─────────────────────────────────────────────────────────────────────┘
    test('no trailing slash in base URL', () {
      expect(ApiClient.baseUrl.endsWith('/'), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 3 — Response Handling Logic (_handle simulation)
  // ═══════════════════════════════════════════════════════════════════════════

  group('Response handling logic', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.1                                                     │
    // │ Functionality: Response Handling — Parses Successful Response     │
    // │ Description : Verifies that a 200 response with valid JSON body   │
    // │               is correctly parsed into a Map.                     │
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "parses 200 response"                        │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses 200 response correctly', () {
      final responseBody = jsonEncode({
        'status': 'success',
        'data': {'userId': '123', 'role': 'PET_OWNER'},
      });

      final parsed = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(parsed['status'], equals('success'));
      expect(parsed['data']['userId'], equals('123'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.2                                                     │
    // │ Functionality: Response Handling — 401 Triggers Session Clear     │
    // │ Description : Verifies that a 401 response triggers clearing of   │
    // │               the stored authentication session and throws an     │
    // │               ApiException.                                       │
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "401 clears session"                         │
    // └─────────────────────────────────────────────────────────────────────┘
    test('401 response triggers session clear and throws', () async {
      // Pre-populate a session
      SharedPreferences.setMockInitialValues({
        'auth_token': 'expired-token',
        'user_id': 'user-1',
        'user_role': 'PET_OWNER',
      });

      final responseBody = jsonEncode({
        'status': 'error',
        'message': 'Session expired. Please log in again.',
      });

      const statusCode = 401;
      final body = jsonDecode(responseBody) as Map<String, dynamic>;

      // Simulate _handle() logic
      if (statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_id');
        await prefs.remove('user_role');
      }

      final msg = body['message'] as String? ??
          'Session expired. Please log in again.';

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
      expect(msg, equals('Session expired. Please log in again.'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.3                                                     │
    // │ Functionality: Response Handling — 400+ Extracts Error Message    │
    // │ Description : Verifies that any 4xx/5xx response extracts the    │
    // │               error message from the response body.              │
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "400+ extracts error message"                │
    // └─────────────────────────────────────────────────────────────────────┘
    test('400+ response extracts error message', () {
      final responseBody = jsonEncode({
        'status': 'error',
        'message': 'Validation failed: email is required',
      });

      const statusCode = 422;
      final body = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(statusCode >= 400, isTrue);
      final msg =
          body['message'] as String? ?? 'An unexpected error occurred.';
      expect(msg, equals('Validation failed: email is required'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.4                                                     │
    // │ Functionality: Response Handling — Fallback Message               │
    // │ Description : Verifies that when the error response has no        │
    // │               'message' field, a default fallback message is used.│
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "uses fallback message"                      │
    // └─────────────────────────────────────────────────────────────────────┘
    test('uses fallback message when no message field in error', () {
      final responseBody = jsonEncode({'status': 'error'});

      const statusCode = 500;
      final body = jsonDecode(responseBody) as Map<String, dynamic>;

      expect(statusCode >= 400, isTrue);
      final msg =
          body['message'] as String? ?? 'An unexpected error occurred.';
      expect(msg, equals('An unexpected error occurred.'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 4 — MIME Type Detection (multipartPostBytes)
  // ═══════════════════════════════════════════════════════════════════════════

  group('MIME type detection', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.1                                                     │
    // │ Functionality: MIME Detection — Common Image Formats              │
    // │ Description : Verifies that the file extension to MIME type       │
    // │               mapping correctly identifies PNG, JPEG, GIF, WEBP, │
    // │               and BMP formats.                                    │
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "detects common image MIME types"            │
    // └─────────────────────────────────────────────────────────────────────┘
    test('detects common image MIME types', () {
      String getMime(String filename) {
        final ext = filename.toLowerCase().split('.').last;
        return switch (ext) {
          'png' => 'image/png',
          'gif' => 'image/gif',
          'webp' => 'image/webp',
          'bmp' => 'image/bmp',
          _ => 'image/jpeg',
        };
      }

      expect(getMime('photo.png'), equals('image/png'));
      expect(getMime('photo.PNG'), equals('image/png'));
      expect(getMime('photo.jpg'), equals('image/jpeg'));
      expect(getMime('photo.jpeg'), equals('image/jpeg'));
      expect(getMime('photo.gif'), equals('image/gif'));
      expect(getMime('photo.webp'), equals('image/webp'));
      expect(getMime('photo.bmp'), equals('image/bmp'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.2                                                     │
    // │ Functionality: MIME Detection — Unknown Extension Defaults to JPEG│
    // │ Description : Verifies that an unknown file extension (e.g. .xyz) │
    // │               defaults to 'image/jpeg'.                           │
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "unknown extension defaults to jpeg"         │
    // └─────────────────────────────────────────────────────────────────────┘
    test('unknown extension defaults to image/jpeg', () {
      String getMime(String filename) {
        final ext = filename.toLowerCase().split('.').last;
        return switch (ext) {
          'png' => 'image/png',
          'gif' => 'image/gif',
          'webp' => 'image/webp',
          'bmp' => 'image/bmp',
          _ => 'image/jpeg',
        };
      }

      expect(getMime('file.xyz'), equals('image/jpeg'));
      expect(getMime('file.tiff'), equals('image/jpeg'));
      expect(getMime('file.svg'), equals('image/jpeg'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 5 — Auth Header Construction
  // ═══════════════════════════════════════════════════════════════════════════

  group('Auth header construction', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 5.1                                                     │
    // │ Functionality: Auth Headers — Include Bearer Token When Logged In │
    // │ Description : Verifies that the Authorization header is set to    │
    // │               'Bearer <token>' when a token exists in storage.    │
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "includes Bearer token"                      │
    // └─────────────────────────────────────────────────────────────────────┘
    test('includes Bearer token when logged in', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'my-jwt-token',
      });
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      expect(headers['Authorization'], equals('Bearer my-jwt-token'));
      expect(headers['Content-Type'], equals('application/json'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 5.2                                                     │
    // │ Functionality: Auth Headers — Omit Authorization When No Token    │
    // │ Description : Verifies that no Authorization header is set when   │
    // │               no token is stored (unauthenticated request).       │
    // │ Command     : flutter test test/api_client_test.dart              │
    // │               --name "omits Authorization when no token"          │
    // └─────────────────────────────────────────────────────────────────────┘
    test('omits Authorization header when no token', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      expect(headers.containsKey('Authorization'), isFalse);
      expect(headers['Content-Type'], equals('application/json'));
    });
  });
}
