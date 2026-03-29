import 'package:tanbihulanam/models/salat_model.dart';
import 'package:tanbihulanam/data/groups_data.dart';
import 'package:tanbihulanam/data/groups_classified.dart';

class OptimizedClassificationService {
  static Map<int, List<int>>? _cachedClassification;
  static Map<int, List<SalatModel>>? _cachedGroupSalawat;
  
  // Quick lookup map - O(1) access
  static Map<int, List<int>> getClassification(List<SalatModel> allSalawat) {
    if (_cachedClassification != null) {
      return _cachedClassification!;
    }
    
    final Map<int, List<int>> classification = {};
    final groups = GroupsData.getGroups();
    
    // Initialize empty lists
    for (var group in groups) {
      classification[group.id] = [];
    }
    
    // Use pre-classified IDs first
    for (var group in groups) {
      final preClassifiedIds = GroupsClassifiedData.getSalawatIdsForGroup(group.id);
      classification[group.id]!.addAll(preClassifiedIds);
    }
    
    // Remove duplicates from each group
    for (var group in groups) {
      classification[group.id] = classification[group.id]!.toSet().toList();
    }
    
    _cachedClassification = classification;
    return classification;
  }
  
  // Get salawat for a specific group - O(1) lookup
  static List<SalatModel> getSalawatForGroup(int groupId, List<SalatModel> allSalawat) {
    if (_cachedGroupSalawat != null && _cachedGroupSalawat!.containsKey(groupId)) {
      return _cachedGroupSalawat![groupId]!;
    }
    
    final classification = getClassification(allSalawat);
    final salawatIds = classification[groupId] ?? [];
    
    // Create a map for O(1) lookup of salawat by ID
    final salawatMap = {for (var s in allSalawat) s.id: s};
    
    final result = <SalatModel>[];
    for (var id in salawatIds) {
      final salat = salawatMap[id];
      if (salat != null) {
        result.add(salat);
      }
    }
    
    if (_cachedGroupSalawat == null) {
      _cachedGroupSalawat = {};
    }
    _cachedGroupSalawat![groupId] = result;
    
    return result;
  }
  
  // Get group statistics without iterating through all salawat
  static Map<String, dynamic> getGroupStatistics(List<SalatModel> allSalawat) {
    final classification = getClassification(allSalawat);
    final groups = GroupsData.getGroups();
    
    final stats = <String, dynamic>{
      'total_salawat': allSalawat.length,
      'groups': {},
    };
    
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
  
  // Refresh cache
  static void refreshCache() {
    _cachedClassification = null;
    _cachedGroupSalawat = null;
  }
}