import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.193.194:8080/api'; // For your network
  // static const String baseUrl = 'http://10.0.2.2:8080/api'; // For Android emulator
  // static const String baseUrl = 'http://localhost:8080/api'; // For web

  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._internal();
  ApiService._internal();

  // Initialize service
  Future<void> initialize() async {
    // No authentication needed
  }

  // Get headers
  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
    };
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body: ${response.body}');
    
    try {
      final body = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        throw ApiException(
          message: body['error'] ?? 'Request failed',
          statusCode: response.statusCode,
          details: body['details'],
        );
      }
    } catch (e) {
      print('Error parsing response: $e');
      throw ApiException(
        message: 'Failed to parse response: $e',
        statusCode: response.statusCode,
        details: null,
      );
    }
  }



  // Book Methods
  Future<List<Map<String, dynamic>>> getBooks({String? query, String? genre}) async {
    final queryParams = <String, String>{};
    if (query != null && query.isNotEmpty) queryParams['query'] = query;
    if (genre != null && genre != 'All') queryParams['genre'] = genre;

    final uri = Uri.parse('$baseUrl/books').replace(queryParameters: queryParams);
    print('Fetching books from: $uri');
    
    final response = await http.get(uri, headers: _headers);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final data = _handleResponse(response);
    final books = List<Map<String, dynamic>>.from(data['data']);
    print('Parsed books: ${books.length}');
    return books;
  }

  Future<Map<String, dynamic>> getBook(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/books/$id'),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createBook({
    required String title,
    required String author,
    String? year,
    required String genre,
    String? imagePath,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books'),
      headers: _headers,
      body: json.encode({
        'title': title,
        'author': author,
        'year': year,
        'genre': genre,
        'imagePath': imagePath ?? '',
        'description': description ?? '',
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateBook({
    required String id,
    required String title,
    required String author,
    String? year,
    required String genre,
    String? imagePath,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/$id'),
      headers: _headers,
      body: json.encode({
        'title': title,
        'author': author,
        'year': year,
        'genre': genre,
        'imagePath': imagePath ?? '',
        'description': description ?? '',
      }),
    );

    return _handleResponse(response);
  }

  Future<void> deleteBook(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/books/$id'),
      headers: _headers,
    );

    _handleResponse(response);
  }

  // Image Upload Methods
  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    print('Starting image upload...');
    print('File path: ${imageFile.path}');
    print('File size: ${await imageFile.length()} bytes');
    
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload/image'),
    );

    // Add the image file
    final stream = http.ByteStream(imageFile.openRead());
    final length = await imageFile.length();
    final filename = imageFile.path.split('/').last;
    print('File details:');
    print('  - Path: ${imageFile.path}');
    print('  - Filename: $filename');
    print('  - Size: $length bytes');
    print('  - Extension: ${filename.split('.').last.toLowerCase()}');
    
    final multipartFile = http.MultipartFile(
      'image',
      stream,
      length,
      filename: filename,
    );
    request.files.add(multipartFile);
    
    print('Sending request to: ${request.url}');
    print('Request headers: ${request.headers}');
    print('Files in request: ${request.files.length}');

    final response = await request.send();
    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    
    final responseData = await response.stream.bytesToString();
    print('Response body: $responseData');
    
    final body = json.decode(responseData);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('Upload successful: $body');
      return body;
    } else {
      print('Upload failed: $body');
      throw ApiException(
        message: body['error'] ?? 'Upload failed',
        statusCode: response.statusCode,
        details: body['details'],
      );
    }
  }

  Future<void> deleteImage(String filename) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/upload/image/$filename'),
      headers: _headers,
    );

    _handleResponse(response);
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    print('Testing health check...');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      print('Health check failed: $e');
      rethrow;
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final List<dynamic>? details;

  ApiException({
    required this.message,
    required this.statusCode,
    this.details,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
} 