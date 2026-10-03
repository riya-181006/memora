import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  String? _token;

  bool get hasToken => _token != null && _token!.isNotEmpty;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (hasToken) 'Authorization': 'Bearer $_token',
  };

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  Future<dynamic> get(String path) {
    return _send(() => http.get(_uri(path), headers: _headers));
  }

  Future<dynamic> post(
      String path, {
        Map<String, dynamic>? body,
        Duration timeout = const Duration(seconds: 30),
      }) {
    return _send(
          () => http.post(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body ?? {}),
      ),
      timeout: timeout,
    );
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) {
    return _send(
          () => http.put(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body ?? {}),
      ),
    );
  }

  Future<dynamic> delete(String path) {
    return _send(() => http.delete(_uri(path), headers: _headers));
  }

  Future<dynamic> _send(
      Future<http.Response> Function() request, {
        Duration timeout = const Duration(seconds: 30),
      }) async {
    try {
      final res = await request().timeout(timeout);
      return _handle(res);
    } on SocketException {
      throw ApiException('No connection. Check your internet and server.');
    } on TimeoutException {
      throw ApiException('Request timed out. Try again.');
    } on FormatException {
      throw ApiException('Got a bad response from the server.');
    }
  }

  dynamic _handle(http.Response res) {
    dynamic data;
    if (res.body.isNotEmpty) {
      data = jsonDecode(res.body);
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    final message = (data is Map && data['message'] is String)
        ? data['message'] as String
        : 'Something went wrong (${res.statusCode})';

    throw ApiException(message, statusCode: res.statusCode);
  }
}