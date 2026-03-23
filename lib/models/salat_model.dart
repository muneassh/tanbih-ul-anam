import 'package:hive_flutter/hive_flutter.dart';

part 'salat_model.g.dart';

@HiveType(typeId: 0)
class SalatModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String arabic;

  @HiveField(2)
  final String bab;

  @HiveField(3)
  final int juz;

  @HiveField(4)
  final int page;

  @HiveField(5)
  final String type;

  SalatModel({
    required this.id,
    required this.arabic,
    required this.bab,
    required this.juz,
    required this.page,
    required this.type,
  });

  factory SalatModel.fromJson(Map<String, dynamic> json) {
    // Handle different JSON structures
    if (json.containsKey('items')) {
      // This is a container for juz items - we don't create a model from this directly
      throw Exception('Use fromJsonList for container items');
    }
    
    return SalatModel(
      id: json['id'] as int,
      arabic: json['arabic'] as String,
      bab: json['bab'] as String? ?? '',
      juz: json['juz'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      type: json['type'] as String? ?? 'unknown',
    );
  }

  static List<SalatModel> fromJsonList(List<dynamic> jsonList) {
    List<SalatModel> models = [];
    int idCounter = 1;
    
    for (var item in jsonList) {
      if (item is Map<String, dynamic>) {
        // Check if this is a container with items (juz1 or juz2)
        if (item.containsKey('items') && item['items'] is List) {
          int juzNumber = item['juz'] as int? ?? 1;
          String type = item['type'] as String? ?? 'juz';
          
          // Process each item in the items array
          for (var subItem in item['items'] as List) {
            if (subItem is Map<String, dynamic>) {
              models.add(SalatModel(
                id: idCounter++,
                arabic: subItem['arabic'] as String,
                bab: subItem['bab'] as String? ?? '',
                juz: juzNumber,
                page: subItem['page'] as int? ?? 1,
                type: type,
              ));
            }
          }
        } else {
          // Regular single item
          models.add(SalatModel(
            id: idCounter++,
            arabic: item['arabic'] as String,
            bab: item['bab'] as String? ?? '',
            juz: item['juz'] as int? ?? 0,
            page: item['page'] as int? ?? 1,
            type: item['type'] as String? ?? 'unknown',
          ));
        }
      }
    }
    
    return models;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'arabic': arabic,
        'bab': bab,
        'juz': juz,
        'page': page,
        'type': type,
      };

  // Helper to check if this is a special section
  bool get isIntroduction => type == 'introduction';
  bool get isEndOfSalawat => type == 'end of salawat' || type == 'end_of_salawat';
  bool get isEndOfDua => type == 'end of dua' || type == 'end_of_dua' || type == 'dua';
  bool get isJuz1 => type == 'juz1' || juz == 1;
  bool get isJuz2 => type == 'juz2' || juz == 2;
  bool get isRegularJuz => juz == 1 || juz == 2;
}