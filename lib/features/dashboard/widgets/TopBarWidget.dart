import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'SettingPopUp.dart';

class CustomTopBar extends ConsumerStatefulWidget {
  final bool isVisible;

  const CustomTopBar({super.key, required this.isVisible});

  @override
  ConsumerState<CustomTopBar> createState() => _CustomTopBarState();
}

class _CustomTopBarState extends ConsumerState<CustomTopBar> {
  final GlobalKey<PopupExampleState> _popupKey = GlobalKey<PopupExampleState>();

  @override
  void didUpdateWidget(CustomTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Close popup when TopBar visibility changes
    if (oldWidget.isVisible != widget.isVisible && !widget.isVisible) {
      _popupKey.currentState?.closePopup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      top: widget.isVisible ? 0 : -200,
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.bgDashboardAppHeader(context),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildHeader(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.home, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 7,)
            ],
          ),
        ),
        SizedBox(width: 40, height: 40, child: PopupExample(key: _popupKey)),
      ],
    );
  }
}
