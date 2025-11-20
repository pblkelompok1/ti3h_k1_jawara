import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/features/layout/widgets/bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/ScrollVisibilityNotifier.dart';

class MainLayout extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  late PageController _pageController;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(MainLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync PageView when navigation changes from external sources (e.g., deep links)
    if (oldWidget.navigationShell.currentIndex != widget.navigationShell.currentIndex) {
      if (_isNavigating) {
        _isNavigating = false;
      } else {
        // External navigation detected, sync PageView
        _pageController.jumpToPage(widget.navigationShell.currentIndex);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (widget.navigationShell.currentIndex != index) {
      _isNavigating = true;
      widget.navigationShell.goBranch(
        index,
        initialLocation: false,
      );
    }
  }

  void _onNavBarTap(int index) {
    if (widget.navigationShell.currentIndex != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNavVisible = ref.watch(scrollVisibilityProvider).visible;
    final currentIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is UserScrollNotification) {
                // Ignore horizontal scroll from PageView
                if (notification.metrics.axis == Axis.horizontal) return false;

                final visibility = ref.read(scrollVisibilityProvider);

                if (notification.direction == ScrollDirection.reverse) {
                  visibility.hide();
                } else if (notification.direction == ScrollDirection.forward) {
                  visibility.show();
                }
              }
              return false;
            },
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const ClampingScrollPhysics(),
              children: [
                // Page 0: Dashboard
                _PageContainer(
                  key: const ValueKey('page_0'),
                  child: widget.navigationShell,
                  isVisible: currentIndex == 0,
                ),
                // Page 1: Explore
                _PageContainer(
                  key: const ValueKey('page_1'),
                  child: widget.navigationShell,
                  isVisible: currentIndex == 1,
                ),
                // Page 2: Create
                _PageContainer(
                  key: const ValueKey('page_2'),
                  child: widget.navigationShell,
                  isVisible: currentIndex == 2,
                ),
                // Page 3: Market
                _PageContainer(
                  key: const ValueKey('page_3'),
                  child: widget.navigationShell,
                  isVisible: currentIndex == 3,
                ),
              ],
            ),
          ),
          CustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: _onNavBarTap,
            isVisible: isNavVisible,
          ),
        ],
      ),
    );
  }
}

/// Container that manages visibility of navigation shell content
/// Only the active page shows the navigation shell, others show empty container
class _PageContainer extends StatelessWidget {
  final Widget child;
  final bool isVisible;

  const _PageContainer({
    super.key,
    required this.child,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    // When not visible, return a colored container to prevent white flash
    if (!isVisible) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
      );
    }
    
    // When visible, show the navigation shell
    return child;
  }
}