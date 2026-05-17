import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'auth_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  // Android emulator reaches the host machine via 10.0.2.2.
  // For iOS simulator use localhost. For physical device use your machine's LAN IP.
  static final String baseUrl =
      kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _authHeaders(),
    );
    return _handle(response);
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: await _authHeaders(),
    );
    return _handle(response);
  }

  /// Sends a multipart/form-data POST using a byte array (works on Flutter web).
  static Future<Map<String, dynamic>> multipartPostBytes(
    String path, {
    required Map<String, String> fields,
    required List<int> bytes,
    required String filename,
    required String fileField,
  }) async {
    final token = await AuthStorage.getToken();

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields.addAll(fields);
    final ext = filename.toLowerCase().split('.').last;
    final mime = switch (ext) {
      'png'  => 'image/png',
      'gif'  => 'image/gif',
      'webp' => 'image/webp',
      'bmp'  => 'image/bmp',
      _      => 'image/jpeg',
    };
    request.files.add(
      http.MultipartFile.fromBytes(
        fileField, bytes,
        filename: filename,
        contentType: MediaType.parse(mime),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _handle(response);
  }

  /// Sends a multipart/form-data POST (for file uploads).
  static Future<Map<String, dynamic>> multipartPost(
    String path, {
    required Map<String, String> fields,
    required File file,
    required String fileField,
  }) async {
    final token = await AuthStorage.getToken();

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields.addAll(fields);
    request.files.add(
      await http.MultipartFile.fromPath(fileField, file.path),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _handle(response);
  }

  /// Sends a multipart/form-data POST with multiple byte-array files.
  /// [files] is a list of records: (field name, bytes, filename).
  static Future<Map<String, dynamic>> multipartPostMultipleFiles(
    String path, {
    Map<String, String> fields = const {},
    required List<Map<String, dynamic>> files,
  }) async {
    final token = await AuthStorage.getToken();
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields.addAll(fields);
    for (final f in files) {
      final fieldName = f['field'] as String;
      final bytes = f['bytes'] as List<int>;
      final filename = f['filename'] as String;
      final ext = filename.toLowerCase().split('.').last;
      final mime = switch (ext) {
        'png'  => 'image/png',
        'gif'  => 'image/gif',
        'webp' => 'image/webp',
        'bmp'  => 'image/bmp',
        _      => 'image/jpeg',
      };
      request.files.add(http.MultipartFile.fromBytes(
        fieldName, bytes,
        filename: filename,
        contentType: MediaType.parse(mime),
      ));
    }
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _handle(response);
  }

  static Map<String, dynamic> _handle(http.Response response) {
    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 401) {
      // Token expired — clear local session so the app can re-login.
      AuthStorage.clear();
      throw const ApiException(401, 'Session expired. Please log in again.');
    }

    if (response.statusCode >= 400) {
      final msg = body['message'] as String? ?? 'An unexpected error occurred.';
      throw ApiException(response.statusCode, msg);
    }

    return body;
  }
}
