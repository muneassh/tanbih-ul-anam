import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PrayerTimesService {
  static PrayerTimesService? _instance;
  static PrayerTimesService get instance => _instance ??= PrayerTimesService._();
  
  PrayerTimesService._() {}
  
  Position? _currentPosition;
  String? _currentCity;
  String? _currentCountry;
  Map<String, String>? _currentPrayerTimes;
  Timer? _prayerCheckTimer;
  PrayerTimes? _prayerTimes;
  
  Future<bool> requestLocationPermission() async {
    if (kIsWeb) return false;
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }
  
  Future<Map<String, dynamic>> getCurrentLocation() async {
    if (kIsWeb) {
      return {'city': 'Mecca', 'country': 'Saudi Arabia', 'lat': 21.4225, 'lng': 39.8262};
    }
    
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        _currentCity = placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? 'Unknown';
        _currentCountry = placemarks.first.country ?? 'Unknown';
      }
      
      return {
        'city': _currentCity ?? 'Unknown',
        'country': _currentCountry ?? 'Unknown',
        'lat': _currentPosition!.latitude,
        'lng': _currentPosition!.longitude,
      };
    } catch (e) {
      print('Error getting location: $e');
      return {'city': 'Mecca', 'country': 'Saudi Arabia', 'lat': 21.4225, 'lng': 39.8262};
    }
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  Future<Map<String, String>> getPrayerTimes() async {
    if (kIsWeb) {
      return _getDefaultPrayerTimes();
    }
    
    try {
      final location = await getCurrentLocation();
      final lat = location['lat'] as double;
      final lng = location['lng'] as double;
      
      final coordinates = Coordinates(lat, lng);
      
      final now = DateTime.now();
      final date = DateComponents(now.year, now.month, now.day);
      
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      params.highLatitudeRule = HighLatitudeRule.middle_of_the_night;
      
      _prayerTimes = PrayerTimes(coordinates, date, params);
      
      final times = {
        'Fajr': _formatTime(_prayerTimes!.fajr),
        'Sunrise': _formatTime(_prayerTimes!.sunrise),
        'Dhuhr': _formatTime(_prayerTimes!.dhuhr),
        'Asr': _formatTime(_prayerTimes!.asr),
        'Maghrib': _formatTime(_prayerTimes!.maghrib),
        'Isha': _formatTime(_prayerTimes!.isha),
      };
      
      _currentPrayerTimes = times;
      return times;
    } catch (e) {
      print('Error getting prayer times: $e');
      return _getDefaultPrayerTimes();
    }
  }
  
  Map<String, String> _getDefaultPrayerTimes() {
    return {
      'Fajr': '05:12',
      'Sunrise': '06:22',
      'Dhuhr': '12:25',
      'Asr': '15:45',
      'Maghrib': '18:30',
      'Isha': '19:45',
    };
  }
  
  void startPrayerMonitoring(Function(Map<String, String>) onPrayerTimesUpdate, Function(String, String) onPrayerStart) {
    if (kIsWeb) return;
    
    _prayerCheckTimer?.cancel();
    _prayerCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final times = await getPrayerTimes();
      onPrayerTimesUpdate(times);
      _checkForPrayerStart(times, onPrayerStart);
    });
  }
  
  void _checkForPrayerStart(Map<String, String> times, Function(String, String) onPrayerStart) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final prayers = {
      'Fajr': 'الفجر',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };
    
    for (var entry in prayers.entries) {
      final prayerTime = times[entry.key];
      if (prayerTime != null && prayerTime == currentTime) {
        onPrayerStart(entry.key, entry.value);
      }
    }
  }
  
  void stopMonitoring() {
    _prayerCheckTimer?.cancel();
  }
}