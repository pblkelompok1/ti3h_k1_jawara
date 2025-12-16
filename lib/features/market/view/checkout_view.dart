import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../provider/marketplace_provider.dart';
import '../provider/account_provider.dart' as account;
import '../models/marketplace_product_model.dart';
import '../models/transaction_method_model.dart';
import '../../../core/provider/auth_service_provider.dart';

class CheckoutView extends ConsumerStatefulWidget {
  const CheckoutView({
    super.key,
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final int quantity;

  @override
  ConsumerState<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends ConsumerState<CheckoutView> {
  bool isDelivery = true;
  TransactionMethod? selectedPaymentMethod;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isCreatingTransaction = false;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final methodsAsync = ref.watch(transactionMethodsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgTransaction(context),
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.bgDashboardCard(context),
        foregroundColor: AppColors.textPrimary(context),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: productAsync.when(
        data: (product) {
          final subtotal = product.price * widget.quantity;
          final deliveryFee = isDelivery ? 5000 : 0;
          final serviceFee = 1000;
          final total = subtotal + deliveryFee + serviceFee;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildAddressCard(),
                const SizedBox(height: 16),
                _buildOrderItemCard(product, widget.quantity),
                const SizedBox(height: 16),
                _buildDescriptionCard(),
                const SizedBox(height: 16),
                _buildDeliveryCard(),
                const SizedBox(height: 16),
                methodsAsync.when(
                  data: (methods) => _buildPaymentMethodCard(methods),
                  loading: () => _buildLoadingCard(),
                  error: (error, stack) => _buildErrorCard(error.toString()),
                ),
                const SizedBox(height: 16),
                _buildPaymentSummaryCard(subtotal, deliveryFee, serviceFee, total),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat produk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) {
          final total = (product.price * widget.quantity) +
              (isDelivery ? 5000 : 0) +
              1000;
          return _buildBottomBar(product, total);
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors.textSecondary(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sudasoyono Muhdi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  "(+62 9123 1923)",
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
                Text(
                  "Blok D - No. 4",
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(MarketplaceProduct product, int qty) {
    final service = ref.read(marketplaceServiceProvider);
    final imageUrl = product.imagesPath.isNotEmpty
        ? service.getImageUrl(product.imagesPath.first)
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 40),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 40),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Penjual: ${product.sellerName ?? 'UMKM Lokal'}",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "x $qty",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      currencyFormatter.format(product.price),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Catatan Pesanan (Opsional)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tambahkan catatan untuk penjual...',
              hintStyle: TextStyle(color: AppColors.textSecondary(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.softBorder(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary(context)),
              ),
              filled: true,
              fillColor: AppColors.bgPrimaryInputBox(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(Icons.delivery_dining, color: AppColors.textPrimary(context)),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              "Kirim ke rumah",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            "Rp. 5.000",
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),

          Switch(
            value: isDelivery,
            onChanged: (v) => setState(() => isDelivery = v),
            activeThumbColor: AppColors.primary(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(List<TransactionMethod> methods) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Metode Pembayaran",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          ...methods.map((method) => _buildPaymentOption(method)),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(TransactionMethod method) {
    final isSelected = selectedPaymentMethod?.transactionMethodId == method.transactionMethodId;
    IconData icon;
    Color color;

    // Map icon dan warna berdasarkan nama metode
    if (method.methodName.toLowerCase().contains('cod')) {
      icon = Icons.money;
      color = Colors.green.shade700;
    } else if (method.methodName.toLowerCase().contains('transfer')) {
      icon = Icons.account_balance;
      color = Colors.orange;
    } else if (method.methodName.toLowerCase().contains('wallet')) {
      icon = Icons.account_balance_wallet;
      color = Colors.purple;
    } else if (method.methodName.toLowerCase().contains('qris')) {
      icon = Icons.qr_code_2;
      color = Colors.blue;
    } else {
      icon = Icons.payment;
      color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => selectedPaymentMethod = method),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary(context).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary(context)
                  : AppColors.softBorder(context),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.methodName,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Radio<int>(
                value: method.transactionMethodId,
                groupValue: selectedPaymentMethod?.transactionMethodId,
                onChanged: (v) => setState(() => selectedPaymentMethod = method),
                activeColor: AppColors.primary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: _cardDecoration(),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 8),
          Text(
            'Gagal memuat metode pembayaran',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(
    int subtotal,
    int deliveryFee,
    int serviceFee,
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rincian Pembayaran",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),

          _buildSummaryRow("Subtotal Pesanan", subtotal),
          _buildSummaryRow("Layanan Pengiriman", deliveryFee),
          _buildSummaryRow("Biaya Layanan", serviceFee),

          const SizedBox(height: 16),
          Divider(color: AppColors.softBorder(context)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Pembayaran",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                currencyFormatter.format(total),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary(context))),
        Text(
          currencyFormatter.format(amount),
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
      ],
    );
  }

  Widget _buildBottomBar(MarketplaceProduct product, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  Text(
                    currencyFormatter.format(total),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isCreatingTransaction ? null : () => _createTransaction(product, total),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                disabledBackgroundColor: AppColors.softBorder(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCreatingTransaction
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Buat Pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTransaction(MarketplaceProduct product, int total) async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() => _isCreatingTransaction = true);

    try {
      // Get current user ID from auth service
      final authService = ref.read(authServiceProvider);
      final user = await authService.getCurrentUser();
      
      if (user == null) {
        throw Exception('User tidak ditemukan. Silakan login kembali.');
      }

      final service = ref.read(marketplaceServiceProvider);
      
      print('🛒 CREATING TRANSACTION:');
      print('   User ID: ${user.id}');
      print('   Product ID: ${widget.productId}');
      print('   Quantity: ${widget.quantity}');
      print('   Payment Method: ${selectedPaymentMethod!.transactionMethodId}');
      
      final result = await service.createTransaction(
        userId: user.id,
        productId: widget.productId,
        quantity: widget.quantity,
        transactionMethodId: selectedPaymentMethod!.transactionMethodId,
        address: "Sudasoyono Muhdi, (+62 9123 1923), Blok D - No. 4",
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      print('✅ Transaction created: ${result['product_transaction_id']}');

      if (!mounted) return;

      // Invalidate my orders to refresh
      ref.invalidate(account.myOrdersProvider(user.id));

      // Navigate to transaction detail
      final transactionId = result['product_transaction_id']?.toString();
      if (transactionId != null) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(child: Text('Pesanan berhasil dibuat!')),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate to transaction detail
        context.go('/transaction/$transactionId');
      } else {
        // Fallback to marketplace if no transaction ID
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pesanan dibuat, tapi tidak bisa membuka detail'),
            backgroundColor: Colors.orange.shade600,
          ),
        );
        context.go('/marketplace');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan: ${e.toString()}'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingTransaction = false);
      }
    }
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.bgDashboardCard(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.softBorder(context)),
    );
  }
}
