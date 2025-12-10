import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/services/finance_service.dart';
import 'package:ti3h_k1_jawara/core/models/fee_transaction_model.dart';
import 'detail_tagihan_pribadi_page.dart';

class TagihanSection extends StatefulWidget {
  final bool isDark;
  final FinanceService financeService;
  final Function(VoidCallback)? onRefreshCallback;
  
  const TagihanSection({
    super.key, 
    required this.isDark,
    required this.financeService,
    this.onRefreshCallback,
  });

  @override
  State<TagihanSection> createState() => _TagihanSectionState();
}

class _TagihanSectionState extends State<TagihanSection>
    with SingleTickerProviderStateMixin {
  bool expanded = true;
  bool isLoading = true;
  String? errorMessage;
  List<FeeTransactionModel> feeTransactions = [];

  @override
  void initState() {
    super.initState();
    // Register refresh callback
    widget.onRefreshCallback?.call(_loadFeeTransactions);
    // Defer heavy operations to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeeTransactions();
    });
  }

  Future<void> _loadFeeTransactions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await widget.financeService.getFeeTransactions();
      setState(() {
        feeTransactions = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: expanded
            ? const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              )
            : BorderRadius.circular(24),
      ),

      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.primaryDark
                    : AppColors.primaryLight,
                borderRadius: expanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      )
                    : BorderRadius.circular(24),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tagihan/Iuran Pribadi",
                    style: TextStyle(
                      color: AppColors.textPrimaryReverse(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0 : 0.5,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 26,
                      color: AppColors.textPrimaryReverse(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: _buildContent(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "Error loading data",
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadFeeTransactions,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (feeTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Tidak ada tagihan",
            style: TextStyle(
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
      );
    }

    return Column(
      children: feeTransactions.map((transaction) {
        return _tagihanItem(
          context: context,
          transaction: transaction,
        );
      }).toList(),
    );
  }

  Widget _tagihanItem({
    required BuildContext context,
    required FeeTransactionModel transaction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final result = await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => DetailTagihanPribadiPage(
                isDark: widget.isDark,
                feeTransactionId: transaction.feeTransactionId,
                kategori: transaction.feeName,
                judul: transaction.feeCategory,
                amount: transaction.formattedAmount,
                dueDate: transaction.transactionDate ?? '-',
                financeService: widget.financeService,
              ),
            ),
          );

          // Refresh list if payment was submitted
          if (result == true) {
            _loadFeeTransactions();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary(context),
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.feeName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.feeCategory,
                      style: TextStyle(
                        fontSize: 14,
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
                    transaction.formattedAmount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
