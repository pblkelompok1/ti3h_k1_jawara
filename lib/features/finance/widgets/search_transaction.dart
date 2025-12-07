import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/models/transaction_model.dart';
import 'package:ti3h_k1_jawara/core/models/fee_model.dart';
import 'package:ti3h_k1_jawara/core/services/finance_service.dart';
import 'transaction_tile.dart';

import 'finance_detail_page.dart';
import 'iuran_detail_page.dart';
import 'otomasi_detail_page.dart';

class SearchTransaction extends StatefulWidget {
  final bool isDark;
  final FinanceService financeService;
  final ScrollController? parentScrollController;

  const SearchTransaction({
    super.key,
    required this.isDark,
    required this.financeService,
    this.parentScrollController,
  });

  @override
  State<SearchTransaction> createState() => _SearchTransactionState();
}

class _SearchTransactionState extends State<SearchTransaction> {
  final TextEditingController controller = TextEditingController();
  
  String searchQuery = "";
  String selectedFilter = "Keuangan";
  
  List<TransactionModel> _transactions = [];
  List<FeeModel> _fees = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    if (widget.parentScrollController != null) {
      widget.parentScrollController!.addListener(_onScroll);
    }
    _loadData();
  }

  @override
  void dispose() {
    controller.dispose();
    if (widget.parentScrollController != null) {
      widget.parentScrollController!.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (widget.parentScrollController == null) return;
    
    final scrollController = widget.parentScrollController!;
    if (scrollController.position.pixels >= 
        scrollController.position.maxScrollExtent - 200 && 
        !_isLoading && 
        _hasMore) {
      _loadMoreData();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentOffset = 0;
      _transactions.clear();
      _fees.clear();
    });

    try {
      if (selectedFilter == "Keuangan") {
        final response = await widget.financeService.getTransactions(
          offset: _currentOffset,
          limit: _limit,
        );
        setState(() {
          _transactions = response.data;
          _hasMore = response.hasMore;
          _currentOffset += _limit;
          _isLoading = false;
        });
      } else if (selectedFilter == "Iuran") {
        final response = await widget.financeService.getFees(
          offset: _currentOffset,
          limit: _limit,
        );
        setState(() {
          _fees = response.data; // Tampilkan semua iuran
          _hasMore = response.hasMore;
          _currentOffset += _limit;
          _isLoading = false;
        });
      } else {
        // Otomasi - filter yang automation_mode != 'off'
        final response = await widget.financeService.getFees(
          offset: _currentOffset,
          limit: _limit,
        );
        setState(() {
          _fees = response.data.where((fee) => 
            fee.automationMode.toLowerCase() != 'off'
          ).toList();
          _hasMore = response.hasMore;
          _currentOffset += _limit;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (selectedFilter == "Keuangan") {
        final response = await widget.financeService.getTransactions(
          offset: _currentOffset,
          limit: _limit,
        );
        setState(() {
          _transactions.addAll(response.data);
          _hasMore = response.hasMore;
          _currentOffset += _limit;
          _isLoading = false;
        });
      } else if (selectedFilter == "Iuran") {
        final response = await widget.financeService.getFees(
          offset: _currentOffset,
          limit: _limit,
        );
        setState(() {
          _fees.addAll(response.data); // Tampilkan semua iuran
          _hasMore = response.hasMore;
          _currentOffset += _limit;
          _isLoading = false;
        });
      } else {
        // Otomasi - filter yang automation_mode != 'off'
        final response = await widget.financeService.getFees(
          offset: _currentOffset,
          limit: _limit,
        );
        setState(() {
          _fees.addAll(response.data.where((fee) => 
            fee.automationMode.toLowerCase() != 'off'
          ));
          _hasMore = response.hasMore;
          _currentOffset += _limit;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void filterSearch(String value) {
    setState(() => searchQuery = value.toLowerCase());
  }

  void changeFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    _loadData(); // Reload data when filter changes
  }

  void _openDetail(dynamic item) {
    Map<String, dynamic> data;
    
    if (item is TransactionModel) {
      data = {
        'title': item.name,
        'time': item.transactionDate,
        'category': item.displayCategory,
        'type': item.type,
        'amount': item.amount.abs(),
        'isIncome': item.isIncome,
        'evidence_path': item.evidencePath,
      };
    } else if (item is FeeModel) {
      data = {
        'title': item.feeName,
        'time': item.chargeDate,
        'category': item.feeCategory,
        'type': item.isAutomated ? 'otomasi' : 'iuran',
        'amount': item.amount,
        'isIncome': item.isIncome,
        'description': item.description,
        'fee_id': item.feeId,
        'automation_mode': item.automationMode,
      };
    } else {
      return;
    }

    final type = data['type'];
    switch (type) {
      case "iuran":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => IuranDetailPage(data: data)),
        );
        break;

      case "otomasi":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => IuranOtomatisDetailPage(data: data)),
        );
        break;

      default:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FinanceDetailPage(data: data)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which data to show based on selected filter
    final List<dynamic> displayItems;
    
    if (selectedFilter == "Keuangan") {
      // Filter transactions based on search
      displayItems = _transactions.where((t) {
        final name = t.name.toLowerCase();
        final category = t.category.toLowerCase();

        return name.contains(searchQuery) || category.contains(searchQuery);
      }).toList();
    } else {
      // Filter fees based on search (for Iuran and Otomasi)
      displayItems = _fees.where((f) {
        final name = f.feeName.toLowerCase();
        final category = f.feeCategory.toLowerCase();

        return name.contains(searchQuery) || category.contains(searchQuery);
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: filterSearch,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgPrimaryInputBox(context),
            hintText: 'Cari transaksi...',
            prefixIcon: Icon(
              Icons.search,
              color: widget.isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 12),

        _buildFilterTabs(context),
        const SizedBox(height: 12),

        // Wrap content in ConstrainedBox with min height for scrollability
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 400, // Minimum height to ensure scrollability
          ),
          child: _buildContentArea(displayItems),
        ),
      ],
    );
  }

  Widget _buildContentArea(List<dynamic> displayItems) {
    if (_isLoading && _transactions.isEmpty && _fees.isEmpty) {
      // Initial loading with Lottie animation
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/list_loading.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat data...',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    if (displayItems.isEmpty) {
      // Empty state with min height
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.textSecondary(context).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada transaksi',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    // Display items with loading indicator at bottom
    return Column(
      children: [
        ...displayItems.map((item) {
          if (item is TransactionModel) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: TransactionTile(
                title: item.name,
                time: item.transactionDate,
                category: item.displayCategory,
                amount: item.formattedAmount,
                isIncome: item.isIncome,
                compact: false,
                onTap: () => _openDetail(item),
              ),
            );
          } else if (item is FeeModel) {
            // Iuran tile - custom layout
            return Container(
              margin: const EdgeInsets.only(bottom: 30),
              child: TransactionTile(
                title: item.feeName,
                time: item.chargeDate,
                category: item.feeCategory,
                amount: item.formattedAmount,
                isIncome: item.isIncome,
                compact: true, // Use compact mode for iuran
                isIuran: true, // Flag to use calendar icon instead of auto_mode
                onTap: () => _openDetail(item),
              ),
            );
          }
          return const SizedBox.shrink();
        }).toList(),
        if (_isLoading && _hasMore)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final tabs = ['Keuangan', 'Iuran', 'Otomasi'];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        itemBuilder: (_, i) {
          final label = tabs[i];
          final active = selectedFilter == label;

          return GestureDetector(
            onTap: () => changeFilter(label),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    color: active
                        ? AppColors.textPrimary(context)
                        : AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 30,
                  height: 3,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary(context)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
