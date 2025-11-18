import 'package:flutter/material.dart';

class PaymentSummaryCards extends StatelessWidget {
  const PaymentSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(
          context,
          icon: Icons.warning_amber_rounded,
          title: "Iuran Belum Dibayar",
          value: "12",
          color: const Color(0xFFE0F7DC),
          onTap: () {},
        ),
        _buildCard(
          context,
          icon: Icons.shopping_cart_checkout_rounded,
          title: "Checkout",
          value: "5 Pesanan",
          color: const Color(0xFFEBDEFC),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              splashColor: Colors.black12, // bisa diganti
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, size: 42),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
