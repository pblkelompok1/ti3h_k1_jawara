import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/features/admin/provider/mock_admin_providers.dart';
import 'package:intl/intl.dart';

class AdminFinanceView extends ConsumerWidget {
  const AdminFinanceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(financeTransactionsProviderMock);
    final filters = ref.watch(financeFilterProviderMock);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Keuangan',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primary(context)),
            onPressed: () => _showFilterDialog(context, ref, filters),
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(financeTransactionsProviderMock);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final isIncome = transaction.type == 'income';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border(context),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isIncome ? Colors.green : Colors.red)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isIncome ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.category,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              transaction.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary(context),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (transaction.residentName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                transaction.residentName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary(context),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(transaction.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isIncome ? '+' : '-'} ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(transaction.amount)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.redAccent(context),
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur tambah transaksi akan segera hadir'),
            ),
          );
        },
        backgroundColor: AppColors.primary(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, String?> currentFilters,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter Transaksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipe:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Semua'),
                  selected: currentFilters['type'] == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(financeFilterProviderMock.notifier).state = {
                        ...currentFilters,
                        'type': null,
                      };
                      Navigator.pop(dialogContext);
                    }
                  },
                ),
                FilterChip(
                  label: const Text('Pemasukan'),
                  selected: currentFilters['type'] == 'income',
                  onSelected: (selected) {
                    ref.read(financeFilterProviderMock.notifier).state = {
                      ...currentFilters,
                      'type': selected ? 'income' : null,
                    };
                    Navigator.pop(dialogContext);
                  },
                ),
                FilterChip(
                  label: const Text('Pengeluaran'),
                  selected: currentFilters['type'] == 'expense',
                  onSelected: (selected) {
                    ref.read(financeFilterProviderMock.notifier).state = {
                      ...currentFilters,
                      'type': selected ? 'expense' : null,
                    };
                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(financeFilterProviderMock.notifier).state = {};
              Navigator.pop(dialogContext);
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      // Fallback jika locale belum diinisialisasi
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
