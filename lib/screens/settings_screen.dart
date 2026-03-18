import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '1.0.0';
  String _appBuildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _appBuildNumber = packageInfo.buildNumber;
    });
  }

  String _getLocalizedText(String ar, String en) {
    final settings = ref.watch(settingsProvider);
    return settings.language == AppLanguage.arabic ? ar : en;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getLocalizedText('الإعدادات', 'Settings'),
          style: GoogleFonts.amiri(fontSize: 24),
        ),
        backgroundColor: const Color(0xFF0A5C36),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedText('اللغة', 'Language'),
                    style: GoogleFonts.amiri(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A5C36),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...AppLanguage.values.map((lang) {
                    return RadioListTile<AppLanguage>(
                      title: Text(
                        lang.displayName,
                        style: GoogleFonts.amiri(fontSize: 16),
                      ),
                      value: lang,
                      groupValue: settings.language,
                      activeColor: const Color(0xFF0A5C36),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(settingsProvider.notifier).setLanguage(value);
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Dark Mode Toggle
          Card(
            child: SwitchListTile(
              title: Text(
                _getLocalizedText('الوضع الليلي', 'Dark Mode'),
                style: GoogleFonts.amiri(fontSize: 18),
              ),
              subtitle: Text(
                _getLocalizedText('تفعيل الخلفية الداكنة', 'Enable dark background'),
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
                    _getLocalizedText('نوع الخط', 'Font Type'),
                    style: GoogleFonts.amiri(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A5C36),
                    ),
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
                    _getLocalizedText('حجم الخط', 'Font Size'),
                    style: GoogleFonts.amiri(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A5C36),
                    ),
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
                _getLocalizedText('حفظ آخر قراءة', 'Save Last Read'),
                style: GoogleFonts.amiri(fontSize: 18),
              ),
              subtitle: Text(
                _getLocalizedText('العودة تلقائياً لآخر صفحة قرأتها', 'Auto-resume from last position'),
                style: GoogleFonts.amiri(fontSize: 14, color: Colors.grey[600]),
              ),
              value: settings.autoSaveLastRead,
              activeColor: const Color(0xFF0A5C36),
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setAutoSaveLastRead(value);
              },
            ),
          ),

          const SizedBox(height: 8),

          // Notifications
          Card(
            child: SwitchListTile(
              title: Text(
                _getLocalizedText('الإشعارات', 'Notifications'),
                style: GoogleFonts.amiri(fontSize: 18),
              ),
              subtitle: Text(
                _getLocalizedText('تذكير بقراءة الصلوات', 'Prayer reminders'),
                style: GoogleFonts.amiri(fontSize: 14, color: Colors.grey[600]),
              ),
              value: settings.enableNotifications,
              activeColor: const Color(0xFF0A5C36),
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setEnableNotifications(value);
              },
            ),
          ),

          const SizedBox(height: 16),

          // About App Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A5C36).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Color(0xFF0A5C36),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getLocalizedText('عن التطبيق', 'About App'),
                        style: GoogleFonts.amiri(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0A5C36),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // App name
                  _buildAboutItem(
                    Icons.apps,
                    _getLocalizedText('اسم التطبيق', 'App Name'),
                    _getLocalizedText('تنبيه الأنام', 'Tanbih al-Anam'),
                  ),
                  
                  const Divider(),
                  
                  // Version
                  _buildAboutItem(
                    Icons.tag,
                    _getLocalizedText('الإصدار', 'Version'),
                    '$_appVersion ($_appBuildNumber)',
                  ),
                  
                  const Divider(),
                  
                  // Developer
                  _buildAboutItem(
                    Icons.person,
                    _getLocalizedText('المطور', 'Developer'),
                    _getLocalizedText('مؤسسة منعش', 'Muneassh Foundation'),
                  ),
                  
                  const Divider(),
                  
                  // Purpose
                  _buildAboutItem(
                    Icons.mosque,
                    _getLocalizedText('الغرض', 'Purpose'),
                    _getLocalizedText(
                      'تطبيق لقراءة الصلوات على سيدنا محمد ﷺ',
                      'An app for reading prayers upon Prophet Muhammad ﷺ',
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Content
                  _buildAboutItem(
                    Icons.menu_book,
                    _getLocalizedText('المحتوى', 'Content'),
                    _getLocalizedText(
                      'جزءان رئيسيان + خاتمة، أبواب متعددة',
                      '2 Main parts + Conclusion, Multiple chapters',
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Features
                  _buildAboutItem(
                    Icons.stars,
                    _getLocalizedText('المميزات', 'Features'),
                    _getLocalizedText(
                      '• واجهة عربية أنيقة\n• خطوط متعددة\n• وضع ليلي\n• إشارات مرجعية\n• مشاركة النصوص\n• حفظ آخر قراءة\n• بحث متقدم',
                      '• Beautiful Arabic UI\n• Multiple fonts\n• Dark mode\n• Bookmarks\n• Share text\n• Save last read\n• Advanced search',
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Developer contact
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'support@muneassh.com',
                          style: GoogleFonts.amiri(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.amiri(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.amiri(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}