import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tanbihulanam/models/salat_model.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/widgets/highlighted_text.dart';

class ReadingContent extends ConsumerWidget {
  final SalatModel salat;
  final bool isInJuzView;
  final bool hideAppBar;

  const ReadingContent({
    super.key,
    required this.salat,
    this.isInJuzView = false,
    this.hideAppBar = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Page number indicator (if not in juz view)
        if (!isInJuzView && !hideAppBar)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Text(
              'صفحة ${salat.page}',
              style: TextStyle(
                fontSize: 14,
                color: settings.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        
        // Main content with highlighting
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: settings.isDarkMode 
                ? const Color(0xFF1E1E1E).withOpacity(0.7)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: HighlightedText(
            text: salat.arabic,
            fontSize: settings.fontSize,
            font: settings.selectedFont,
            isDarkMode: settings.isDarkMode,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Bab name (if available)
        if (salat.bab.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Text(
              salat.bab,
              style: TextStyle(
                fontSize: 12,
                color: settings.isDarkMode ? Colors.grey[500] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}