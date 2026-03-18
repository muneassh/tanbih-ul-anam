import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tanbihulanam/models/salat_model.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/services/bookmark_service.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  final SalatModel salat;

  const ReadingScreen({super.key, required this.salat});

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
    _saveLastRead();
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'تمت الإضافة إلى المفضلة' : 'تمت الإزالة من المفضلة'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveLastRead() async {
    final settings = ref.read(settingsProvider);
    if (settings.autoSaveLastRead) {
      ref.read(lastReadProvider.notifier).state = widget.salat.id;
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
        return GoogleFonts.amiri(fontSize: size, height: 1.8, color: color);
      case AppFont.noto:
        return GoogleFonts.notoNaskhArabic(fontSize: size, height: 1.8, color: color);
      case AppFont.cairo:
        return GoogleFonts.cairo(fontSize: size, height: 1.8, color: color);
      case AppFont.tajawal:
        return GoogleFonts.tajawal(fontSize: size, height: 1.8, color: color);
    }
  }

  List<TextSpan> _buildHighlightedPrayerSpans(String text, TextStyle baseStyle) {
    List<TextSpan> spans = [];
    String searchWord = 'محمد';
    String symbol = 'ﷺ';
    
    if (text.contains(searchWord)) {
      List<String> parts = text.split(searchWord);
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isNotEmpty) {
          // Check for ﷺ in this part
          if (parts[i].contains(symbol)) {
            List<String> symbolParts = parts[i].split(symbol);
            for (int j = 0; j < symbolParts.length; j++) {
              if (symbolParts[j].isNotEmpty) {
                spans.add(TextSpan(
                  text: symbolParts[j],
                  style: baseStyle,
                ));
              }
              if (j < symbolParts.length - 1 || parts[i].endsWith(symbol)) {
                spans.add(TextSpan(
                  text: symbol,
                  style: baseStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ));
              }
            }
          } else {
            spans.add(TextSpan(
              text: parts[i],
              style: baseStyle,
            ));
          }
        }
        if (i < parts.length - 1 || text.endsWith(searchWord)) {
          spans.add(TextSpan(
            text: searchWord,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ));
        }
      }
    } else if (text.contains(symbol)) {
      List<String> parts = text.split(symbol);
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(
            text: parts[i],
            style: baseStyle,
          ));
        }
        if (i < parts.length - 1 || text.endsWith(symbol)) {
          spans.add(TextSpan(
            text: symbol,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ));
        }
      }
    } else {
      spans.add(TextSpan(
        text: text,
        style: baseStyle,
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'صفحة ${widget.salat.page}',
          style: GoogleFonts.amiri(),
        ),
        backgroundColor: const Color(0xFF0A5C36),
        foregroundColor: Colors.white,
        actions: [
          // Bookmark button
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: _isLoading ? null : _toggleBookmark,
          ),
          // Share button
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareText,
          ),
          // Font size controls
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () {
              if (settings.fontSize > 16) {
                ref.read(settingsProvider.notifier).setFontSize(settings.fontSize - 2);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () {
              if (settings.fontSize < 32) {
                ref.read(settingsProvider.notifier).setFontSize(settings.fontSize + 2);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: settings.isDarkMode 
              ? const Color(0xFF121212) 
              : const Color(0xFFFDF5E6),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Decorative top border
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 2,
                          color: settings.isDarkMode 
                              ? Colors.white.withOpacity(0.3)
                              : const Color(0xFF0A5C36).withOpacity(0.3),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: settings.isDarkMode 
                              ? Colors.white.withOpacity(0.5)
                              : const Color(0xFF0A5C36).withOpacity(0.5),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 40,
                          height: 2,
                          color: settings.isDarkMode 
                              ? Colors.white.withOpacity(0.3)
                              : const Color(0xFF0A5C36).withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                  
                  // Main prayer text with highlighted Muhammad
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: settings.isDarkMode 
                          ? const Color(0xFF1E1E1E)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: settings.isDarkMode 
                            ? Colors.white.withOpacity(0.1)
                            : const Color(0xFF0A5C36).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(settings.isDarkMode ? 0.3 : 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                  
                  const SizedBox(height: 24),
                  
                  // Page number badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: settings.isDarkMode 
                          ? const Color(0xFF0A5C36).withOpacity(0.3)
                          : const Color(0xFF0A5C36).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: settings.isDarkMode 
                            ? Colors.white.withOpacity(0.1)
                            : const Color(0xFF0A5C36).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 18,
                          color: settings.isDarkMode ? Colors.white70 : const Color(0xFF0A5C36),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'الصفحة ${widget.salat.page}',
                          style: GoogleFonts.amiri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: settings.isDarkMode ? Colors.white70 : const Color(0xFF0A5C36),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Juz and Bab info
                  if (widget.salat.bab.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        '${widget.salat.bab} • الجزء ${widget.salat.juz}',
                        style: GoogleFonts.amiri(
                          fontSize: 14,
                          color: settings.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Ad space
                  Container(
                    height: 60,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: settings.isDarkMode 
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: settings.isDarkMode 
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'AD SPACE',
                      style: GoogleFonts.amiri(
                        color: settings.isDarkMode ? Colors.grey[500] : Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}