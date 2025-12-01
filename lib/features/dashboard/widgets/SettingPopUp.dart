import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ti3h_k1_jawara/core/themes/theme_provider.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PopupExample extends ConsumerStatefulWidget {
  const PopupExample({super.key});

  @override
  ConsumerState<PopupExample> createState() => _PopupExampleState();
}

class _PopupExampleState extends ConsumerState<PopupExample>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _entry;
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

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
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgDashboardCard(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          width: 1.4,
                          color: AppColors.softBorder(context),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AutoSizeText(
                                'Dark Mode',
                                maxLines: 1,
                                minFontSize: 10,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Switch(
                                value: isDark,
                                onChanged: (_) {
                                  ref
                                      .read(themeProvider.notifier)
                                      .toggleTheme();
                                },
                              ),
                            ],
                          ),

                          const Divider(height: 20),

                          _popupItem("Settings", Icons.settings),
                          _popupItem("Notification", Icons.notifications),
                          _popupItem("Help & Support", Icons.help_outline),
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

  Widget _popupItem(String label, IconData icon) {
    return InkWell(
      onTap: () {
        _hidePopup();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20, // ukuran seragam
              color: AppColors.surfaceLight,
            ),
            const SizedBox(width: 12), // spasi konsisten
            Expanded(
              child: AutoSizeText(
                label,
                maxLines: 1,
                minFontSize: 10,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
