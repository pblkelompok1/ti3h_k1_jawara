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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final visibility = ref.read(scrollVisibilityProvider);

    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      visibility.hide();
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      visibility.show();
    }
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNavVisible = ref.watch(scrollVisibilityProvider).visible;

    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is UserScrollNotification) {

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
            child: widget.navigationShell,
          ),
          CustomBottomNavBar(
            currentIndex: widget.navigationShell.currentIndex,
            onTap: _onTap,
            isVisible: isNavVisible,
          ),
        ],
      ),
    );
  }
}