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
  final String? searchQuery;

  const HighlightedText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.font,
    required this.isDarkMode,
    this.textAlign = TextAlign.center,
    this.lineHeight = 1.6,
    this.searchQuery,
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
    
    // Comprehensive patterns for Muhammad highlighting
    List<String> muhammadPatterns = [
      'محمد',
      'مُحَمَّد',
      'مُحَمَّدٍ',
      'مُحَمَّدًا',
      'مُحَمَّدَ',
      'محمداً',
      'محمدٍ',
      'محمدًا',
      'مُحَمَّدٌ',
      'مُحَمَّدُ',
      'مُحَمَّدِ',
      'ﷺ',
      'صلعم',
      'صلى الله عليه وسلم',
      'صلى الله عليه وآله وسلم',
      'عليه الصلاة والسلام',
      'عليه أفضل الصلاة والسلام',
      'سيدنا محمد',
      'نبينا محمد',
      'رسول الله محمد',
      'النبي محمد',
      'الرسول محمد',
      'حبيب الله محمد',
      'خير الخلق محمد',
      'خاتم الأنبياء محمد',
    ];
    
    String remainingText = text;
    TextStyle baseStyle = _getBaseStyle();
    
    // Create a list of all patterns to highlight
    List<String> allPatterns = [...muhammadPatterns];
    
    // Add search query if provided
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      allPatterns.add(searchQuery!);
    }
    
    while (remainingText.isNotEmpty) {
      int earliestMatch = -1;
      String earliestPattern = '';
      
      // Find the earliest occurrence of any pattern
      for (String pattern in allPatterns) {
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
      
      // Determine highlight color
      Color highlightColor;
      Color? backgroundColor;
      
      if (muhammadPatterns.contains(earliestPattern)) {
        highlightColor = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.2);
      } else if (searchQuery != null && earliestPattern == searchQuery) {
        highlightColor = Colors.orange;
        backgroundColor = Colors.orange.withOpacity(0.3);
      } else {
        highlightColor = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.2);
      }
      
      spans.add(TextSpan(
        text: earliestPattern,
        style: baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: highlightColor,
          backgroundColor: backgroundColor,
          fontSize: baseStyle.fontSize! * 1.02,
        ),
      ));
      
      remainingText = remainingText.substring(earliestMatch + earliestPattern.length);
    }
    
    return spans;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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