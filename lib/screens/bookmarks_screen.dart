import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tanbihulanam/providers/data_provider.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/services/bookmark_service.dart';
import 'package:tanbihulanam/screens/juz_screen.dart';
import 'package:tanbihulanam/models/salat_model.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  Set<String> _pageBookmarks = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await BookmarkService.getPageBookmarks();
    if (mounted) {
      setState(() {
        _pageBookmarks = bookmarks;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(String pageKey) async {
    await BookmarkService.removePageBookmark(pageKey);
    _loadBookmarks();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تمت إزالة الصفحة من المفضلة'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _getLocalizedText(String ar, String en) {
    final settings = ref.watch(settingsProvider);
    return settings.language == AppLanguage.arabic ? ar : en;
  }

  // Parse page key to get juz and page info
  Map<String, String> _parsePageKey(String pageKey) {
    final parts = pageKey.split('_');
    return {
      'juz': parts.length > 0 ? parts[0] : '1',
      'bab': parts.length > 1 ? parts[1] : '',
      'page': parts.length > 2 ? parts[2] : '0',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getLocalizedText('المفضلة', 'Bookmarks'),
          style: GoogleFonts.amiri(fontSize: 24),
        ),
        backgroundColor: const Color(0xFF0A5C36),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookmarks,
          ),
          if (_pageBookmarks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      _getLocalizedText('تأكيد', 'Confirm'),
                      style: GoogleFonts.amiri(),
                    ),
                    content: Text(
                      _getLocalizedText('هل تريد حذف جميع الصفحات المفضلة؟', 'Delete all bookmarked pages?'),
                      style: GoogleFonts.amiri(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          _getLocalizedText('إلغاء', 'Cancel'),
                          style: GoogleFonts.amiri(),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          _getLocalizedText('حذف', 'Delete'),
                          style: GoogleFonts.amiri(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await BookmarkService.clearAllBookmarks();
                  _loadBookmarks();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pageBookmarks.isEmpty
              ? _buildEmptyState()
              : _buildBookmarksList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedText('لا توجد صفحات في المفضلة', 'No bookmarked pages'),
            style: GoogleFonts.amiri(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getLocalizedText(
              'اضغط على علامة 🔖 في أي صفحة للإضافة هنا',
              'Tap the 🔖 icon on any page to add it here',
            ),
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList() {
    return Consumer(
      builder: (context, ref, child) {
        final salawatAsync = ref.watch(salawatProvider);
        
        return salawatAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('خطأ: $err')),
          data: (allSalawat) {
            final bookmarkedPagesList = _pageBookmarks.toList()..sort();
            
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bookmarkedPagesList.length,
              itemBuilder: (context, index) {
                final pageKey = bookmarkedPagesList[index];
                final parsed = _parsePageKey(pageKey);
                final juz = int.tryParse(parsed['juz'] ?? '1') ?? 1;
                final pageNum = int.tryParse(parsed['page'] ?? '0') ?? 0;
                final bab = parsed['bab'] ?? '';
                
                // Find a sample salawat from this page for preview
                final pageSalawat = allSalawat
                    .where((s) => s.juz == juz && (bab.isEmpty || s.bab == bab))
                    .toList();
                
                final sampleSalat = pageSalawat.isNotEmpty ? pageSalawat.first : null;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JuzScreen(
                            juzNumber: juz,
                            initialPage: pageNum,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A5C36),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.bookmark,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_getLocalizedText('الجزء', 'Part')} $juz',
                                  style: GoogleFonts.amiri(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0A5C36),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bab.isNotEmpty && bab != 'all' 
                                      ? bab
                                      : _getLocalizedText('جميع الأبواب', 'All chapters'),
                                  style: GoogleFonts.amiri(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (sampleSalat != null)
                                  Text(
                                    '${_getLocalizedText('صفحة', 'Page')} ${sampleSalat.page} - ${sampleSalat.page + 5}',
                                    style: GoogleFonts.amiri(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _removeBookmark(pageKey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}