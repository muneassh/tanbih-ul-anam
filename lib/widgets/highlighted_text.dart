import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';

class HighlightedText extends ConsumerWidget {
  final String text;
  final double fontSize;
  final AppFont font;
  final bool isDarkMode;
  final TextAlign textAlign;
  final double lineHeight;

  const HighlightedText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.font,
    required this.isDarkMode,
    this.textAlign = TextAlign.center,
    this.lineHeight = 1.6,
  });

  TextStyle _getBaseStyle() {
    switch (font) {
      case AppFont.amiri:
        return GoogleFonts.amiri(
          fontSize: fontSize,
          height: lineHeight,
          color: isDarkMode ? Colors.white70 : const Color(0xFF2C1810),
        );
      case AppFont.noto:
        return GoogleFonts.notoNaskhArabic(
          fontSize: fontSize,
          height: lineHeight,
          color: isDarkMode ? Colors.white70 : const Color(0xFF2C1810),
        );
      case AppFont.cairo:
        return GoogleFonts.cairo(
          fontSize: fontSize,
          height: lineHeight,
          color: isDarkMode ? Colors.white70 : const Color(0xFF2C1810),
        );
      case AppFont.tajawal:
        return GoogleFonts.tajawal(
          fontSize: fontSize,
          height: lineHeight,
          color: isDarkMode ? Colors.white70 : const Color(0xFF2C1810),
        );
      default:
        return GoogleFonts.amiri(
          fontSize: fontSize,
          height: lineHeight,
          color: isDarkMode ? Colors.white70 : const Color(0xFF2C1810),
        );
    }
  }

  List<TextSpan> _buildSpans() {
    List<TextSpan> spans = [];
    
    // Comprehensive patterns to catch ALL forms of Muhammad
    List<String> patterns = [
      // Basic forms with all diacritics
      'محمد',
      'مُحَمَّد',
      'مُحَمَّدٍ',
      'مُحَمَّدًا',
      'مُحَمَّدَ',
      'مُحَمَّدٌ',
      'مُحَمَّدُ',
      'مُحَمَّدِ',
      'محمداً',
      'محمدٍ',
      'محمدًا',
      'محمدٌ',
      'محمدُ',
      'محمدِ',
      
      // With different diacritic combinations
      'مُحَمَّدْ',
      'مُحَمَّدّ',
      'مُحَمَّد',
      'مُحَمَّدٍ',
      'مُحَمَّدًا',
      'مُحَمَّدَ',
      'مُحَمَّدٌ',
      'مُحَمَّدُ',
      'مُحَمَّدِ',
      
      // With honorific symbols
      'ﷺ',
      'محمدﷺ',
      'مُحَمَّدﷺ',
      'مُحَمَّدﷺ',
      
      // Combined with titles
      'النبي محمد',
      'النبي مُحَمَّد',
      'الرسول محمد',
      'الرسول مُحَمَّد',
      'سيدنا محمد',
      'سيدنا مُحَمَّد',
      'نبينا محمد',
      'نبينا مُحَمَّد',
      'رسول الله محمد',
      'رسول الله مُحَمَّد',
      
      // With صلی الله علیه وسلم variations
      'صلعم',
      'صلى الله عليه وسلم',
      'صلى الله عليه وآله وسلم',
      'عليه الصلاة والسلام',
      'عليه أفضل الصلاة والسلام',
    ];
    
    String remainingText = text;
    TextStyle baseStyle = _getBaseStyle();
    
    while (remainingText.isNotEmpty) {
      int earliestMatch = -1;
      String earliestPattern = '';
      
      // Find the earliest occurrence of any pattern
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
      
      // Add text before the match
      if (earliestMatch > 0) {
        spans.add(TextSpan(
          text: remainingText.substring(0, earliestMatch),
          style: baseStyle,
        ));
      }
      
      // Add the highlighted pattern
      spans.add(TextSpan(
        text: earliestPattern,
        style: baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.red,
          fontSize: baseStyle.fontSize! * 1.05,
        ),
      ));
      
      // Update remaining text
      remainingText = remainingText.substring(earliestMatch + earliestPattern.length);
    }
    
    return spans;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If text is empty, return empty widget
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return SelectableText.rich(
      TextSpan(children: _buildSpans()),
      textDirection: TextDirection.rtl,
      textAlign: textAlign,
    );
  }
}