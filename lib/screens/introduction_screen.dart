import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IntroductionScreen extends ConsumerWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المقدمة',
          style: GoogleFonts.amiri(fontSize: 24),
        ),
        backgroundColor: const Color(0xFF0A5C36),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Decorative header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0A5C36).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0A5C36).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  _buildBlessingSymbol(),
                  const SizedBox(height: 16),
                  Text(
                    'تنبيه الأنام',
                    style: GoogleFonts.amiri(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A5C36),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'في الصلاة على سيدنا محمد عليه أفضل الصلاة والسلام',
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Introduction content
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'فضل الصلاة على النبي ﷺ',
                    'قال الله تعالى: "إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ ۚ يَا أَيُّهَا الَّذِينَ آمَنُوا صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا" (الأحزاب: 56)',
                  ),
                  _buildDivider(),
                  _buildSection(
                    'عن تنبيه الأنام',
                    'هذا الكتاب المبارك جمع فيه المؤلف مجموعة من الصلوات على سيدنا محمد ﷺ، مستمدة من كتب الصلاة المشهورة مثل دلائل الخيرات وغيره. وهو مقسم إلى جزأين رئيسيين وخاتمة.',
                  ),
                  _buildDivider(),
                  _buildSection(
                    'كيفية القراءة',
                    '• اختر الجزء الذي ترغب في قراءته\n• اختر الباب المناسب\n• اقرأ الصلاة بتدبر وخشوع\n• يمكنك إضافة الصلاة إلى المفضلة\n• شارك الصلاة مع الأحبة',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A5C36),
                    const Color(0xFF1E7A4C),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItemWithText('جزءان', 'الأول والثاني'),
                  _buildStatItemWithIcon(Icons.book, 'أبواب متعددة'),
                  _buildStatItemWithIcon(Icons.star, 'مفضلة شخصية'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlessingSymbol() {
    return Text(
      'ﷺ',
      style: GoogleFonts.amiri(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.red,
        shadows: const [
          Shadow(
            blurRadius: 4,
            color: Colors.black26,
            offset: Offset(1, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHighlightedTitle(title),
        const SizedBox(height: 12),
        _buildHighlightedText(content),
      ],
    );
  }

  Widget _buildHighlightedTitle(String text) {
    // Split text to highlight "محمد" or "ﷺ"
    List<TextSpan> spans = [];
    String searchWord = 'محمد';
    
    if (text.contains(searchWord)) {
      List<String> parts = text.split(searchWord);
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(
            text: parts[i],
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0A5C36),
            ),
          ));
        }
        if (i < parts.length - 1 || text.endsWith(searchWord)) {
          spans.add(TextSpan(
            text: searchWord,
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ));
        }
      }
    } else {
      spans.add(TextSpan(
        text: text,
        style: GoogleFonts.amiri(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0A5C36),
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildHighlightedText(String text) {
    // Split text to highlight "محمد" or "ﷺ"
    List<TextSpan> spans = [];
    String searchWord = 'محمد';
    String symbol = 'ﷺ';
    
    // First check for محمد
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
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ));
              }
              if (j < symbolParts.length - 1 || parts[i].endsWith(symbol)) {
                spans.add(TextSpan(
                  text: symbol,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    height: 1.6,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ));
              }
            }
          } else {
            spans.add(TextSpan(
              text: parts[i],
              style: GoogleFonts.amiri(
                fontSize: 18,
                height: 1.6,
                color: Colors.black87,
              ),
            ));
          }
        }
        if (i < parts.length - 1 || text.endsWith(searchWord)) {
          spans.add(TextSpan(
            text: searchWord,
            style: GoogleFonts.amiri(
              fontSize: 18,
              height: 1.6,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ));
        }
      }
    } 
    // Check for ﷺ only
    else if (text.contains(symbol)) {
      List<String> parts = text.split(symbol);
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(
            text: parts[i],
            style: GoogleFonts.amiri(
              fontSize: 18,
              height: 1.6,
              color: Colors.black87,
            ),
          ));
        }
        if (i < parts.length - 1 || text.endsWith(symbol)) {
          spans.add(TextSpan(
            text: symbol,
            style: GoogleFonts.amiri(
              fontSize: 18,
              height: 1.6,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ));
        }
      }
    } else {
      spans.add(TextSpan(
        text: text,
        style: GoogleFonts.amiri(
          fontSize: 18,
          height: 1.6,
          color: Colors.black87,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFF0A5C36).withOpacity(0.2),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF0A5C36),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFF0A5C36).withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemWithText(String mainText, String subText) {
    return Column(
      children: [
        Text(
          mainText,
          style: GoogleFonts.amiri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subText,
          style: GoogleFonts.amiri(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItemWithIcon(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          text,
          style: GoogleFonts.amiri(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}