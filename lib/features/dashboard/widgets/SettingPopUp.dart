import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/core/themes/theme_provider.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../core/provider/auth_service_provider.dart';

class PopupExample extends ConsumerStatefulWidget {
  const PopupExample({super.key});

  @override
  ConsumerState<PopupExample> createState() => PopupExampleState();
}

class PopupExampleState extends ConsumerState<PopupExample>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _entry;
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  // Public method to close popup from parent
  void closePopup() {
    if (_entry != null) {
      _hidePopup();
    }
  }

  final GlobalKey _buttonKey = GlobalKey();

  final double _popupWidth = 300;
  final double _verticalSpacing = 40;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _offset = Tween(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _showPopup() {
    final box = _buttonKey.currentContext!.findRenderObject() as RenderBox;

    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;

    final double left = pos.dx + size.width - _popupWidth;
    final double top = pos.dy + size.height + _verticalSpacing;

    _entry = OverlayEntry(
      builder: (context) {
        final notifier = ref.watch(themeProvider.notifier);
        final isDark = notifier.isDark;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _hidePopup,
                behavior: HitTestBehavior.translucent,
                child: Container(),
              ),
            ),

            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: _opacity,
                  child: SlideTransition(
                    position: _offset,
                    child: Container(
                      width: _popupWidth,
                      decoration: BoxDecoration(
                        color: AppColors.bgDashboardCard(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          width: 1.5,
                          color: AppColors.softBorder(context),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Profile Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const CircleAvatar(
                                    radius: 28,
                                    backgroundImage: NetworkImage(
                                      "https://i.pinimg.com/736x/5d/e7/9e/5de79ee675c983703b09a3fc637a01cd.jpg",
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Consumer(
                                    builder: (context, ref, _) {

                                      return const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Dr. Ambatron",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "ambatron@email.com",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Menu Items
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Column(
                              children: [
                                _popupItem(
                                  "Profile",
                                  Icons.person_rounded,
                                  const Color(0xFF4285F4),
                                  '/profile',
                                ),

                                // Dark Mode Toggle
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFFFC107,
                                            ).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.dark_mode_rounded,
                                            size: 20,
                                            color: Color(0xFFFFC107),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Dark Mode',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Transform.scale(
                                          scale: 0.85,
                                          child: Switch(
                                            value: isDark,
                                            onChanged: (_) {
                                              ref
                                                  .read(themeProvider.notifier)
                                                  .toggleTheme();
                                            },
                                            activeColor: const Color(
                                              0xFFFFC107,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Divider(height: 20),
                                ),

                                // Logout Button
                                _popupItem(
                                  "Logout",
                                  Icons.logout_rounded,
                                  const Color(0xFFF44336),
                                  null,
                                  isLogout: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_entry!);
    _controller.forward();
    setState(() {});
  }

  Widget _popupItem(
    String label,
    IconData icon,
    Color color,
    String? route, {
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: () async {
        _hidePopup();
        if (route != null) GoRouter.of(context).push(route);

        // Handle navigation or actions here
        if (isLogout) {
          // Show confirmation dialog
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  'Konfirmasi Logout',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                content: const Text(
                  'Apakah Anda yakin ingin keluar?',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF44336),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );

          // If user confirms, proceed with logout
          if (shouldLogout == true && context.mounted) {
            final authService = ref.read(authServiceProvider);
            await authService.logout();
            if (context.mounted) {
              context.go('/start');
            }
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isLogout ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isLogout ? FontWeight.w600 : FontWeight.w500,
                    color: isLogout ? color : null,
                  ),
                ),
              ),
              if (!isLogout)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _hidePopup() async {
    await _controller.reverse();
    _entry?.remove();
    _entry = null;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        key: _buttonKey,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _controller,
          color: Colors.white,
          size: 28,
        ),
        onPressed: () => _entry == null ? _showPopup() : _hidePopup(),
      ),
    );
  }
}

double getPopupWidth(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  // Maximum 300, minimal mengambil 85% lebar screen
  final maxWidth = 300.0;
  final minWidth = screenWidth * 0.85;

  return screenWidth < maxWidth ? minWidth : maxWidth;
}
