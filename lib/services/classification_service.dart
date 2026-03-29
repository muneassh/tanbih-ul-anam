import 'package:tanbihulanam/models/salat_model.dart';
import 'package:tanbihulanam/data/groups_data.dart';

class ClassificationService {
  static Map<int, List<int>>? _cachedClassification;
  static Map<int, List<SalatModel>>? _cachedGroupSalawat;
  
  static Map<int, List<int>> classifySalawat(List<SalatModel> allSalawat) {
    if (_cachedClassification != null) {
      return _cachedClassification!;
    }
    
    final Map<int, List<int>> groupSalawatMap = {};
    final groups = GroupsData.getGroups();
    
    // Initialize empty lists for each group
    for (var group in groups) {
      groupSalawatMap[group.id] = [];
    }
    
    print('\n=== Classification Started ===');
    print('Total salawat to classify: ${allSalawat.length}');
    
    // Keyword-based classification with logging
    for (var salat in allSalawat) {
      final arabicText = salat.arabic;
      final babText = salat.bab;
      final lowerText = arabicText.toLowerCase();
      
      for (var group in groups) {
        for (var keyword in group.keywords) {
          if (arabicText.contains(keyword) || babText.contains(keyword)) {
            if (!groupSalawatMap[group.id]!.contains(salat.id)) {
              groupSalawatMap[group.id]!.add(salat.id);
              print('Matched: ${group.nameAr} -> Salat ${salat.id} (keyword: "$keyword")');
            }
            break;
          }
        }
      }
    }
    
    // Manual mapping with expanded keywords
    _applyManualMapping(groupSalawatMap, allSalawat);
    
    // Print final statistics
    print('\n=== Classification Results ===');
    for (var group in groups) {
      print('${group.nameAr}: ${groupSalawatMap[group.id]?.length ?? 0} salawat');
    }
    print('===============================\n');
    
    _cachedClassification = groupSalawatMap;
    return groupSalawatMap;
  }
  
  static void _applyManualMapping(Map<int, List<int>> groupSalawatMap, List<SalatModel> allSalawat) {
    // Expanded manual keywords for problem groups
    final manualKeywords = {
      1: [ // Nikah
        'زوج', 'زوجة', 'نكاح', 'زواج', 'عروس', 'عرس', 'خطبة', 'تزويج', 'أهل', 'بيت',
        'ذرية', 'ولد', 'بنين', 'المودة', 'الرحمة', 'العشرة', 'الطلاق', 'زفاف', 'خطيب', 'خطيبة'
      ],
      6: [ // Gatherings (Majlis)
        'مجلس', 'اجتماع', 'لقاء', 'جمع', 'حضور', 'جليس', 'ندوة', 'محفل', 'منتدى', 'جماعة',
        'الاجتماعات', 'المؤتمرات', 'اللقاء', 'التجمع', 'المحفل', 'المنتدى', 'الندوة'
      ],
      9: [ // Relief (Farj al-Hamm)
        'هم', 'غم', 'كرب', 'فرج', 'ضيق', 'حزن', 'بلاء', 'شدة', 'كربة', 'انشراح',
        'تيسير', 'تسهيل', 'الهموم', 'الكروب', 'الأحزان', 'الأتراح', 'الغموم'
      ],
      10: [ // Charity (Sadaqah)
        'صدقة', 'زكاة', 'إنفاق', 'إحسان', 'خير', 'عطاء', 'تبرع', 'تصدق', 'مواساة',
        'إيثار', 'بذل', 'إطعام', 'كفالة', 'إغاثة', 'مساعدة', 'معونة', 'الصدقات', 'الزكوات'
      ],
    };
    
    for (var salat in allSalawat) {
      final text = salat.arabic;
      
      for (var entry in manualKeywords.entries) {
        final groupId = entry.key;
        final keywords = entry.value;
        
        for (var keyword in keywords) {
          if (text.contains(keyword)) {
            if (!groupSalawatMap[groupId]!.contains(salat.id)) {
              groupSalawatMap[groupId]!.add(salat.id);
              print('Manual match: ${_getGroupName(groupId)} -> Salat ${salat.id} (keyword: "$keyword")');
            }
            break;
          }
        }
      }
    }
  }
  
  static String _getGroupName(int groupId) {
    switch (groupId) {
      case 1: return 'النكاح (Marriage)';
      case 2: return 'الشفاء (Healing)';
      case 3: return 'الجنازة (Funeral)';
      case 4: return 'الرزق (Sustenance)';
      case 5: return 'الحفظ (Protection)';
      case 6: return 'المجلس (Gatherings)';
      case 7: return 'المولد (Mawlid)';
      case 8: return 'الدعاء (Dua)';
      case 9: return 'فرج الهم (Relief)';
      case 10: return 'الصدقة (Charity)';
      default: return 'Unknown';
    }
  }
  
  static List<SalatModel> getSalawatForGroup(int groupId, List<SalatModel> allSalawat, Map<int, List<int>> classification) {
    if (_cachedGroupSalawat != null && _cachedGroupSalawat!.containsKey(groupId)) {
      return _cachedGroupSalawat![groupId]!;
    }
    
    final salawatIds = classification[groupId] ?? [];
    final result = allSalawat.where((s) => salawatIds.contains(s.id)).toList();
    
    if (_cachedGroupSalawat == null) {
      _cachedGroupSalawat = {};
    }
    _cachedGroupSalawat![groupId] = result;
    
    return result;
  }
  
  static Map<String, dynamic> getGroupStatistics(List<SalatModel> allSalawat, Map<int, List<int>> classification) {
    final stats = <String, dynamic>{
      'total_salawat': allSalawat.length,
      'groups': {},
    };
    
    final groups = GroupsData.getGroups();
    int totalClassified = 0;
    
    for (var group in groups) {
      final count = classification[group.id]?.length ?? 0;
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
    
    return stats;
  }
  
  static void refreshCache() {
    _cachedClassification = null;
    _cachedGroupSalawat = null;
    print('Classification cache refreshed');
  }
  
  static List<Map<String, dynamic>> getTopGroups(Map<int, List<int>> classification, int limit) {
    final groups = GroupsData.getGroups();
    final List<Map<String, dynamic>> groupCounts = [];
    
    for (var group in groups) {
      groupCounts.add({
        'group': group,
        'count': classification[group.id]?.length ?? 0,
      });
    }
    
    groupCounts.sort((a, b) => b['count'].compareTo(a['count']));
    return groupCounts.take(limit).toList();
  }
}