import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConclusionScreen extends ConsumerWidget {
  const ConclusionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الحلقة الختامية',
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
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0A5C36),
                    const Color(0xFF052B1A),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  _buildBlessingSymbol(),
                  const SizedBox(height: 16),
                  Text(
                    'خير ما نختم به',
                    style: GoogleFonts.amiri(
                      fontSize: 24,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildHighlightedTitle('الصلاة على النبي محمد ﷺ'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Conclusion content
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
                  _buildPrayerCard(
                    'الصلاة المشرفة',
                    'اللهم صل على سيدنا محمد الفاتح لما أغلق، والخاتم لما سبق، ناصر الحق بالحق، والهادي إلى صراطك المستقيم، وعلى آله حق قدره ومقداره العظيم.',
                  ),
                  const SizedBox(height: 20),
                  _buildPrayerCard(
                    'صلاة النور',
                    'اللهم صل على سيدنا محمد نور الأنوار، وسر الأسرار، ومفتاح باب اليسار، سيدنا محمد المختار، وآله الأطهار، أصحاب الأخيار، عدد نعم الله وأفضاله.',
                  ),
                  const SizedBox(height: 20),
                  _buildPrayerCard(
                    'صلاة السلام',
                    'اللهم صل وسلم وبارك على سيدنا محمد وعلى آله كما لا نهاية لكمالك وكما لا غاية لجلالك، عدد ما كان وعدد ما يكون وعدد الحركات والسكون.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Closing dua
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF5E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF0A5C36).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'الدعاء الختامي',
                    style: GoogleFonts.amiri(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A5C36),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHighlightedText(
                    'اللهم تقبل منا هذا العمل، واجعله خالصاً لوجهك الكريم، واغفر لنا ولوالدينا ولجميع المسلمين، برحمتك يا أرحم الراحمين. وصلى الله على سيدنا محمد وعلى آله وصحبه وسلم.',
                  ),
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
        fontSize: 64,
        fontWeight: FontWeight.bold,
        color: Colors.red,
        shadows: const [
          Shadow(
            blurRadius: 8,
            color: Colors.white54,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedTitle(String text) {
    List<TextSpan> spans = [];
    String searchWord = 'محمد';
    String symbol = 'ﷺ';
    
    if (text.contains(searchWord)) {
      List<String> parts = text.split(searchWord);
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(
            text: parts[i],
            style: GoogleFonts.amiri(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ));
        }
        if (i < parts.length - 1 || text.endsWith(searchWord)) {
          spans.add(TextSpan(
            text: searchWord,
            style: GoogleFonts.amiri(
              fontSize: 28,
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
            style: GoogleFonts.amiri(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ));
        }
        if (i < parts.length - 1 || text.endsWith(symbol)) {
          spans.add(TextSpan(
            text: symbol,
            style: GoogleFonts.amiri(
              fontSize: 28,
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
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildHighlightedText(String text) {
    List<TextSpan> spans = [];
    String searchWord = 'محمد';
    String symbol = 'ﷺ';
    
    if (text.contains(searchWord)) {
      List<String> parts = text.split(searchWord);
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isNotEmpty) {
          if (parts[i].contains(symbol)) {
            List<String> symbolParts = parts[i].split(symbol);
            for (int j = 0; j < symbolParts.length; j++) {
              if (symbolParts[j].isNotEmpty) {
                spans.add(TextSpan(
                  text: symbolParts[j],
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    height: 1.8,
                    color: Colors.black87,
                  ),
                ));
              }
              if (j < symbolParts.length - 1 || parts[i].endsWith(symbol)) {
                spans.add(TextSpan(
                  text: symbol,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    height: 1.8,
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
                height: 1.8,
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
              height: 1.8,
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
            style: GoogleFonts.amiri(
              fontSize: 18,
              height: 1.8,
              color: Colors.black87,
            ),
          ));
        }
        if (i < parts.length - 1 || text.endsWith(symbol)) {
          spans.add(TextSpan(
            text: symbol,
            style: GoogleFonts.amiri(
              fontSize: 18,
              height: 1.8,
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
          height: 1.8,
          color: Colors.black87,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPrayerCard(String title, String prayer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0A5C36).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHighlightedTitle(title),
          const SizedBox(height: 12),
          _buildHighlightedText(prayer),
        ],
      ),
    );
  }
}