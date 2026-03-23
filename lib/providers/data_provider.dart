import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/salat_model.dart';

final salawatProvider = FutureProvider<List<SalatModel>>((ref) async {
  // Try to get from Hive first
  final box = await Hive.openBox<SalatModel>('salawat');
  
  if (box.isNotEmpty && !kIsWeb) {
    print('Loading ${box.length} items from Hive cache');
    return box.values.toList();
  }
  
  // If empty or on web, load from JSON
  print('Loading from JSON...');
  final jsonString = await rootBundle.loadString('assets/json/tanbih_clean.json');
  final List<dynamic> jsonList = jsonDecode(jsonString);
  
  final salawatList = SalatModel.fromJsonList(jsonList);
  
  // Store in Hive only on mobile
  if (!kIsWeb) {
    await box.clear();
    for (var salat in salawatList) {
      await box.put(salat.id, salat);
    }
    print('Cached ${salawatList.length} items');
  }
  
  return salawatList;
});

// Provider for introduction
final introductionProvider = FutureProvider<List<SalatModel>>((ref) async {
  final all = await ref.watch(salawatProvider.future);
  return all.where((s) => s.isIntroduction).toList();
});

// Provider for juz 1
final juz1Provider = FutureProvider<List<SalatModel>>((ref) async {
  final all = await ref.watch(salawatProvider.future);
  return all.where((s) => s.juz == 1).toList();
});

// Provider for juz 2
final juz2Provider = FutureProvider<List<SalatModel>>((ref) async {
  final all = await ref.watch(salawatProvider.future);
  return all.where((s) => s.juz == 2).toList();
});

// Provider for end of salawat
final endOfSalawatProvider = FutureProvider<List<SalatModel>>((ref) async {
  final all = await ref.watch(salawatProvider.future);
  return all.where((s) => s.isEndOfSalawat).toList();
});

// Provider for end of dua
final endOfDuaProvider = FutureProvider<List<SalatModel>>((ref) async {
  final all = await ref.watch(salawatProvider.future);
  return all.where((s) => s.isEndOfDua).toList();
});

// Generic provider by juz
final salawatByJuzProvider = FutureProvider.family<List<SalatModel>, int>((ref, juz) async {
  final all = await ref.watch(salawatProvider.future);
  return all.where((s) => s.juz == juz).toList();
});

// Provider for chapters (babs) in a specific juz
final chaptersByJuzProvider = FutureProvider.family<List<String>, int>((ref, juz) async {
  final all = await ref.watch(salawatByJuzProvider(juz).future);
  final chapters = <String>{};
  for (final item in all) {
    if (item.bab.isNotEmpty) {
      chapters.add(item.bab);
    }
  }
  return chapters.toList()..sort();
});

// Provider for salawat by bab and juz
final salawatByBabProvider = FutureProvider.family<List<SalatModel>, Map<String, dynamic>>((ref, params) async {
  final juz = params['juz'] as int;
  final bab = params['bab'] as String;
  final all = await ref.watch(salawatByJuzProvider(juz).future);
  return all.where((s) => s.bab == bab).toList();
});

// Provider to get a single salat by ID - FIXED
final salatByIdProvider = FutureProvider.family<SalatModel?, int>((ref, id) async {
  // Make return type nullable by adding '?'
  final box = await Hive.openBox<SalatModel>('salawat');
  if (kIsWeb || box.isEmpty) {
    final all = await ref.watch(salawatProvider.future);
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (e) {
      return null; // Return null if not found
    }
  }
  return box.get(id);
});