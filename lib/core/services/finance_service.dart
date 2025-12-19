import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ti3h_k1_jawara/core/models/transaction_model.dart';
import 'package:ti3h_k1_jawara/core/models/fee_model.dart';
import 'package:ti3h_k1_jawara/core/models/fee_transaction_model.dart';
import 'package:ti3h_k1_jawara/core/models/fee_summary_model.dart';
import 'package:ti3h_k1_jawara/core/services/auth_service.dart';

class FinanceService {
  final AuthService authService;
  final String baseUrl =
      "https://prefunctional-albertha-unpessimistically.ngrok-free.dev";

  FinanceService({required this.authService});

  /// Get list of transactions with pagination
  ///
  /// Parameters:
  /// - offset: The starting point for pagination (default: 0)
  /// - limit: The number of items to fetch (default: 10)
  ///
  /// Returns TransactionListResponse containing total, limit, offset, and data
  Future<TransactionListResponse> getTransactions({
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final res = await authService.sendWithAuth((token) {
        return http.get(
          Uri.parse("$baseUrl/finance/list?offset=$offset&limit=$limit"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return TransactionListResponse.fromJson(data);
      } else {
        throw Exception("Failed to load transactions: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching transactions: $e");
    }
  }

  /// Get balance information by period
  ///
  /// Parameters:
  /// - period: 'day', 'month', 'year', or 'all' (default: 'all')
  ///
  /// Returns Map containing:
  /// - total_balance: Total balance (income - expense)
  /// - total_income: Total income
  /// - total_expense: Total expense
  /// - period: The period used
  /// - period_details: Breakdown of finance_income, fee_income, finance_expense
  Future<Map<String, dynamic>> getBalance({String period = 'all'}) async {
    try {
      final res = await authService.sendWithAuth((token) {
        return http.get(
          Uri.parse("$baseUrl/finance/balance?period=$period"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          'total_balance': (data['total_balance'] as num).toDouble(),
          'total_income': (data['total_income'] as num).toDouble(),
          'total_expense': (data['total_expense'] as num).toDouble(),
          'period': data['period'] as String,
          'period_details': data['period_details'] as Map<String, dynamic>,
        };
      } else {
        throw Exception("Failed to load balance: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching balance: $e");
    }
  }

  /// Get list of fees (iuran) with pagination
  ///
  /// Parameters:
  /// - name: Filter by fee name (default: 'iuran')
  /// - offset: The starting point for pagination (default: 0)
  /// - limit: The number of items to fetch (default: 10)
  ///
  /// Returns FeeListResponse containing total, limit, offset, and data
  Future<FeeListResponse> getFees({
    String name = '',
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        'offset': offset.toString(),
        'limit': limit.toString(),
      };
      if (name.trim().isNotEmpty) {
        queryParams['name'] = name.trim();
      }

      final uri = Uri.parse(
        "$baseUrl/finance/fees",
      ).replace(queryParameters: queryParams);

      final res = await authService.sendWithAuth((token) {
        return http.get(
          uri,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return FeeListResponse.fromJson(data);
      } else {
        throw Exception("Failed to load fees: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching fees: $e");
    }
  }

  /// Search transactions by query
  Future<List<TransactionModel>> searchTransactions(String query) async {
    try {
      final response = await getTransactions(offset: 0, limit: 100);

      return response.data.where((transaction) {
        return transaction.name.toLowerCase().contains(query.toLowerCase()) ||
            transaction.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception("Error searching transactions: $e");
    }
  }

  /// Filter transactions by type (keuangan or iuran)
  Future<List<TransactionModel>> filterTransactionsByType({
    required String type,
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final response = await getTransactions(offset: offset, limit: limit);

      return response.data.where((transaction) {
        return transaction.type == type;
      }).toList();
    } catch (e) {
      throw Exception("Error filtering transactions: $e");
    }
  }

  /// Get list of fee transactions for current user's family
  /// Filters by family_id and unpaid status, sorted by due_date ascending
  ///
  /// Returns FeeTransactionListResponse containing filtered transactions
  /// Get fee transactions for the current user's family
  ///
  /// Parameters:
  /// - status: Filter by payment status ('paid', 'unpaid', or 'all' for both)
  /// - limit: Maximum number of records to return (default: 100)
  /// - offset: Offset for pagination (default: 0)
  ///
  /// Returns FeeTransactionListResponse containing the fee transactions
  Future<FeeTransactionListResponse> getFeeTransactions({
    String status = 'unpaid',
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      // Get family ID from AuthService
      final familyId = await authService.getFamilyId();
      if (familyId == null) {
        throw Exception("Failed to get family ID");
      }

      // Build query parameters
      final queryParams = {
        'family_id': familyId,
        'sort_by': 'due_date',
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      // Only add status filter if not 'all'
      if (status != 'all') {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(
        "$baseUrl/finance/fee-transactions",
      ).replace(queryParameters: queryParams);

      final res = await authService.sendWithAuth((token) {
        return http.get(
          uri,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return FeeTransactionListResponse.fromJson(data);
      } else {
        throw Exception("Failed to load fee transactions: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching fee transactions: $e");
    }
  }

  /// Create a new finance transaction with file upload
  ///
  /// Parameters:
  /// - name: Transaction name
  /// - amount: Transaction amount (positive number)
  /// - category: Transaction category
  /// - transactionDate: Transaction date string
  /// - evidenceFilePath: Local file path to evidence (optional)
  /// - isExpense: true for expense, false for income
  ///
  /// Returns Map containing detail message and created transaction data
  Future<Map<String, dynamic>> createTransaction({
    required String name,
    required double amount,
    required String category,
    required String transactionDate,
    String? evidenceFilePath,
    required bool isExpense,
  }) async {
    try {
      // Get token using authService
      final token = await authService.getAccessToken();
      if (token == null) throw Exception('No authentication token');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/finance/transactions"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['accept'] = 'application/json';

      request.fields['name'] = name;
      request.fields['amount'] = amount.toInt().toString();
      request.fields['category'] = category;
      request.fields['transaction_date'] = transactionDate;
      request.fields['is_expense'] = isExpense.toString();

      if (evidenceFilePath != null && evidenceFilePath.isNotEmpty) {
        final file = await http.MultipartFile.fromPath(
          'evidence_file',
          evidenceFilePath,
        );
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['detail'] ??
              "Failed to create transaction: ${res.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error creating transaction: $e");
    }
  }

  /// Get fee details with families transactions
  ///
  /// Parameters:
  /// - feeId: The UUID of the fee
  /// - offset: Pagination offset (default: 0)
  /// - limit: Pagination limit (default: 100)
  ///
  /// Returns Map containing fee details and families with their transactions
  Future<Map<String, dynamic>> getFeeWithFamilies({
    required String feeId,
    int offset = 0,
    int limit = 100,
  }) async {
    try {
      final res = await authService.sendWithAuth((token) {
        return http.get(
          Uri.parse(
            "$baseUrl/finance/fees/$feeId/families?offset=$offset&limit=$limit",
          ),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        throw Exception("Failed to load fee families: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching fee families: $e");
    }
  }

  /// Update fee transaction status with payment evidence
  ///
  /// Parameters:
  /// - feeTransactionId: The ID of the fee transaction to update
  /// - transactionMethod: Payment method (cash, transfer, qris)
  /// - evidenceFilePath: Local file path to payment evidence (required)
  ///
  /// Returns Map containing detail message and updated transaction data
  Future<Map<String, dynamic>> updateFeeTransaction({
    required int feeTransactionId,
    required String transactionMethod,
    required String evidenceFilePath,
  }) async {
    try {
      final token = await authService.getAccessToken();
      if (token == null) throw Exception('No authentication token');

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse("$baseUrl/finance/fee-transactions/$feeTransactionId"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['accept'] = 'application/json';

      request.fields['transaction_method'] = transactionMethod;

      final file = await http.MultipartFile.fromPath(
        'evidence_file',
        evidenceFilePath,
      );
      request.files.add(file);

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['detail'] ??
              "Failed to update fee transaction: ${res.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error updating fee transaction: $e");
    }
  }

  /// Create a new fee (tagih iuran)
  ///
  /// Parameters:
  /// - feeName: Name of the fee
  /// - amount: Fee amount per family
  /// - chargeDate: Date when fee is charged (YYYY-MM-DD)
  /// - dueDate: Due date for payment (YYYY-MM-DD)
  /// - description: Description of the fee
  /// - feeCategory: Category of the fee
  ///
  /// Returns Map containing detail message, fee data, and transactions_created count
  Future<Map<String, dynamic>> createFee({
    required String feeName,
    required double amount,
    required String chargeDate,
    required String dueDate,
    required String description,
    required String feeCategory,
  }) async {
    try {
      final res = await authService.sendWithAuth((token) {
        return http.post(
          Uri.parse("$baseUrl/finance/fees"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
            "accept": "application/json",
          },
          body: jsonEncode({
            "fee_name": feeName,
            "amount": amount.toInt(),
            "charge_date": chargeDate,
            "due_date": dueDate,
            "description": description,
            "fee_category": feeCategory,
          }),
        );
      });

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['detail'] ?? "Failed to create fee: ${res.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error creating fee: $e");
    }
  }

  /// Get fee summary for a specific user
  ///
  /// Parameters:
  /// - userId: The UUID of the user
  ///
  /// Returns FeeSummaryModel containing:
  /// - total_unpaid_amount: Total amount of unpaid fees
  /// - total_unpaid_count: Number of unpaid fees
  Future<FeeSummaryModel> getFeeSummary(String userId) async {
    try {
      final res = await authService.sendWithAuth((token) {
        return http.get(
          Uri.parse("$baseUrl/finance/fee-summary/$userId"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return FeeSummaryModel.fromJson(data);
      } else {
        throw Exception("Failed to load fee summary: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching fee summary: $e");
    }
  }
}
