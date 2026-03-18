import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Language enum
enum AppLanguage {
  arabic('العربية', 'ar'),
  english('English', 'en');

  final String displayName;
  final String code;
  const AppLanguage(this.displayName, this.code);
}

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
  final AppLanguage language;
  final bool enableNotifications;
  final bool autoPlayAudio;
  final bool showTafsir;
  final int lastReadJuz;
  final int lastReadPage;
  final int? lastReadSalatId;

  SettingsState({
    required this.isDarkMode,
    required this.selectedFont,
    required this.fontSize,
    required this.autoSaveLastRead,
    required this.language,
    required this.enableNotifications,
    required this.autoPlayAudio,
    required this.showTafsir,
    required this.lastReadJuz,
    required this.lastReadPage,
    this.lastReadSalatId,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    AppFont? selectedFont,
    double? fontSize,
    bool? autoSaveLastRead,
    AppLanguage? language,
    bool? enableNotifications,
    bool? autoPlayAudio,
    bool? showTafsir,
    int? lastReadJuz,
    int? lastReadPage,
    int? lastReadSalatId,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      selectedFont: selectedFont ?? this.selectedFont,
      fontSize: fontSize ?? this.fontSize,
      autoSaveLastRead: autoSaveLastRead ?? this.autoSaveLastRead,
      language: language ?? this.language,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      showTafsir: showTafsir ?? this.showTafsir,
      lastReadJuz: lastReadJuz ?? this.lastReadJuz,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      lastReadSalatId: lastReadSalatId ?? this.lastReadSalatId,
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
      language: AppLanguage.arabic,
      enableNotifications: true,
      autoPlayAudio: false,
      showTafsir: false,
      lastReadJuz: 1,
      lastReadPage: 1,
      lastReadSalatId: null,
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
      language: AppLanguage.values[box.get('language', defaultValue: 0)],
      enableNotifications: box.get('enableNotifications', defaultValue: true),
      autoPlayAudio: box.get('autoPlayAudio', defaultValue: false),
      showTafsir: box.get('showTafsir', defaultValue: false),
      lastReadJuz: box.get('lastReadJuz', defaultValue: 1),
      lastReadPage: box.get('lastReadPage', defaultValue: 1),
      lastReadSalatId: box.get('lastReadSalatId'),
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

  Future<void> setLanguage(AppLanguage lang) async {
    final box = await Hive.openBox('settings');
    await box.put('language', lang.index);
    state = state.copyWith(language: lang);
  }

  Future<void> setEnableNotifications(bool value) async {
    final box = await Hive.openBox('settings');
    await box.put('enableNotifications', value);
    state = state.copyWith(enableNotifications: value);
  }

  Future<void> setAutoPlayAudio(bool value) async {
    final box = await Hive.openBox('settings');
    await box.put('autoPlayAudio', value);
    state = state.copyWith(autoPlayAudio: value);
  }

  Future<void> setShowTafsir(bool value) async {
    final box = await Hive.openBox('settings');
    await box.put('showTafsir', value);
    state = state.copyWith(showTafsir: value);
  }

  Future<void> updateLastRead(int juz, int page, int salatId) async {
    final box = await Hive.openBox('settings');
    await box.put('lastReadJuz', juz);
    await box.put('lastReadPage', page);
    await box.put('lastReadSalatId', salatId);
    state = state.copyWith(
      lastReadJuz: juz,
      lastReadPage: page,
      lastReadSalatId: salatId,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

// Last read position provider
final lastReadProvider = StateProvider<int?>((ref) => null);