import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tanbihulanam/providers/data_provider.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/models/salat_model.dart';
import 'package:tanbihulanam/widgets/highlighted_text.dart';
import 'package:tanbihulanam/services/bookmark_service.dart';

class ConclusionScreen extends ConsumerStatefulWidget {
  const ConclusionScreen({super.key});

  @override
  ConsumerState<ConclusionScreen> createState() => _ConclusionScreenState();
}

class _ConclusionScreenState extends ConsumerState<ConclusionScreen> {
  Map<int, bool> _bookmarkedStatus = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadBookmarks(List<SalatModel> items) async {
    for (var item in items) {
      final isBookmarked = await BookmarkService.isBookmarked(item.id);
      setState(() {
        _bookmarkedStatus[item.id] = isBookmarked;
      });
    }
  }

  Future<void> _toggleBookmark(int salatId) async {
    final isBookmarked = _bookmarkedStatus[salatId] ?? false;
    
    if (isBookmarked) {
      await BookmarkService.removeBookmark(salatId);
    } else {
      await BookmarkService.addBookmark(salatId);
    }
    
    setState(() {
      _bookmarkedStatus[salatId] = !isBookmarked;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!isBookmarked ? 'تمت الإضافة إلى المفضلة' : 'تمت الإزالة من المفضلة'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final endOfSalawatAsync = ref.watch(endOfSalawatProvider);
    final endOfDuaAsync = ref.watch(endOfDuaProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          settings.language == AppLanguage.arabic 
              ? 'الحلقة الختامية' 
              : 'Conclusion',
          style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A5C36),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header for End of Salawat
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A5C36), Color(0xFF1E7A4C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                  const SizedBox(height: 8),
                  Text(
                    settings.language == AppLanguage.arabic 
                        ? 'ختام الصلوات'
                        : 'End of Salawat',
                    style: GoogleFonts.amiri(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // End of Salawat Content
            endOfSalawatAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: GoogleFonts.amiri(),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          settings.language == AppLanguage.arabic 
                              ? 'لا توجد بيانات'
                              : 'No data available',
                          style: GoogleFonts.amiri(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadBookmarks(items);
                });
                
                return Column(
                  children: items.map((item) {
                    final isBookmarked = _bookmarkedStatus[item.id] ?? false;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: settings.isDarkMode 
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Bookmark header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (item.bab.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A5C36).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.bab,
                                      style: GoogleFonts.amiri(
                                        fontSize: 14,
                                        color: const Color(0xFF0A5C36),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(),
                                IconButton(
                                  icon: Icon(
                                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    color: isBookmarked ? Colors.amber : Colors.grey,
                                    size: 28,
                                  ),
                                  onPressed: () => _toggleBookmark(item.id),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                          
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                HighlightedText(
                                  text: item.arabic,
                                  fontSize: settings.fontSize,
                                  font: settings.selectedFont,
                                  isDarkMode: settings.isDarkMode,
                                  textAlign: TextAlign.center,
                                ),
                                
                                const Divider(height: 24),
                                
                                // Page number
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.menu_book,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'صفحة ${item.page}',
                                      style: GoogleFonts.amiri(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Dua Section Header - Separate Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E4C3A), Color(0xFF2A6B4F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.language == AppLanguage.arabic 
                              ? 'الأدعية'
                              : 'Duas',
                          style: GoogleFonts.amiri(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          settings.language == AppLanguage.arabic 
                              ? 'دعاء ختامي مبارك'
                              : 'Blessed Closing Duas',
                          style: GoogleFonts.amiri(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Dua Content
            endOfDuaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: GoogleFonts.amiri(),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.mosque, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          settings.language == AppLanguage.arabic 
                              ? 'لا توجد أدعية متاحة'
                              : 'No duas available',
                          style: GoogleFonts.amiri(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          settings.language == AppLanguage.arabic 
                              ? 'سيتم إضافة الأدعية قريباً'
                              : 'Duas will be added soon',
                          style: GoogleFonts.amiri(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadBookmarks(items);
                });
                
                return Column(
                  children: items.map((item) {
                    final isBookmarked = _bookmarkedStatus[item.id] ?? false;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFE8F5E9),
                            const Color(0xFFC8E6C9),
                            const Color(0xFFA5D6A7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFF0A5C36).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Dua header
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0A5C36), Color(0xFF1E7A4C)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    settings.language == AppLanguage.arabic ? 'دعاء' : 'Dua',
                                    style: GoogleFonts.amiri(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () => _toggleBookmark(item.id),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                          
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                if (item.bab.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A5C36).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: const Color(0xFF0A5C36).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      item.bab,
                                      style: GoogleFonts.amiri(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0A5C36),
                                      ),
                                    ),
                                  ),
                                
                                // Decorative elements for dua
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (i) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0A5C36).withOpacity(0.2 + (i * 0.1)),
                                        shape: BoxShape.circle,
                                      ),
                                    )),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                HighlightedText(
                                  text: item.arabic,
                                  fontSize: settings.fontSize,
                                  font: settings.selectedFont,
                                  isDarkMode: false, // Always light background for dua
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Decorative footer
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0A5C36).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.menu_book,
                                            size: 14,
                                            color: Color(0xFF0A5C36),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'صفحة ${item.page}',
                                            style: GoogleFonts.amiri(
                                              fontSize: 12,
                                              color: const Color(0xFF0A5C36),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0A5C36),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'دعاء',
                                        style: GoogleFonts.amiri(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}