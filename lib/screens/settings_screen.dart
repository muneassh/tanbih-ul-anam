import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: GoogleFonts.amiri(fontSize: 24),
        ),
        backgroundColor: const Color(0xFF0A5C36),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dark Mode Toggle
          Card(
            child: SwitchListTile(
              title: Text(
                'الوضع الليلي',
                style: GoogleFonts.amiri(fontSize: 18),
              ),
              subtitle: Text(
                'تفعيل الخلفية الداكنة',
                style: GoogleFonts.amiri(fontSize: 14, color: Colors.grey[600]),
              ),
              value: settings.isDarkMode,
              activeColor: const Color(0xFF0A5C36),
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleDarkMode();
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Font Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نوع الخط',
                    style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...AppFont.values.map((font) {
                    return RadioListTile<AppFont>(
                      title: Text(
                        font.displayName,
                        style: GoogleFonts.amiri(fontSize: 16),
                      ),
                      value: font,
                      groupValue: settings.selectedFont,
                      activeColor: const Color(0xFF0A5C36),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(settingsProvider.notifier).setFont(value);
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Font Size
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حجم الخط',
                    style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (settings.fontSize > 16) {
                            ref.read(settingsProvider.notifier).setFontSize(settings.fontSize - 2);
                          }
                        },
                      ),
                      Expanded(
                        child: Slider(
                          value: settings.fontSize,
                          min: 16,
                          max: 32,
                          divisions: 8,
                          activeColor: const Color(0xFF0A5C36),
                          onChanged: (value) {
                            ref.read(settingsProvider.notifier).setFontSize(value);
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          if (settings.fontSize < 32) {
                            ref.read(settingsProvider.notifier).setFontSize(settings.fontSize + 2);
                          }
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      '${settings.fontSize.round()}px',
                      style: GoogleFonts.amiri(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Auto-save last read
          Card(
            child: SwitchListTile(
              title: Text(
                'حفظ آخر قراءة',
                style: GoogleFonts.amiri(fontSize: 18),
              ),
              subtitle: Text(
                'العودة تلقائياً لآخر صفحة قرأتها',
                style: GoogleFonts.amiri(fontSize: 14, color: Colors.grey[600]),
              ),
              value: settings.autoSaveLastRead,
              activeColor: const Color(0xFF0A5C36),
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setAutoSaveLastRead(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}