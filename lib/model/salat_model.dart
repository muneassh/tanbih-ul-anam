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

  SalatModel({required this.id, required this.arabic, required this.bab, required this.juz, required this.page});
}