import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/letter_type.dart';
import '../models/letter_transaction.dart';

class LetterApiService {
  final baseUrl = "https://presumptive-renee-uncircled.ngrok-free.dev";
  final storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: "access_token");
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== Get Letter Types ====================
  
  Future<List<LetterType>> getLetterTypes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/letters'),
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => LetterType.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load letter types: ${response.statusCode}');
    }
  }

  // ==================== Get Letter Type Detail ====================
  
  Future<LetterType> getLetterTypeDetail(String letterId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/letters/types/$letterId'),
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return LetterType.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load letter type: ${response.statusCode}');
    }
  }

  // ==================== Create Letter Request ====================
  
  Future<LetterTransaction> createLetterRequest({
    required String letterId,
    required Map<String, dynamic> data,
    required String userId,
  }) async {
    final requestBody = {
      'letter_id': letterId,
      'data': data,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/letters/requests?user_id=$userId'),
      headers: await _getHeaders(),
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 201) {
      return LetterTransaction.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to create letter request');
    }
  }

  // ==================== Get Letter Requests (with filters) ====================
  
  Future<Map<String, dynamic>> getLetterRequests({
    String? userId,
    String? letterId,
    String? status,
    int offset = 0,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'offset': offset.toString(),
      'limit': limit.toString(),
    };

    if (userId != null && userId.isNotEmpty) {
      queryParams['user_id'] = userId;
    }

    if (letterId != null && letterId.isNotEmpty) {
      queryParams['letter_id'] = letterId;
    }

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final uri = Uri.parse('$baseUrl/letters/requests').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'total': data['total'] as int,
        'data': (data['data'] as List)
            .map((json) => LetterTransaction.fromJson(json))
            .toList(),
      };
    } else {
      throw Exception('Failed to load requests: ${response.statusCode}');
    }
  }

  // ==================== Get Letter Request Detail ====================
  
  Future<LetterTransaction> getLetterRequestDetail(String transactionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/letters/requests/$transactionId'),
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return LetterTransaction.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load request detail: ${response.statusCode}');
    }
  }

  // ==================== Update Request Status (Admin) ====================
  
  Future<LetterTransaction> updateRequestStatus({
    required String transactionId,
    required String status,
    String? rejectionReason,
  }) async {
    final requestBody = {
      'status': status,
      if (rejectionReason != null && rejectionReason.isNotEmpty)
        'rejection_reason': rejectionReason,
    };

    final response = await http.patch(
      Uri.parse('$baseUrl/letters/requests/$transactionId/status'),
      headers: await _getHeaders(),
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      return LetterTransaction.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to update status');
    }
  }

  // ==================== Delete Letter Request ====================
  
  Future<void> deleteLetterRequest(String transactionId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/letters/requests/$transactionId'),
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete request: ${response.statusCode}');
    }
  }

  // ==================== Download PDF ====================
  
  Future<File> downloadPdf({
    required String pdfPath,
    required String fileName,
  }) async {
    // pdfPath example: "storage/letters/domisili_abc123.pdf"
    // Use /files endpoint with encoded path
    final String pdfUrl;
    if (pdfPath.startsWith('http')) {
      pdfUrl = pdfPath;
    } else {
      final encodedPath = Uri.encodeComponent(pdfPath);
      pdfUrl = '$baseUrl/files/$encodedPath';
    }

    final response = await http.get(
      Uri.parse(pdfUrl),
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Failed to download PDF: ${response.statusCode}');
    }
  }

  // ==================== Get PDF URL ====================
  
  String getPdfUrl(String pdfPath) {
    if (pdfPath.startsWith('http')) {
      return pdfPath;
    }
    // Use /files endpoint with encoded path
    // Example: storage/letters/abc.pdf -> /files/storage%2Fletters%2Fabc.pdf
    final encodedPath = Uri.encodeComponent(pdfPath);
    return '$baseUrl/files/$encodedPath';
  }
}
