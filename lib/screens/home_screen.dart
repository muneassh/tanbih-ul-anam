import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'juz_screen.dart';
import 'settings_screen.dart';
import 'introduction_screen.dart';
import 'conclusion_screen.dart';
import 'bookmarks_screen.dart';
import 'search_screen.dart';
import 'groups_screen.dart';
import '../providers/settings_provider.dart';
import '../widgets/ad_widget.dart';
import '../services/prayer_times_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  
  // Prayer times data
  Map<String, String> _prayerTimes = {
    'Fajr': '--:--',
    'Sunrise': '--:--',
    'Dhuhr': '--:--',
    'Asr': '--:--',
    'Maghrib': '--:--',
    'Isha': '--:--',
  };
  
  // Prayer names for display
  final Map<String, Map<String, String>> _prayerNames = {
    'Fajr': {'ar': 'الفجر', 'en': 'Fajr'},
    'Sunrise': {'ar': 'الشروق', 'en': 'Sunrise'},
    'Dhuhr': {'ar': 'الظهر', 'en': 'Dhuhr'},
    'Asr': {'ar': 'العصر', 'en': 'Asr'},
    'Maghrib': {'ar': 'المغرب', 'en': 'Maghrib'},
    'Isha': {'ar': 'العشاء', 'en': 'Isha'},
  };
  
  String? _activePrayer;
  String? _upcomingPrayer;
  int? _upcomingMinutes;
  Timer? _timer;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  String _locationStatus = 'جاري تحديد الموقع...';
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    
    // Initialize blinking animation
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
    
    // Initialize prayer times service
    _initializePrayerTimes();
  }

  Future<void> _initializePrayerTimes() async {
    final service = PrayerTimesService.instance;
    
    // Request location permission
    final hasPermission = await service.requestLocationPermission();
    if (!hasPermission) {
      setState(() {
        _locationStatus = 'يرجى تفعيل الموقع';
        _isLoadingLocation = false;
      });
      return;
    }
    
    // Get location and prayer times
    final location = await service.getCurrentLocation();
    setState(() {
      _locationStatus = '${location['city']}, ${location['country']}';
      _isLoadingLocation = false;
    });
    
    // Get initial prayer times
    final times = await service.getPrayerTimes();
    setState(() {
      _prayerTimes = times;
    });
    
    // Start monitoring
    service.startPrayerMonitoring(
      (times) {
        if (mounted) {
          setState(() {
            _prayerTimes = times;
          });
        }
      },
      (prayerEn, prayerAr) {
        if (mounted) {
          _showPrayerNotification(prayerEn, prayerAr);
          setState(() {
            _activePrayer = prayerEn;
          });
        }
      },
    );
    
    // Start checking prayer times
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkPrayerTimes();
    });
    _checkPrayerTimes();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _timer?.cancel();
    _blinkController.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8891897633102231/2923488560',
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isBannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('BannerAd failed to load: $error');
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  int _getMinutesFromTime(String time) {
    if (time == '--:--') return 0;
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  void _checkPrayerTimes() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    // Find current prayer (active within 30 minutes after its time)
    String? activePrayer;
    for (var prayer in _prayerTimes.keys) {
      if (prayer == 'Sunrise') continue;
      final prayerMinutes = _getMinutesFromTime(_prayerTimes[prayer]!);
      
      if (currentMinutes >= prayerMinutes && currentMinutes < prayerMinutes + 30) {
        activePrayer = prayer;
        break;
      }
    }
    
    // Find next upcoming prayer (within 15 minutes)
    String? upcomingPrayer;
    int? upcomingMinutes;
    
    for (var prayer in _prayerTimes.keys) {
      if (prayer == 'Sunrise') continue;
      final prayerMinutes = _getMinutesFromTime(_prayerTimes[prayer]!);
      
      if (prayerMinutes > currentMinutes) {
        final diff = prayerMinutes - currentMinutes;
        if (diff <= 15) {
          upcomingPrayer = prayer;
          upcomingMinutes = diff;
          break;
        }
      }
    }
    
    // Update state
    if (activePrayer != _activePrayer) {
      setState(() {
        _activePrayer = activePrayer;
      });
    }
    
    if (upcomingPrayer != _upcomingPrayer || upcomingMinutes != _upcomingMinutes) {
      setState(() {
        _upcomingPrayer = upcomingPrayer;
        _upcomingMinutes = upcomingMinutes;
      });
    }
  }

  void _showPrayerNotification(String prayerEn, String prayerAr) {
    final settings = ref.read(settingsProvider);
    final prayerName = settings.language == AppLanguage.arabic ? prayerAr : prayerEn;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                settings.language == AppLanguage.arabic
                    ? 'حان الآن وقت صلاة $prayerName'
                    : 'It\'s time for $prayerName prayer',
                style: GoogleFonts.amiri(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getLocalizedText(String ar, String en) {
    final settings = ref.watch(settingsProvider);
    return settings.language == AppLanguage.arabic ? ar : en;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen background
          Positioned.fill(
            child: Image.asset(
              'assets/images/landscape.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF0A5C36),
              ),
            ),
          ),
          
          // Subtle dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.20),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: const Icon(Icons.grid_view, color: Colors.white, size: 22),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const GroupsScreen()),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: const Icon(Icons.search, color: Colors.white, size: 22),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => SettingsScreen()),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                      
                      // App Logo/Title
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/icon.png',
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.mosque,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      
                      // Right side icons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: Icon(
                                Icons.language,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                final newLang = settings.language == AppLanguage.arabic 
                                    ? AppLanguage.english 
                                    : AppLanguage.arabic;
                                ref.read(settingsProvider.notifier).setLanguage(newLang);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Location and prayer times header
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isLoadingLocation ? 'جاري تحديد الموقع...' : _locationStatus,
                        style: GoogleFonts.amiri(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Resume reading button
                if (settings.lastReadSalatId != null && settings.lastReadPage > 0)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JuzScreen(
                              juzNumber: settings.lastReadJuz,
                              initialSalatId: settings.lastReadSalatId,
                              initialPage: settings.lastReadPage,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history, color: Colors.white, size: 14),
                      label: Text(
                        _getLocalizedText(
                          'الجزء ${settings.lastReadJuz} - صفحة ${settings.lastReadPage}',
                          'Part ${settings.lastReadJuz} - Page ${settings.lastReadPage}',
                        ),
                        style: GoogleFonts.amiri(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A5C36).withOpacity(0.8),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(140, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                
                const Spacer(flex: 1),
                
                // DEDICATION TEXT BOX
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A5C36),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إهداء',
                              style: GoogleFonts.amiri(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0A5C36),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'هذا العمل المتواضع أهديه إلى روحي أبي وإلى شيخي',
                              style: GoogleFonts.amiri(
                                fontSize: 12,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ሶዋቡን ለአባቴ እና ለሼይኼ',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                fontFamily: 'monospace',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A5C36).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Color(0xFF0A5C36),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Prayer times bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.50),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPrayerTime('Fajr', _prayerTimes['Fajr'] ?? '--:--',
                            isActive: _activePrayer == 'Fajr',
                            isUpcoming: _upcomingPrayer == 'Fajr'),
                        _buildDivider(),
                        _buildPrayerTime('Sunrise', _prayerTimes['Sunrise'] ?? '--:--',
                            isActive: false,
                            isUpcoming: false),
                        _buildDivider(),
                        _buildPrayerTime('Dhuhr', _prayerTimes['Dhuhr'] ?? '--:--',
                            isActive: _activePrayer == 'Dhuhr',
                            isUpcoming: _upcomingPrayer == 'Dhuhr'),
                        _buildDivider(),
                        _buildPrayerTime('Asr', _prayerTimes['Asr'] ?? '--:--',
                            isActive: _activePrayer == 'Asr',
                            isUpcoming: _upcomingPrayer == 'Asr'),
                        _buildDivider(),
                        _buildPrayerTime('Maghrib', _prayerTimes['Maghrib'] ?? '--:--',
                            isActive: _activePrayer == 'Maghrib',
                            isUpcoming: _upcomingPrayer == 'Maghrib'),
                        _buildDivider(),
                        _buildPrayerTime('Isha', _prayerTimes['Isha'] ?? '--:--',
                            isActive: _activePrayer == 'Isha',
                            isUpcoming: _upcomingPrayer == 'Isha'),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Main buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildMainButton('المقدمة', 'Introduction', 'intro'),
                      const SizedBox(height: 10),
                      _buildMainButton('الجزء الأول', 'Part One', 'juz1'),
                      const SizedBox(height: 10),
                      _buildMainButton('الجزء الثاني', 'Part Two', 'juz2'),
                      const SizedBox(height: 10),
                      _buildMainButton('الحلقة الختامية', 'Conclusion', 'conclusion'),
                    ],
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // Ad
                if (_isBannerAdLoaded && _bannerAd != null)
                  Container(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    margin: const EdgeInsets.only(bottom: 4),
                    child: AdWidget(ad: _bannerAd!),
                  )
                else
                  const AdSpace(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildPrayerTime(String prayerKey, String time, 
      {required bool isActive, required bool isUpcoming}) {
    final settings = ref.watch(settingsProvider);
    final prayerName = _prayerNames[prayerKey]!;
    final label = settings.language == AppLanguage.arabic ? prayerName['ar']! : prayerName['en']!;
    
    // For active prayer - red blinking
    if (isActive) {
      return AnimatedBuilder(
        animation: _blinkAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.red.withOpacity(_blinkAnimation.value),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.red.withOpacity(_blinkAnimation.value),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    
    // For upcoming prayer - orange bold
    if (isUpcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    // Normal prayer
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton(String arText, String enText, String type) {
    final settings = ref.watch(settingsProvider);
    final text = settings.language == AppLanguage.arabic ? arText : enText;
    
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          if (type == 'intro') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IntroductionScreen()),
            );
          } else if (type == 'juz1') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const JuzScreen(juzNumber: 1),
              ),
            );
          } else if (type == 'juz2') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const JuzScreen(juzNumber: 2),
              ),
            );
          } else if (type == 'conclusion') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConclusionScreen()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A5C36),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.amiri(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}