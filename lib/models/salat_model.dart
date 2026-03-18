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

  SalatModel({
    required this.id,
    required this.arabic,
    required this.bab,
    required this.juz,
    required this.page,
  });

  factory SalatModel.fromJson(Map<String, dynamic> json) {
    return SalatModel(
      id: json['id'] as int,
      arabic: json['arabic'] as String,
      bab: (json['bab'] as String?) ?? '',
      juz: json['juz'] as int,
      page: json['page'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'arabic': arabic,
        'bab': bab,
        'juz': juz,
        'page': page,
      };
}