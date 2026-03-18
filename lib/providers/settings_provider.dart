import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Available fonts in google_fonts package
enum AppFont {
  amiri('Amiri'),
  noto('Noto Naskh'),
  cairo('Cairo'),
  tajawal('Tajawal');

  final String displayName;
  const AppFont(this.displayName);
}

// Settings state
class SettingsState {
  final bool isDarkMode;
  final AppFont selectedFont;
  final double fontSize;
  final bool autoSaveLastRead;

  SettingsState({
    required this.isDarkMode,
    required this.selectedFont,
    required this.fontSize,
    required this.autoSaveLastRead,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    AppFont? selectedFont,
    double? fontSize,
    bool? autoSaveLastRead,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      selectedFont: selectedFont ?? this.selectedFont,
      fontSize: fontSize ?? this.fontSize,
      autoSaveLastRead: autoSaveLastRead ?? this.autoSaveLastRead,
    );
  }
}

// Settings provider
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(
    SettingsState(
      isDarkMode: false,
      selectedFont: AppFont.amiri,
      fontSize: 24.0,
      autoSaveLastRead: true,
    ),
  ) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settings');
    state = state.copyWith(
      isDarkMode: box.get('isDarkMode', defaultValue: false),
      selectedFont: AppFont.values[box.get('selectedFont', defaultValue: 0)],
      fontSize: box.get('fontSize', defaultValue: 24.0),
      autoSaveLastRead: box.get('autoSaveLastRead', defaultValue: true),
    );
  }

  Future<void> toggleDarkMode() async {
    final box = await Hive.openBox('settings');
    await box.put('isDarkMode', !state.isDarkMode);
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  Future<void> setFont(AppFont font) async {
    final box = await Hive.openBox('settings');
    await box.put('selectedFont', font.index);
    state = state.copyWith(selectedFont: font);
  }

  Future<void> setFontSize(double size) async {
    final box = await Hive.openBox('settings');
    await box.put('fontSize', size);
    state = state.copyWith(fontSize: size);
  }

  Future<void> setAutoSaveLastRead(bool value) async {
    final box = await Hive.openBox('settings');
    await box.put('autoSaveLastRead', value);
    state = state.copyWith(autoSaveLastRead: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

// Last read position provider
final lastReadProvider = StateProvider<int?>((ref) => null);