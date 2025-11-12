import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:ti3h_k1_jawara/features/layout/widgets/bottom_nav_bar.dart';

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final ScrollController _scrollController = ScrollController();
  bool _isNavBarVisible = true;

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
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isNavBarVisible) {
        setState(() => _isNavBarVisible = false);
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isNavBarVisible) {
        setState(() => _isNavBarVisible = true);
      }
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
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is UserScrollNotification) {
                if (notification.direction == ScrollDirection.reverse) {
                  if (_isNavBarVisible) {
                    setState(() => _isNavBarVisible = false);
                  }
                } else if (notification.direction == ScrollDirection.forward) {
                  if (!_isNavBarVisible) {
                    setState(() => _isNavBarVisible = true);
                  }
                }
              }
              return false;
            },
            child: widget.navigationShell,
          ),
          CustomBottomNavBar(
            currentIndex: widget.navigationShell.currentIndex,
            onTap: _onTap,
            isVisible: _isNavBarVisible,
          ),
        ],
      ),
    );
  }
}