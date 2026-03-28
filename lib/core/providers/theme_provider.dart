import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggleTheme() {
    state = (state == ThemeMode.light || state == ThemeMode.system)
        ? ThemeMode.dark
        : ThemeMode.light;
  }
}

final themeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
