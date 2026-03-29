import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tanbihulanam/providers/data_provider.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/screens/reading_screen.dart';
import 'package:tanbihulanam/models/salat_model.dart';
import 'package:tanbihulanam/widgets/highlighted_text.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SalatModel> _searchResults = [];
  bool _isSearching = false;
  String _currentQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query, List<SalatModel> allSalawat) {
    setState(() {
      _currentQuery = query;
    });
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = allSalawat.where((salat) {
        return salat.arabic.contains(query) ||
            salat.bab.contains(query) ||
            salat.page.toString().contains(query) ||
            salat.id.toString().contains(query);
      }).toList();
    });
  }

  String _getLocalizedText(String ar, String en) {
    final settings = ref.watch(settingsProvider);
    return settings.language == AppLanguage.arabic ? ar : en;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: GoogleFonts.amiri(
            fontSize: 18,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: _getLocalizedText('ابحث في الصلوات...', 'Search in prayers...'),
            hintStyle: GoogleFonts.amiri(
              color: Colors.white.withOpacity(0.7),
            ),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                        _isSearching = false;
                        _currentQuery = '';
                      });
                    },
                  )
                : null,
          ),
          onChanged: (query) {
            final allSalawat = ref.read(salawatProvider).valueOrNull ?? [];
            _performSearch(query, allSalawat);
          },
        ),
        backgroundColor: const Color(0xFF0A5C36),
        foregroundColor: Colors.white,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final salawatAsync = ref.watch(salawatProvider);
          
          return salawatAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('خطأ: $err')),
            data: (allSalawat) {
              if (!_isSearching) {
                return _buildInitialState();
              }
              
              if (_searchResults.isEmpty) {
                return _buildNoResults();
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final salat = _searchResults[index];
                  
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
                            builder: (context) => ReadingScreen(salat: salat),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
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
                                      '${salat.page}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
                                        '${_getLocalizedText('صفحة', 'Page')} ${salat.page} • ${_getLocalizedText('الجزء', 'Part')} ${salat.juz}',
                                        style: GoogleFonts.amiri(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0A5C36),
                                        ),
                                      ),
                                      if (salat.bab.isNotEmpty)
                                        Text(
                                          salat.bab,
                                          style: GoogleFonts.amiri(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: HighlightedText(
                                text: salat.arabic,
                                fontSize: settings.fontSize - 4,
                                font: settings.selectedFont,
                                isDarkMode: settings.isDarkMode,
                                textAlign: TextAlign.right,
                                searchQuery: _currentQuery, // Pass the search query
                              ),
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
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedText('ابحث في الصلوات', 'Search in prayers'),
            style: GoogleFonts.amiri(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getLocalizedText(
              'يمكنك البحث بكلمة أو رقم الصفحة',
              'You can search by word or page number',
            ),
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedText('لا توجد نتائج', 'No results found'),
            style: GoogleFonts.amiri(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getLocalizedText('جرب كلمات بحث أخرى', 'Try different search words'),
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}