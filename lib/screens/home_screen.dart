import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _HomeScreenState extends ConsumerState<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
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

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  String _getLocalizedText(String ar, String en) {
    final settings = ref.watch(settingsProvider);
    return settings.language == AppLanguage.arabic ? ar : en;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/landscape.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF0A5C36),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.20),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar - FIXED HEIGHT OVERFLOW
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left icons
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
                      
                      // Right icons
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

                // Resume reading button - goes to exact page
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
                          'صفحة ${settings.lastReadPage}',
                          'Page ${settings.lastReadPage}',
                        ),
                        style: GoogleFonts.amiri(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A5C36).withOpacity(0.8),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),

                const Spacer(flex: 1),

                // Prayer times bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.50),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPrayerTime('الفجر', 'Fajr', '5:12'),
                        _buildDivider(),
                        _buildPrayerTime('الشروق', 'Sunrise', '6:22'),
                        _buildDivider(),
                        _buildPrayerTime('الظهر', 'Dhuhr', '12:25'),
                        _buildDivider(),
                        _buildPrayerTime('العصر', 'Asr', '3:45'),
                        _buildDivider(),
                        _buildPrayerTime('المغرب', 'Maghrib', '6:30'),
                        _buildDivider(),
                        _buildPrayerTime('العشاء', 'Isha', '7:45'),
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
      height: 25,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildPrayerTime(String arLabel, String enLabel, String time) {
    final settings = ref.watch(settingsProvider);
    final label = settings.language == AppLanguage.arabic ? arLabel : enLabel;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 9,
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