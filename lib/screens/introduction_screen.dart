import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tanbihulanam/providers/data_provider.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/widgets/highlighted_text.dart'; // Use HighlightedText instead

class IntroductionScreen extends ConsumerWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final introductionAsync = ref.watch(introductionProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          settings.language == AppLanguage.arabic ? 'المقدمة' : 'Introduction',
          style: GoogleFonts.amiri(fontSize: 24),
        ),
        backgroundColor: const Color(0xFF0A5C36),
        foregroundColor: Colors.white,
      ),
      body: introductionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
        data: (introductionItems) {
          if (introductionItems.isEmpty) {
            return Center(
              child: Text(
                settings.language == AppLanguage.arabic 
                    ? 'لا توجد بيانات' 
                    : 'No data available',
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Decorative header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A5C36), Color(0xFF1E7A4C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ﷺ',
                        style: GoogleFonts.amiri(
                          fontSize: 48,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        settings.language == AppLanguage.arabic
                            ? 'تنبيه الأنام'
                            : 'Tanbih al-Anam',
                        style: GoogleFonts.amiri(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        settings.language == AppLanguage.arabic
                            ? 'في الصلاة على سيدنا محمد ﷺ'
                            : 'Prayers upon Prophet Muhammad ﷺ',
                        style: GoogleFonts.amiri(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Introduction content
                ...introductionItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: settings.isDarkMode 
                          ? const Color(0xFF1E1E1E).withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF0A5C36).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.bab.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              item.bab,
                              style: GoogleFonts.amiri(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0A5C36),
                              ),
                            ),
                          ),
                        HighlightedText(
                          text: item.arabic,
                          fontSize: settings.fontSize,
                          font: settings.selectedFont,
                          isDarkMode: settings.isDarkMode,
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}