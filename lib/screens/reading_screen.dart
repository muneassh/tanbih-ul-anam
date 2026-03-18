import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tanbihulanam/models/salat_model.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/services/bookmark_service.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  final SalatModel salat;
  final bool isInJuzView;
  final List<SalatModel>? allSalawat;
  final int? currentIndex;
  final bool isFullScreen;
  final VoidCallback? onToggleFullScreen;

  const ReadingScreen({
    super.key, 
    required this.salat,
    this.isInJuzView = false,
    this.allSalawat,
    this.currentIndex,
    this.isFullScreen = false,
    this.onToggleFullScreen,
  });

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  bool _isBookmarked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
    if (!widget.isInJuzView) {
      _saveLastRead();
    }
  }

  Future<void> _checkBookmark() async {
    final bookmarked = await BookmarkService.isBookmarked(widget.salat.id);
    if (mounted) {
      setState(() {
        _isBookmarked = bookmarked;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await BookmarkService.removeBookmark(widget.salat.id);
    } else {
      await BookmarkService.addBookmark(widget.salat.id);
    }
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'تمت الإضافة إلى المفضلة' : 'تمت الإزالة من المفضلة'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveLastRead() async {
    final settings = ref.read(settingsProvider);
    if (settings.autoSaveLastRead) {
      await ref.read(settingsProvider.notifier).updateLastRead(
        widget.salat.juz,
        widget.salat.page,
        widget.salat.id,
      );
    }
  }

  void _shareText() {
    final String textToShare = '''
${widget.salat.arabic}

- من كتاب تنبيه الأنام
- الصفحة: ${widget.salat.page}
- الجزء: ${widget.salat.juz}
''';
    
    Share.share(textToShare, subject: 'صلاة من تنبيه الأنام');
  }

  TextStyle _getFontStyle(AppFont font, double size, {Color? color}) {
    switch (font) {
      case AppFont.amiri:
        return GoogleFonts.amiri(fontSize: size, height: 1.5, color: color);
      case AppFont.noto:
        return GoogleFonts.notoNaskhArabic(fontSize: size, height: 1.5, color: color);
      case AppFont.cairo:
        return GoogleFonts.cairo(fontSize: size, height: 1.5, color: color);
      case AppFont.tajawal:
        return GoogleFonts.tajawal(fontSize: size, height: 1.5, color: color);
      default:
        return GoogleFonts.amiri(fontSize: size, height: 1.5, color: color);
    }
  }

  List<TextSpan> _buildHighlightedPrayerSpans(String text, TextStyle baseStyle) {
    List<TextSpan> spans = [];
    List<String> patterns = [
      'محمد',
      'مُحَمَّد',
      'مُحَمَّدٍ',
      'مُحَمَّدًا',
      'مُحَمَّدَ',
      'محمداً',
      'محمدٍ',
      'محمدًا',
      'ﷺ',
    ];
    
    String remainingText = text;
    
    while (remainingText.isNotEmpty) {
      int earliestMatch = -1;
      String earliestPattern = '';
      
      for (String pattern in patterns) {
        int index = remainingText.indexOf(pattern);
        if (index != -1 && (earliestMatch == -1 || index < earliestMatch)) {
          earliestMatch = index;
          earliestPattern = pattern;
        }
      }
      
      if (earliestMatch == -1) {
        if (remainingText.isNotEmpty) {
          spans.add(TextSpan(text: remainingText, style: baseStyle));
        }
        break;
      }
      
      if (earliestMatch > 0) {
        spans.add(TextSpan(
          text: remainingText.substring(0, earliestMatch),
          style: baseStyle,
        ));
      }
      
      spans.add(TextSpan(
        text: earliestPattern,
        style: baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.red,
          fontSize: baseStyle.fontSize! * 1.1,
        ),
      ));
      
      remainingText = remainingText.substring(earliestMatch + earliestPattern.length);
    }
    
    return spans;
  }

  // Calculate how many salawat can fit on one page
  int _getSalawatPerPage(double fontSize, double screenHeight) {
    double lineHeight = fontSize * 1.5;
    double availableHeight = screenHeight * (widget.isFullScreen ? 0.95 : 0.75);
    int avgLinesPerSalat = 5;
    double salatHeight = avgLinesPerSalat * lineHeight;
    return (availableHeight / salatHeight).floor();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final screenSize = MediaQuery.of(context).size;
    
    // In full screen mode with multiple salawat available
    if (widget.isFullScreen && widget.allSalawat != null && widget.currentIndex != null) {
      int salawatPerPage = _getSalawatPerPage(settings.fontSize, screenSize.height);
      salawatPerPage = salawatPerPage.clamp(1, 6); // Show 1-6 salawat per page
      
      int startIndex = widget.currentIndex!;
      int endIndex = (startIndex + salawatPerPage).clamp(0, widget.allSalawat!.length);
      
      return Container(
        color: settings.isDarkMode ? const Color(0xFF121212) : const Color(0xFFFDF5E6),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: endIndex - startIndex,
          itemBuilder: (context, index) {
            final salat = widget.allSalawat![startIndex + index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: settings.isDarkMode 
                    ? const Color(0xFF1E1E1E).withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: settings.isDarkMode 
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFF0A5C36).withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  SelectableText.rich(
                    TextSpan(
                      children: _buildHighlightedPrayerSpans(
                        salat.arabic,
                        _getFontStyle(
                          settings.selectedFont, 
                          settings.fontSize - 2,
                          color: settings.isDarkMode ? Colors.white70 : const Color(0xFF2C1810),
                        ),
                      ),
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                  // Page number only at the bottom of the screen, not per salawat
                ],
              ),
            );
          },
        ),
      );
    }
    
    // Normal single salawat view
    return Container(
      color: settings.isDarkMode ? const Color(0xFF121212) : const Color(0xFFFDF5E6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Only show app bar equivalent if not in Juz view
            if (!widget.isInJuzView) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'صفحة ${widget.salat.page}',
                    style: GoogleFonts.amiri(fontSize: 18),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        ),
                        onPressed: _isLoading ? null : _toggleBookmark,
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: _shareText,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
            ],
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: settings.isDarkMode 
                        ? const Color(0xFF1E1E1E)
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SelectableText.rich(
                    TextSpan(
                      children: _buildHighlightedPrayerSpans(
                        widget.salat.arabic,
                        _getFontStyle(
                          settings.selectedFont, 
                          settings.fontSize,
                          color: settings.isDarkMode ? Colors.white70 : const Color(0xFF2C1810),
                        ),
                      ),
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            
            // Page number - only once at bottom
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0A5C36).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'الصفحة ${widget.salat.page}',
                style: GoogleFonts.amiri(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A5C36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}