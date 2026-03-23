import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tanbihulanam/models/salat_model.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/services/bookmark_service.dart';
import 'package:tanbihulanam/widgets/highlighted_text.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  final SalatModel salat;
  final bool isInJuzView;
  final bool hideAppBar;
  final double? fontSize;
  final AppFont? font;
  final bool? isDarkMode;

  const ReadingScreen({
    super.key, 
    required this.salat,
    this.isInJuzView = false,
    this.hideAppBar = false,
    this.fontSize,
    this.font,
    this.isDarkMode,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    
    // Use provided values or fallback to settings
    final double fontSize = widget.fontSize ?? settings.fontSize;
    final AppFont font = widget.font ?? settings.selectedFont;
    final bool isDarkMode = widget.isDarkMode ?? settings.isDarkMode;
    
    // Standalone view with full app bar - BOOKMARK FIXED
    if (!widget.isInJuzView && !widget.hideAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'صفحة ${widget.salat.page}',
            style: GoogleFonts.amiri(),
          ),
          backgroundColor: const Color(0xFF0A5C36),
          foregroundColor: Colors.white,
          actions: [
            // Bookmark button - FIXED: Always visible
            IconButton(
  icon: Icon(
    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
    color: Colors.white,
    size: 24,
  ),
  onPressed: () async {
    if (!_isLoading) {
      await _toggleBookmark();
      // Force rebuild to show updated state
      setState(() {});
    }
  },
  tooltip: _isBookmarked ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
),
            
            // Share button
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white, size: 22),
              onPressed: _shareText,
              tooltip: 'مشاركة',
            ),
            
            // Font size controls
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                    onPressed: () {
                      if (settings.fontSize > 16) {
                        ref.read(settingsProvider.notifier).setFontSize(settings.fontSize - 1);
                      }
                    },
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      maxWidth: 32,
                      minHeight: 32,
                      maxHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  Text(
                    '${settings.fontSize.round()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    onPressed: () {
                      if (settings.fontSize < 28) {
                        ref.read(settingsProvider.notifier).setFontSize(settings.fontSize + 1);
                      }
                    },
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      maxWidth: 32,
                      minHeight: 32,
                      maxHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Container(
          color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5E8C7),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? const Color(0xFF1E1E1E)
                              : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: HighlightedText(
                          text: widget.salat.arabic,
                          fontSize: fontSize,
                          font: font,
                          isDarkMode: isDarkMode,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  
                  // Page number
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A5C36).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 14,
                          color: const Color(0xFF0A5C36),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'صفحة ${widget.salat.page}',
                          style: GoogleFonts.amiri(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A5C36),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Embedded view for Juz screen (no app bar)
    return HighlightedText(
      text: widget.salat.arabic,
      fontSize: fontSize,
      font: font,
      isDarkMode: isDarkMode,
      textAlign: TextAlign.center,
    );
  }
}