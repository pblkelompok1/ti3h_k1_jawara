import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../provider/transaction_provider.dart';
import '../provider/product_provider.dart';
import '../provider/account_provider.dart';

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
  String selectedPaymentMethod = 'Paypal';

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(productRepositoryProvider);
    final product = repo.getProductById(widget.productId);

    if (product == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Produk tidak ditemukan",
            style: TextStyle(color: AppColors.textPrimary(context)),
          ),
        ),
      );
    }

    final qty = ref.watch(quantityProvider(widget.productId));
    final price = product.price;

    final subtotal = price * qty;
    final deliveryFee = isDelivery ? 5000 : 0;
    final serviceFee = 1000;
    final total = subtotal + deliveryFee + serviceFee;

    return Scaffold(
      backgroundColor: AppColors.bgTransaction(context),
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.bgDashboardCard(context),
        foregroundColor: AppColors.textPrimary(context),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAddressCard(),
            const SizedBox(height: 16),

            _buildOrderItemCard(product, qty),
            const SizedBox(height: 16),

            _buildDeliveryCard(),
            const SizedBox(height: 16),

            _buildPaymentMethodCard(),
            const SizedBox(height: 16),

            _buildPaymentSummaryCard(subtotal, deliveryFee, serviceFee, total),

            const SizedBox(height: 120),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomBar(total),
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

  Widget _buildOrderItemCard(product, int qty) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.images.first,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, size: 40),
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
                      "Penjual: ${product.seller ?? 'UMKM Lokal'}",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "x $qty",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: AppColors.softBorder(context)),
          const SizedBox(height: 12),
          _buildOrderDetailRow("Atur Pesanan *", "Atur >", isRequired: true),
        ],
      ),
    );
  }

  Widget _buildOrderDetailRow(
    String label,
    String value, {
    bool isRequired = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textPrimary(context))),
        Text(value, style: TextStyle(color: AppColors.textSecondary(context))),
      ],
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

  Widget _buildPaymentMethodCard() {
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

          _buildPaymentOption("Paypal", Icons.payment, Colors.blue),
          _buildPaymentOption("BNI", Icons.account_balance, Colors.orange),
          _buildPaymentOption("BRI", Icons.account_balance, Colors.blueAccent),
          _buildPaymentOption(
            "Bayar Ditempat",
            Icons.money,
            Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String name, IconData icon, Color color) {
    return InkWell(
      onTap: () => setState(() => selectedPaymentMethod = name),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              name,
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
          ),

          Radio<String>(
            value: name,
            groupValue: selectedPaymentMethod,
            onChanged: (v) => setState(() => selectedPaymentMethod = v!),
            activeColor: AppColors.primary(context),
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

  Widget _buildBottomBar(int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgDashboardCard(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              child: Text(
                currencyFormatter.format(total),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),

            const SizedBox(width: 16),

            ElevatedButton(
              onPressed: () {
                final product = ref
                    .read(productRepositoryProvider)
                    .getProductById(widget.productId)!;

                final qty = ref.read(quantityProvider(widget.productId));
                final transactionId = DateTime.now().millisecondsSinceEpoch
                    .toString();

                // 🔹 SIMPAN TRANSAKSI DETAIL
                ref
                    .read(transactionListProvider.notifier)
                    .addTransaction(
                      Transaction(
                        id: transactionId,
                        productName: product.name,
                        sellerName: product.seller,
                        quantity: qty,
                        subtotal: product.price * qty,
                        deliveryFee: isDelivery ? 5000 : 0,
                        serviceFee: 1000,
                        total: total,
                        paymentMethod: selectedPaymentMethod,
                        qrCodeData: selectedPaymentMethod == "Bayar Ditempat"
                            ? ""
                            : "QR-$transactionId",
                        recipientName: "Sudasoyono Muhdi",
                        recipientPhone: "(+62 9123 1923)",
                        recipientAddress: "Blok D - No. 4",
                        createdAt: DateTime.now(),
                        isDelivery: isDelivery,
                      ),
                    );

                // 🔹 SIMPAN KE MY ORDERS (BUYER)
                ref
                    .read(myOrdersProvider.notifier)
                    .addOrder(
                      MyOrder(
                        id: transactionId,
                        productName: product.name,
                        sellerName: product.seller,
                        price: product.price,
                        quantity: qty,
                        total: total,
                        status: 'pending',
                        paymentMethod: selectedPaymentMethod,
                        date: DateTime.now(),
                      ),
                    );

                context.push('/transaction/$transactionId');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.bgDashboardCard(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.softBorder(context)),
    );
  }
}
