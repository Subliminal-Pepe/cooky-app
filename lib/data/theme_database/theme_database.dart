/*
 * Author: Alban DAVID
 * Github : https://github.com/AlbanDAVID/cooky-app
 * This file is governed by the GNU General Public License, version 3.0.
 * A copy of the license is included in the LICENSE file at the root of this project.
 */

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Theme mode selected by the user.
///
/// [system] follows the device light/dark setting and is the default.
enum AppThemeMode { system, light, dark }

/// Color theme selected by the user.
///
/// [dynamic] uses the colors provided by the platform (wallpaper on Android
/// 12+). The other values are fixed Material 3 seed colors used as a fallback
/// or when the user prefers a specific palette.
enum AppThemeColor { dynamic, purple, blue, green, teal, orange, pink }

/// Reads and writes the theme preferences from the Hive box used by the app.
class ThemeDatabase {
  static const String boxName = 'mybox';
  static const String themeModeKey = 'THEME_MODE';
  static const String themeColorKey = 'THEME_COLOR';

  Box get _box => Hive.box(boxName);

  AppThemeMode getThemeMode() {
    final storedMode = _box.get(themeModeKey);
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == storedMode,
      orElse: () => AppThemeMode.system,
    );
  }

  AppThemeColor getThemeColor() {
    final storedColor = _box.get(themeColorKey);
    return AppThemeColor.values.firstWhere(
      (color) => color.name == storedColor,
      orElse: () => AppThemeColor.dynamic,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) {
    return _box.put(themeModeKey, mode.name);
  }

  Future<void> setThemeColor(AppThemeColor color) {
    return _box.put(themeColorKey, color.name);
  }

  static ThemeMode toFlutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Seed colors used to build Material 3 color schemes.
  ///
  /// The purple seed matches Cooky's historical brand color.
  static const Map<AppThemeColor, Color> seedColors = {
    AppThemeColor.purple: Color(0xFF9371CA),
    AppThemeColor.blue: Color(0xFF1565C0),
    AppThemeColor.green: Color(0xFF2E7D32),
    AppThemeColor.teal: Color(0xFF00796B),
    AppThemeColor.orange: Color(0xFFEF6C00),
    AppThemeColor.pink: Color(0xFFC2185B),
  };

  static Color seedColorFor(AppThemeColor color) {
    return seedColors[color] ?? seedColors[AppThemeColor.purple]!;
  }
}
