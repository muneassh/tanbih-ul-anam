import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';
import '../data/groups_data.dart';
import '../data/groups_classified.dart';
import '../providers/data_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '1.0.0';
  String _appBuildNumber = '1';
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _loadStatistics();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _appBuildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _loadStatistics() async {
    final allSalawat = await ref.read(salawatProvider.future);
    final groups = GroupsData.getGroups();
    final Map<String, dynamic> stats = {
      'total_salawat': allSalawat.length,
      'groups': {},
    };
    
    int totalClassified = 0;
    
    for (var group in groups) {
      final salawatIds = GroupsClassifiedData.getSalawatIdsForGroup(group.id);
      final count = salawatIds.length;
      totalClassified += count;
      stats['groups'][group.nameAr] = {
        'count': count,
        'color': group.color.value,
        'icon': group.icon.codePoint,
      };
      stats['groups'][group.nameEn] = {
        'count': count,
        'color': group.color.value,
        'icon': group.icon.codePoint,
      };
    }
    
    stats['total_classified'] = totalClassified;
    stats['unclassified'] = allSalawat.length - totalClassified;
    
    setState(() {
      _statistics = stats;
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
                            ref.read(settingsProvider.notifier).setFontSize(settings.fontSize - 1);
                          }
                        },
                      ),
                      Expanded(
                        child: Slider(
                          value: settings.fontSize.clamp(16.0, 32.0),
                          min: 16,
                          max: 32,
                          divisions: 16,
                          activeColor: const Color(0xFF0A5C36),
                          onChanged: (value) {
                            if (value >= 16 && value <= 32) {
                              ref.read(settingsProvider.notifier).setFontSize(value);
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          if (settings.fontSize < 32) {
                            ref.read(settingsProvider.notifier).setFontSize(settings.fontSize + 1);
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

          const SizedBox(height: 8),

          // Flip Animation
          Card(
            child: SwitchListTile(
              title: Text(
                _getLocalizedText('حركة التقليب', 'Flip Animation'),
                style: GoogleFonts.amiri(fontSize: 18),
              ),
              subtitle: Text(
                _getLocalizedText('تفعيل تأثير تقليب الصفحات', 'Enable page flip effect'),
                style: GoogleFonts.amiri(fontSize: 14, color: Colors.grey[600]),
              ),
              value: settings.enableFlipAnimation,
              activeColor: const Color(0xFF0A5C36),
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setEnableFlipAnimation(value);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Group Statistics Section
          _buildStatisticsCard(),

          const SizedBox(height: 16),

          // About App Section
          _buildAboutCard(),

          const SizedBox(height: 8),

          // Reset Settings Button
          Card(
            child: ListTile(
              leading: const Icon(Icons.restore, color: Colors.red),
              title: Text(
                _getLocalizedText('إعادة تعيين الإعدادات', 'Reset Settings'),
                style: GoogleFonts.amiri(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      _getLocalizedText('تأكيد', 'Confirm'),
                      style: GoogleFonts.amiri(),
                    ),
                    content: Text(
                      _getLocalizedText(
                        'هل أنت متأكد من إعادة تعيين جميع الإعدادات؟',
                        'Are you sure you want to reset all settings?',
                      ),
                      style: GoogleFonts.amiri(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          _getLocalizedText('إلغاء', 'Cancel'),
                          style: GoogleFonts.amiri(),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(settingsProvider.notifier).resetToDefaults();
                          Navigator.pop(context);
                        },
                        child: Text(
                          _getLocalizedText('تأكيد', 'Confirm'),
                          style: GoogleFonts.amiri(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    if (_statistics == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  _getLocalizedText('جاري تحميل الإحصائيات...', 'Loading statistics...'),
                  style: GoogleFonts.amiri(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final stats = _statistics!;
    final groupsStats = stats['groups'] as Map;
    final totalSalawat = stats['total_salawat'] as int;
    final totalClassified = stats['total_classified'] as int;
    final unclassified = stats['unclassified'] as int;
    final settings = ref.watch(settingsProvider);
    final groups = GroupsData.getGroups();

    return Card(
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
                    Icons.analytics,
                    color: Color(0xFF0A5C36),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getLocalizedText('إحصائيات المجموعات', 'Group Statistics'),
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0A5C36),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Summary Stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A5C36).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    totalSalawat.toString(),
                    _getLocalizedText('إجمالي الصلوات', 'Total Prayers'),
                    Icons.menu_book,
                  ),
                  _buildStatItem(
                    totalClassified.toString(),
                    _getLocalizedText('مصنفة', 'Classified'),
                    Icons.check_circle,
                  ),
                  _buildStatItem(
                    unclassified.toString(),
                    _getLocalizedText('غير مصنفة', 'Unclassified'),
                    Icons.warning,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _getLocalizedText('توزيع الصلوات حسب المجموعات', 'Distribution by Category'),
              style: GoogleFonts.amiri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0A5C36),
              ),
            ),
            const SizedBox(height: 12),
            
            // Group Distribution List
            ...groups.map((group) {
              final groupData = groupsStats[group.nameAr];
              final count = groupData != null && groupData is Map ? (groupData['count'] as int? ?? 0) : 0;
              final percentage = totalSalawat > 0 ? (count / totalSalawat * 100).toStringAsFixed(1) : '0';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(group.icon, size: 20, color: group.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            settings.language == AppLanguage.arabic
                                ? group.nameAr
                                : group.nameEn,
                            style: GoogleFonts.amiri(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '$count ($percentage%)',
                          style: GoogleFonts.amiri(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: count / totalSalawat,
                      backgroundColor: Colors.grey[200],
                      color: group.color,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            const Divider(height: 24),
            
            // Top Groups
            Text(
              _getLocalizedText('أكثر المجموعات', 'Top Categories'),
              style: GoogleFonts.amiri(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: groups
                  .map((group) {
                    final groupData = groupsStats[group.nameAr];
                    final count = groupData != null && groupData is Map ? (groupData['count'] as int? ?? 0) : 0;
                    if (count > 0) {
                      return Chip(
                        label: Text(
                          settings.language == AppLanguage.arabic ? group.nameAr : group.nameEn,
                          style: GoogleFonts.amiri(fontSize: 12),
                        ),
                        avatar: Icon(group.icon, size: 16, color: group.color),
                        backgroundColor: group.color.withOpacity(0.1),
                        labelStyle: TextStyle(color: group.color),
                      );
                    }
                    return null;
                  })
                  .whereType<Chip>()
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: const Color(0xFF0A5C36)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.amiri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0A5C36),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.amiri(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCard() {
    return Card(
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
            
            // Features
            _buildAboutItem(
              Icons.stars,
              _getLocalizedText('المميزات', 'Features'),
              _getLocalizedText(
                '• واجهة عربية أنيقة\n• خطوط متعددة\n• وضع ليلي\n• إشارات مرجعية\n• مشاركة النصوص\n• حفظ آخر قراءة\n• بحث متقدم\n• تقليب الصفحات بشكل كتاب\n• مجموعات مصنفة\n• أوقات صلاة حسب الموقع',
                '• Beautiful Arabic UI\n• Multiple fonts\n• Dark mode\n• Bookmarks\n• Share text\n• Save last read\n• Advanced search\n• Book-like page flip\n• Categorized groups\n• Location-based prayer times',
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