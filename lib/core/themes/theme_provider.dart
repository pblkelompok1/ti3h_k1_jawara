import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/services/settings_service.dart';

final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  final SettingsService _repo = SettingsService();

  @override
  Future<ThemeMode> build() async {
    // ✅ Await untuk load dari storage
    final isDark = await _repo.getDarkMode();
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    // Guard untuk async state
    final currentState = state;
    if (currentState is! AsyncData<ThemeMode>) return;

    final isDark = currentState.value == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    
    // Update state
    state = AsyncData(newMode);
    
    // Save ke storage
    await _repo.setDarkMode(!isDark);
  }
}
