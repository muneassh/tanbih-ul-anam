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

// Reading mode enum
enum ReadingMode {
  normal('Normal', 'normal'),
  fullScreen('ملء الشاشة', 'full_screen');

  final String displayName;
  final String code;
  const ReadingMode(this.displayName, this.code);
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
  final ReadingMode readingMode;
  final bool showPageNumbers;
  final bool enableFlipAnimation;
  final double animationSpeed;
  final String? lastReadBab;
  final Map<int, int> lastPositions; // Map of juz to last salat index

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
    required this.readingMode,
    required this.showPageNumbers,
    required this.enableFlipAnimation,
    required this.animationSpeed,
    this.lastReadBab,
    required this.lastPositions,
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
    ReadingMode? readingMode,
    bool? showPageNumbers,
    bool? enableFlipAnimation,
    double? animationSpeed,
    String? lastReadBab,
    Map<int, int>? lastPositions,
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
      readingMode: readingMode ?? this.readingMode,
      showPageNumbers: showPageNumbers ?? this.showPageNumbers,
      enableFlipAnimation: enableFlipAnimation ?? this.enableFlipAnimation,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      lastReadBab: lastReadBab ?? this.lastReadBab,
      lastPositions: lastPositions ?? this.lastPositions,
    );
  }
}

// Settings provider
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(
    SettingsState(
      isDarkMode: false,
      selectedFont: AppFont.amiri,
      fontSize: 22.0.clamp(16.0, 32.0), // Ensure initial value is valid
      autoSaveLastRead: true,
      language: AppLanguage.arabic,
      enableNotifications: true,
      autoPlayAudio: false,
      showTafsir: false,
      lastReadJuz: 1,
      lastReadPage: 1,
      lastReadSalatId: null,
      readingMode: ReadingMode.normal,
      showPageNumbers: true,
      enableFlipAnimation: true,
      animationSpeed: 1.0,
      lastReadBab: null,
      lastPositions: {},
    ),
  ) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final box = await Hive.openBox('settings');
      
      // Load last positions map
      Map<int, int> lastPositions = {};
      final positionsMap = box.get('lastPositions', defaultValue: {});
      if (positionsMap is Map) {
        positionsMap.forEach((key, value) {
          if (key is int && value is int) {
            lastPositions[key] = value;
          }
        });
      }
      
      state = state.copyWith(
        isDarkMode: box.get('isDarkMode', defaultValue: false),
        selectedFont: AppFont.values[box.get('selectedFont', defaultValue: 0)],
        fontSize: (box.get('fontSize', defaultValue: 22.0) as num).toDouble().clamp(16.0, 32.0),
        autoSaveLastRead: box.get('autoSaveLastRead', defaultValue: true),
        language: AppLanguage.values[box.get('language', defaultValue: 0)],
        enableNotifications: box.get('enableNotifications', defaultValue: true),
        autoPlayAudio: box.get('autoPlayAudio', defaultValue: false),
        showTafsir: box.get('showTafsir', defaultValue: false),
        lastReadJuz: box.get('lastReadJuz', defaultValue: 1),
        lastReadPage: box.get('lastReadPage', defaultValue: 1),
        lastReadSalatId: box.get('lastReadSalatId'),
        readingMode: box.get('readingMode', defaultValue: 0) == 0 
            ? ReadingMode.normal 
            : ReadingMode.fullScreen,
        showPageNumbers: box.get('showPageNumbers', defaultValue: true),
        enableFlipAnimation: box.get('enableFlipAnimation', defaultValue: true),
        animationSpeed: box.get('animationSpeed', defaultValue: 1.0),
        lastReadBab: box.get('lastReadBab'),
        lastPositions: lastPositions,
      );
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> toggleDarkMode() async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('isDarkMode', !state.isDarkMode);
      state = state.copyWith(isDarkMode: !state.isDarkMode);
    } catch (e) {
      debugPrint('Error toggling dark mode: $e');
    }
  }

  Future<void> setFont(AppFont font) async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('selectedFont', font.index);
      state = state.copyWith(selectedFont: font);
    } catch (e) {
      debugPrint('Error setting font: $e');
    }
  }

  Future<void> setFontSize(double size) async {
    try {
      // Clamp value to valid range
      final clampedSize = size.clamp(16.0, 32.0);
      final box = await Hive.openBox('settings');
      await box.put('fontSize', clampedSize);
      state = state.copyWith(fontSize: clampedSize);
    } catch (e) {
      debugPrint('Error setting font size: $e');
    }
  }

  Future<void> setAutoSaveLastRead(bool value) async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('autoSaveLastRead', value);
      state = state.copyWith(autoSaveLastRead: value);
    } catch (e) {
      debugPrint('Error setting auto save: $e');
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('language', lang.index);
      state = state.copyWith(language: lang);
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  Future<void> setEnableNotifications(bool value) async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('enableNotifications', value);
      state = state.copyWith(enableNotifications: value);
    } catch (e) {
      debugPrint('Error setting notifications: $e');
    }
  }

  Future<void> setAutoPlayAudio(bool value) async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('autoPlayAudio', value);
      state = state.copyWith(autoPlayAudio: value);
    } catch (e) {
      debugPrint('Error setting auto play audio: $e');
    }
  }

  Future<void> setShowTafsir(bool value) async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('showTafsir', value);
      state = state.copyWith(showTafsir: value);
    } catch (e) {
      debugPrint('Error setting show tafsir: $e');
    }
  }

  Future<void> setReadingMode(ReadingMode mode) async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('readingMode', mode == ReadingMode.normal ? 0 : 1);
      state = state.copyWith(readingMode: mode);
    } catch (e) {
      debugPrint('Error setting reading mode: $e');
    }
  }

  Future<void> setShowPageNumbers(bool value) async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('showPageNumbers', value);
      state = state.copyWith(showPageNumbers: value);
    } catch (e) {
      debugPrint('Error setting show page numbers: $e');
    }
  }

  Future<void> setEnableFlipAnimation(bool value) async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('enableFlipAnimation', value);
      state = state.copyWith(enableFlipAnimation: value);
    } catch (e) {
      debugPrint('Error setting flip animation: $e');
    }
  }

  Future<void> setAnimationSpeed(double speed) async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('animationSpeed', speed.clamp(0.5, 2.0));
      state = state.copyWith(animationSpeed: speed.clamp(0.5, 2.0));
    } catch (e) {
      debugPrint('Error setting animation speed: $e');
    }
  }

  // Enhanced last read update with position tracking
  Future<void> updateLastRead(int juz, int page, int salatId, {String? bab}) async {
    try {
      final box = await Hive.openBox('settings');
      
      // Update current last read
      await box.put('lastReadJuz', juz);
      await box.put('lastReadPage', page);
      await box.put('lastReadSalatId', salatId);
      if (bab != null) {
        await box.put('lastReadBab', bab);
      }
      
      // Update last positions map
      Map<int, int> updatedPositions = Map.from(state.lastPositions);
      updatedPositions[juz] = salatId;
      await box.put('lastPositions', updatedPositions);
      
      state = state.copyWith(
        lastReadJuz: juz,
        lastReadPage: page,
        lastReadSalatId: salatId,
        lastReadBab: bab,
        lastPositions: updatedPositions,
      );
    } catch (e) {
      debugPrint('Error updating last read: $e');
    }
  }

  // Get last position for specific juz
  int? getLastPositionForJuz(int juz) {
    return state.lastPositions[juz];
  }

  // Clear all reading history
  Future<void> clearReadingHistory() async {
    try {
      final box = await Hive.openBox('settings');
      await box.delete('lastReadJuz');
      await box.delete('lastReadPage');
      await box.delete('lastReadSalatId');
      await box.delete('lastReadBab');
      await box.delete('lastPositions');
      
      state = state.copyWith(
        lastReadJuz: 1,
        lastReadPage: 1,
        lastReadSalatId: null,
        lastReadBab: null,
        lastPositions: {},
      );
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }

  // Reset all settings to default
  Future<void> resetToDefaults() async {
    try {
      final box = await Hive.openBox('settings');
      await box.clear();
      
      state = SettingsState(
        isDarkMode: false,
        selectedFont: AppFont.amiri,
        fontSize: 22.0.clamp(16.0, 32.0),
        autoSaveLastRead: true,
        language: AppLanguage.arabic,
        enableNotifications: true,
        autoPlayAudio: false,
        showTafsir: false,
        lastReadJuz: 1,
        lastReadPage: 1,
        lastReadSalatId: null,
        readingMode: ReadingMode.normal,
        showPageNumbers: true,
        enableFlipAnimation: true,
        animationSpeed: 1.0,
        lastReadBab: null,
        lastPositions: {},
      );
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }

  // Helper to calculate pages based on font size
  int calculateTotalPages(int totalSalawat, double screenHeight, bool isFullScreen) {
    double lineHeight = state.fontSize * 1.6;
    double availableHeight = screenHeight * (isFullScreen ? 0.75 : 0.6);
    int avgLinesPerSalat = 5;
    double salatHeight = avgLinesPerSalat * lineHeight;
    int salawatPerPage = (availableHeight / salatHeight).floor();
    salawatPerPage = salawatPerPage.clamp(1, 10);
    
    return (totalSalawat / salawatPerPage).ceil();
  }

  // Get salawat per page based on current settings
  int getSalawatPerPage(double screenHeight, bool isFullScreen) {
    double lineHeight = state.fontSize * 1.6;
    double availableHeight = screenHeight * (isFullScreen ? 0.75 : 0.6);
    int avgLinesPerSalat = 5;
    double salatHeight = avgLinesPerSalat * lineHeight;
    int salawatPerPage = (availableHeight / salatHeight).floor();
    return salawatPerPage.clamp(1, 10);
  }
}

// Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

// Last read position provider (kept for backward compatibility)
final lastReadProvider = StateProvider<int?>((ref) => null);

// Provider for current reading mode
final readingModeProvider = Provider<ReadingMode>((ref) {
  return ref.watch(settingsProvider).readingMode;
});

// Provider for current font size
final fontSizeProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).fontSize;
});

// Provider for current font
final fontProvider = Provider<AppFont>((ref) {
  return ref.watch(settingsProvider).selectedFont;
});

// Provider for dark mode
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).isDarkMode;
});

// Provider for language
final languageProvider = Provider<AppLanguage>((ref) {
  return ref.watch(settingsProvider).language;
});

// Provider for animation speed
final animationSpeedProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).animationSpeed;
});

// Provider for flip animation enabled
final flipAnimationEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).enableFlipAnimation;
});