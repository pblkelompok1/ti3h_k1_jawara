import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ti3h_k1_jawara/core/models/transaction_model.dart';
import 'package:ti3h_k1_jawara/core/models/fee_model.dart';
import 'package:ti3h_k1_jawara/core/services/auth_service.dart';

class FinanceService {
  final AuthService authService;
  final String baseUrl = "https://presumptive-renee-uncircled.ngrok-free.dev";

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
    String name = 'iuran',
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final res = await authService.sendWithAuth((token) {
        return http.get(
          Uri.parse("$baseUrl/finance/fees?name=$name&offset=$offset&limit=$limit"),
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
}
