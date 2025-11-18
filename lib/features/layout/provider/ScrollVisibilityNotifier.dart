import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScrollVisibilityNotifier extends ChangeNotifier {
  bool _visible = true;

  bool get visible => _visible;

  void hide() {
    if (_visible) {
      _visible = false;
      notifyListeners();
    }
  }

  void show() {
    if (!_visible) {
      _visible = true;
      notifyListeners();
    }
  }
}

final scrollVisibilityProvider = ChangeNotifierProvider<ScrollVisibilityNotifier>((ref) {
  return ScrollVisibilityNotifier();
});