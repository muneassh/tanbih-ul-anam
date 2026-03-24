import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tanbihulanam/providers/data_provider.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/services/bookmark_service.dart';
import 'package:tanbihulanam/screens/juz_screen.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  Set<String> _pageBookmarks = {};
  Map<String, Map<String, dynamic>> _pageDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await BookmarkService.getPageBookmarks();
    final details = <String, Map<String, dynamic>>{};
    
    for (var key in bookmarks) {
      final detail = await BookmarkService.getPageDetails(key);
      if (detail.isNotEmpty) {
        details[key] = detail;
      }
    }
    
    if (mounted) {
      setState(() {
        _pageBookmarks = bookmarks;
        _pageDetails = details;
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
                  await BookmarkService.clearAllPageBookmarks();
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
    final bookmarkedPagesList = _pageBookmarks.toList()..sort();
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookmarkedPagesList.length,
      itemBuilder: (context, index) {
        final pageKey = bookmarkedPagesList[index];
        final details = _pageDetails[pageKey] ?? {};
        
        final juz = details['juzNumber'] ?? 1;
        final pageNumber = details['pageNumber'] ?? 1;
        final babName = details['babName'] ?? '';
        
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
                    initialPage: pageNumber,
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
                    child: Center(
                      child: Text(
                        '$pageNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                        if (babName.isNotEmpty)
                          Text(
                            babName,
                            style: GoogleFonts.amiri(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getLocalizedText('صفحة', 'Page')} $pageNumber',
                          style: GoogleFonts.amiri(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A5C36).withOpacity(0.7),
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
  }
}