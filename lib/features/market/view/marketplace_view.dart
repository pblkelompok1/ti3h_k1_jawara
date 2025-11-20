import 'package:flutter/material.dart';

class MarketMainScreen extends StatefulWidget {
  const MarketMainScreen({super.key});

  @override
  State<MarketMainScreen> createState() => _MarketMainScreenState();
}

class _MarketMainScreenState extends State<MarketMainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggle() {
    if (_controller.isAnimating) return;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          final angle = _controller.value * 2 * 3.1415;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)   // memberi efek 3D depth
              ..rotateY(angle),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber,
            border: Border.all(width: 4, color: Colors.red),
          ),
          child: const Icon(Icons.monetization_on, size: 40),
        ),
      ),
    );
  }
}
