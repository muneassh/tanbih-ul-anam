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
import '../providers/settings_provider.dart';
import '../widgets/ad_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  
  // Prayer times data (in order)
  final List<Map<String, String>> _prayerTimes = [
    {'ar': 'الفجر', 'en': 'Fajr', 'time': '05:12'},
    {'ar': 'الشروق', 'en': 'Sunrise', 'time': '06:22'},
    {'ar': 'الظهر', 'en': 'Dhuhr', 'time': '12:25'},
    {'ar': 'العصر', 'en': 'Asr', 'time': '15:45'},
    {'ar': 'المغرب', 'en': 'Maghrib', 'time': '18:30'},
    {'ar': 'العشاء', 'en': 'Isha', 'time': '19:45'},
  ];
  
  // Track which prayer is currently active
  String? _activePrayer;
  String? _upcomingPrayer;
  int? _upcomingMinutes;
  Timer? _timer;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    
    // Initialize blinking animation for active prayer
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
    
    // Start timer after initState completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _checkPrayerTimes();
      });
      _checkPrayerTimes(); // Initial check
    });
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
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  void _checkPrayerTimes() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    // Find current prayer (active within 30 minutes after its time)
    String? activePrayer;
    for (var prayer in _prayerTimes) {
      final prayerTime = prayer['time']!;
      final prayerMinutes = _getMinutesFromTime(prayerTime);
      
      if (currentMinutes >= prayerMinutes && currentMinutes < prayerMinutes + 30) {
        activePrayer = prayer['en'];
        break;
      }
    }
    
    // Find next upcoming prayer (within 15 minutes)
    String? upcomingPrayer;
    int? upcomingMinutes;
    
    for (var prayer in _prayerTimes) {
      final prayerTime = prayer['time']!;
      final prayerMinutes = _getMinutesFromTime(prayerTime);
      
      if (prayerMinutes > currentMinutes) {
        final diff = prayerMinutes - currentMinutes;
        if (diff <= 15) {
          upcomingPrayer = prayer['en'];
          upcomingMinutes = diff;
          break;
        }
      }
    }
    
    // Handle midnight case (next day's Fajr)
    if (upcomingPrayer == null) {
      final firstPrayerMinutes = _getMinutesFromTime(_prayerTimes[0]['time']!);
      final diff = (firstPrayerMinutes + 24 * 60) - currentMinutes;
      if (diff <= 15) {
        upcomingPrayer = _prayerTimes[0]['en'];
        upcomingMinutes = diff;
      }
    }
    
    // Update state if changed
    if (activePrayer != _activePrayer) {
      setState(() {
        _activePrayer = activePrayer;
      });
      
      if (activePrayer != null) {
        _showPrayerNotification(activePrayer, 'started');
      }
    }
    
    if (upcomingPrayer != _upcomingPrayer || upcomingMinutes != _upcomingMinutes) {
      setState(() {
        _upcomingPrayer = upcomingPrayer;
        _upcomingMinutes = upcomingMinutes;
      });
      
      if (upcomingPrayer != null && upcomingMinutes != null && upcomingMinutes <= 5) {
        _showPrayerNotification(upcomingPrayer, 'upcoming', upcomingMinutes);
      }
    }
  }

  void _showPrayerNotification(String prayer, String type, [int? minutes]) {
    // Use addPostFrameCallback to ensure Scaffold is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final prayerData = _prayerTimes.firstWhere(
        (p) => p['en'] == prayer,
        orElse: () => {'ar': prayer, 'en': prayer},
      );
      
      final settings = ref.read(settingsProvider);
      final name = settings.language == AppLanguage.arabic ? prayerData['ar']! : prayerData['en']!;
      
      String message;
      Color backgroundColor;
      
      if (type == 'started') {
        message = 'حان الآن وقت صلاة $name';
        backgroundColor = Colors.green;
      } else {
        message = 'متبقي $minutes دقيقة على صلاة $name';
        backgroundColor = Colors.orange;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(type == 'started' ? Icons.access_time : Icons.timer, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.amiri(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  String _getLocalizedText(String ar, String en) {
    final settings = ref.watch(settingsProvider);
    return settings.language == AppLanguage.arabic ? ar : en;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Find upcoming prayer for highlighting
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    String? upcomingPrayer;
    int? upcomingTimeDiff;
    
    for (var entry in _prayerTimes) {
      final prayerTime = entry['time']!;
      final parts = prayerTime.split(':');
      final prayerMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final diff = prayerMinutes - currentMinutes;
      
      if (diff > 0 && diff <= 15) {
        if (upcomingPrayer == null || diff < upcomingTimeDiff!) {
          upcomingPrayer = entry['en'];
          upcomingTimeDiff = diff;
        }
      }
    }
    
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
                              icon: const Icon(Icons.search,
                                  color: Colors.white, size: 22),
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
                              icon: const Icon(Icons.settings_outlined,
                                  color: Colors.white, size: 22),
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
                      
                      // Title
                      Expanded(
                        child: Text(
                          _getLocalizedText('تنبيه الأنام', 'Tanbih al-Anam'),
                          style: GoogleFonts.amiri(
                            fontSize: screenWidth < 360 ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black54,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
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
                              icon: const Icon(Icons.bookmark_border,
                                  color: Colors.white, size: 20),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                
                // Prayer times bar with highlighting
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
                        for (int i = 0; i < _prayerTimes.length; i++)
                          _buildPrayerTime(
                            _prayerTimes[i]['ar']!,
                            _prayerTimes[i]['en']!,
                            _prayerTimes[i]['time']!,
                            isActive: _activePrayer == _prayerTimes[i]['en'],
                            isUpcoming: _upcomingPrayer == _prayerTimes[i]['en'],
                          ),
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

  Widget _buildPrayerTime(String arLabel, String enLabel, String time, 
      {required bool isActive, required bool isUpcoming}) {
    final settings = ref.watch(settingsProvider);
    final label = settings.language == AppLanguage.arabic ? arLabel : enLabel;
    
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
    
    // For upcoming prayer - orange bold (static)
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
    
    // Normal prayer - white
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