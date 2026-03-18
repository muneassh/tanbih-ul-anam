import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/salat_model.dart';

final salawatProvider = FutureProvider<List<SalatModel>>((ref) async {
  // Try to get from Hive first
  final box = await Hive.openBox<SalatModel>('salawat');
  
  if (box.isNotEmpty) {
    print('Loading ${box.length} items from Hive cache');
    return box.values.toList();
  }
  
  // If empty, load from JSON and store in Hive
  print('Loading from JSON and caching...');
  final jsonString = await rootBundle.loadString('assets/json/tanbih_clean.json');
  final List<dynamic> jsonList = jsonDecode(jsonString);
  
  final salawatList = jsonList.map((dynamic item) {
    return SalatModel.fromJson(item as Map<String, dynamic>);
  }).toList();
  
  // Store in Hive
  await box.clear();
  for (var salat in salawatList) {
    await box.put(salat.id, salat);
  }
  
  return salawatList;
});

// Add a provider to get single item by ID (faster than filtering)
final salawatByIdProvider = FutureProvider.family<SalatModel?, int>((ref, id) async {
  final box = await Hive.openBox<SalatModel>('salawat');
  return box.get(id);
});

final salawatByJuzProvider = Provider.family<List<SalatModel>, int>((ref, juz) {
  final all = ref.watch(salawatProvider).valueOrNull ?? [];
  return all.where((s) => s.juz == juz).toList();
});

final chaptersProvider = Provider<List<String>>((ref) {
  final all = ref.watch(salawatProvider).valueOrNull ?? [];
  final chapters = <String>{};
  for (final item in all) {
    if (item.bab.isNotEmpty) {
      chapters.add(item.bab);
    }
  }
  return chapters.toList()..sort();
});