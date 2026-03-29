import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tanbihulanam/providers/data_provider.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/screens/reading_screen.dart';
import 'package:tanbihulanam/models/salat_model.dart';
import 'package:tanbihulanam/widgets/ad_widget.dart';
import 'package:tanbihulanam/services/bookmark_service.dart';
import 'package:tanbihulanam/widgets/highlighted_text.dart';

class JuzScreen extends ConsumerStatefulWidget {
  final int juzNumber;
  final int? initialSalatId;
  final int? initialPage;

  const JuzScreen({
    super.key, 
    required this.juzNumber, 
    this.initialSalatId,
    this.initialPage,
  });

  @override
  ConsumerState<JuzScreen> createState() => _JuzScreenState();
}

class _JuzScreenState extends ConsumerState<JuzScreen> {
  String? _selectedBab;
  List<SalatModel> _currentSalawat = [];
  List<List<SalatModel>> _paginatedSalawat = [];
  int _currentPageIndex = 0;
  late PageController _pageController;
  bool _isFullScreen = false;
  bool _isInitialized = false;
  
  Set<String> _pageBookmarks = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadPageBookmarks();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPageBookmarks() async {
    final bookmarks = await BookmarkService.getPageBookmarks();
    if (mounted) {
      setState(() {
        _pageBookmarks = bookmarks;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadInitialData();
      _isInitialized = true;
    }
  }

  Future<void> _loadInitialData() async {
    final allSalawat = await ref.read(salawatProvider.future);
    final juzItems = allSalawat.where((s) => s.juz == widget.juzNumber).toList();
    
    if (juzItems.isNotEmpty && mounted) {
      setState(() {
        _currentSalawat = juzItems;
      });
      
      if (widget.initialPage != null) {
        final pageNumber = widget.initialPage!;
        SalatModel? targetSalat;
        String? targetBab;
        
        for (var salat in juzItems) {
          if (salat.page == pageNumber) {
            targetSalat = salat;
            targetBab = salat.bab;
            break;
          }
        }
        
        if (targetSalat != null && targetBab != null && mounted) {
          final Map<String, List<SalatModel>> grouped = {};
          for (var item in juzItems) {
            final key = item.bab.isNotEmpty ? item.bab : _getLocalizedText('غير مصنف', 'Uncategorized');
            grouped.putIfAbsent(key, () => []).add(item);
          }
          
          if (grouped.containsKey(targetBab)) {
            setState(() {
              _selectedBab = targetBab;
              _currentSalawat = grouped[targetBab]!;
            });
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _recalculatePagination();
              
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted && _pageController.hasClients) {
                  for (int i = 0; i < _paginatedSalawat.length; i++) {
                    final pageSalawat = _paginatedSalawat[i];
                    if (pageSalawat.any((s) => s.page == pageNumber)) {
                      _currentPageIndex = i;
                      _pageController.jumpToPage(i);
                      break;
                    }
                  }
                }
              });
            });
          }
        }
      }
      else if (widget.initialSalatId != null) {
        final Map<String, List<SalatModel>> grouped = {};
        for (var item in juzItems) {
          final key = item.bab.isNotEmpty ? item.bab : _getLocalizedText('غير مصنف', 'Uncategorized');
          grouped.putIfAbsent(key, () => []).add(item);
        }
        
        String? targetBab;
        int targetIndex = -1;
        
        for (var entry in grouped.entries) {
          final index = entry.value.indexWhere((s) => s.id == widget.initialSalatId);
          if (index != -1) {
            targetBab = entry.key;
            targetIndex = index;
            break;
          }
        }
        
        if (targetBab != null && targetIndex != -1 && mounted) {
          setState(() {
            _selectedBab = targetBab;
            _currentSalawat = grouped[targetBab]!;
          });
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _recalculatePagination();
            
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted && _pageController.hasClients) {
                for (int i = 0; i < _paginatedSalawat.length; i++) {
                  if (_paginatedSalawat[i].any((s) => s.id == widget.initialSalatId)) {
                    _currentPageIndex = i;
                    _pageController.jumpToPage(i);
                    break;
                  }
                }
              }
            });
          });
        }
      }
    }
  }

  String _getLocalizedText(String ar, String en) {
    final settings = ref.watch(settingsProvider);
    return settings.language == AppLanguage.arabic ? ar : en;
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalculatePagination();
    });
  }

  String _getPageKey(int pageIndex) {
    return '${widget.juzNumber}_${_selectedBab ?? 'all'}_$pageIndex';
  }

  Future<void> _togglePageBookmark(int pageIndex) async {
    final pageKey = _getPageKey(pageIndex);
    final isBookmarked = _pageBookmarks.contains(pageKey);
    
    final pageSalawat = _paginatedSalawat[pageIndex];
    final firstSalat = pageSalawat.isNotEmpty ? pageSalawat.first : null;
    final pageNumber = firstSalat?.page ?? 1;
    
    try {
      if (isBookmarked) {
        await BookmarkService.removePageBookmark(pageKey);
        setState(() {
          _pageBookmarks.remove(pageKey);
        });
      } else {
        await BookmarkService.addPageBookmark(
          pageKey,
          pageNumber: pageNumber,
          babName: _selectedBab,
          juzNumber: widget.juzNumber,
        );
        setState(() {
          _pageBookmarks.add(pageKey);
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!isBookmarked 
                ? '✓ تمت إضافة الصفحة ${pageNumber} إلى المفضلة' 
                : '✓ تمت إزالة الصفحة ${pageNumber} من المفضلة'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: !isBookmarked ? Colors.green : Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      print('Error toggling page bookmark: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _recalculatePagination() {
    if (_currentSalawat.isEmpty) return;
    
    final settings = ref.read(settingsProvider);
    final screenSize = MediaQuery.of(context).size;
    
    double lineHeight = settings.fontSize * 1.6;
    double availableHeight = screenSize.height * (_isFullScreen ? 0.8 : 0.65);
    double availableWidth = screenSize.width - 32;
    
    List<List<SalatModel>> pages = [];
    List<SalatModel> currentPage = [];
    double currentPageHeight = 0;
    double headerHeight = 40;
    
    for (var salat in _currentSalawat) {
      int avgCharsPerWord = 5;
      int wordsPerLine = (availableWidth / (settings.fontSize * 0.7)).floor();
      int charsPerLine = wordsPerLine * avgCharsPerWord;
      
      int estimatedLines = (salat.arabic.length / charsPerLine).ceil();
      estimatedLines = estimatedLines.clamp(2, 20);
      
      double salatHeight = estimatedLines * lineHeight + 5;
      
      double totalHeight = currentPage.isEmpty 
          ? currentPageHeight + salatHeight + headerHeight
          : currentPageHeight + salatHeight;
      
      if (totalHeight > availableHeight && currentPage.isNotEmpty) {
        pages.add(currentPage);
        currentPage = [salat];
        currentPageHeight = salatHeight;
      } else {
        currentPage.add(salat);
        currentPageHeight = currentPage.isEmpty 
            ? salatHeight + headerHeight
            : currentPageHeight + salatHeight;
      }
    }
    
    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }
    
    setState(() {
      _paginatedSalawat = pages;
    });
  }

  int _getBabNumber(String babName) {
    final arabicNumbers = {
      '١': 1, '٢': 2, '٣': 3, '٤': 4, '٥': 5,
      '٦': 6, '٧': 7, '٨': 8, '٩': 9, '١٠': 10,
      '١١': 11, '١٢': 12, '١٣': 13, '١٤': 14, '١٥': 15,
      '١٦': 16, '١٧': 17, '١٨': 18, '١٩': 19, '٢٠': 20
    };
    
    final pattern = RegExp(r'باب\s*\(([^)]+)\)');
    final match = pattern.firstMatch(babName);
    
    if (match != null) {
      String numberStr = match.group(1)!;
      if (arabicNumbers.containsKey(numberStr)) {
        return arabicNumbers[numberStr]!;
      }
      int? num = int.tryParse(numberStr);
      if (num != null) return num;
    }
    
    for (var entry in arabicNumbers.entries) {
      if (babName.contains('(${entry.key})')) {
        return entry.value;
      }
    }
    
    if (babName.contains('في فضل الصلاة')) return 1;
    if (babName.contains('في وصف خلقه')) return 2;
    if (babName.contains('في معرفة آياته')) return 3;
    if (babName.contains('في ذكر بعض أسمائه')) return 4;
    if (babName.contains('في ذكر فضله على الأنبياء')) return 5;
    if (babName.contains('في ذكر حقه على أمته')) return 6;
    if (babName.contains('في ذكر بعض مناقب آله')) return 7;
    if (babName.contains('في الاستغفار والدعاء')) return 8;
    
    return 999;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      backgroundColor: settings.isDarkMode 
          ? const Color(0xFF121212) 
          : const Color(0xFFF5E8C7),
      body: Consumer(
        builder: (context, ref, child) {
          final salawatAsync = ref.watch(salawatByJuzProvider(widget.juzNumber));
          
          return salawatAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(_getLocalizedText('خطأ: $err', 'Error: $err')),
            ),
            data: (juzItems) {
              if (juzItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _getLocalizedText('لا توجد بيانات', 'No data'),
                        style: GoogleFonts.amiri(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }

              if (_selectedBab == null && widget.initialSalatId == null && widget.initialPage == null) {
                final Map<String, List<SalatModel>> grouped = {};
                for (var item in juzItems) {
                  final key = item.bab.isNotEmpty ? item.bab : _getLocalizedText('غير مصنف', 'Uncategorized');
                  grouped.putIfAbsent(key, () => []).add(item);
                }

                List<String> sortedKeys = grouped.keys.toList();
                sortedKeys.sort((a, b) {
                  int numA = _getBabNumber(a);
                  int numB = _getBabNumber(b);
                  return numA.compareTo(numB);
                });

                return SafeArea(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A5C36),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getLocalizedText(
                                'الجزء ${widget.juzNumber} - الأبواب',
                                'Part ${widget.juzNumber} - Chapters',
                              ),
                              style: GoogleFonts.amiri(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: sortedKeys.length,
                          itemBuilder: (context, index) {
                            final babName = sortedKeys[index];
                            final items = grouped[babName]!;
                            items.sort((a, b) => a.page.compareTo(b.page));

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedBab = babName;
                                    _currentSalawat = items;
                                    _currentPageIndex = 0;
                                    _paginatedSalawat = [];
                                  });
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _recalculatePagination();
                                    if (_pageController.hasClients) {
                                      _pageController.jumpToPage(0);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
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
                                            '${items.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              babName,
                                              style: GoogleFonts.amiri(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0A5C36),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _getLocalizedText(
                                                '${items.length} صلوات',
                                                '${items.length} Prayers',
                                              ),
                                              style: GoogleFonts.amiri(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Color(0xFF0A5C36),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (_paginatedSalawat.isEmpty && _currentSalawat.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _recalculatePagination();
                });
                return const Center(child: CircularProgressIndicator());
              }

              if (_paginatedSalawat.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A5C36),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.list, color: Colors.white, size: 22),
                            onPressed: () {
                              setState(() {
                                _selectedBab = null;
                                _paginatedSalawat = [];
                              });
                            },
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              maxWidth: 36,
                              minHeight: 36,
                              maxHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          
                          const SizedBox(width: 4),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedBab ?? _getLocalizedText('الجزء ${widget.juzNumber}', 'Part ${widget.juzNumber}'),
                                  style: GoogleFonts.amiri(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${_getLocalizedText('صفحة', 'Page')} ${_currentPageIndex + 1} / ${_paginatedSalawat.length}',
                                  style: GoogleFonts.amiri(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                                  onPressed: () {
                                    if (settings.fontSize > 14) {
                                      ref.read(settingsProvider.notifier).setFontSize(settings.fontSize - 1);
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _recalculatePagination();
                                      });
                                    }
                                  },
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    maxWidth: 32,
                                    minHeight: 32,
                                    maxHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                Text(
                                  '${settings.fontSize.round()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                                  onPressed: () {
                                    if (settings.fontSize < 26) {
                                      ref.read(settingsProvider.notifier).setFontSize(settings.fontSize + 1);
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _recalculatePagination();
                                      });
                                    }
                                  },
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    maxWidth: 32,
                                    minHeight: 32,
                                    maxHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 4),
                          
                          IconButton(
                            icon: Icon(
                              _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _toggleFullScreen,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              maxWidth: 32,
                              minHeight: 32,
                              maxHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                                onPressed: _currentPageIndex > 0 && _pageController.hasClients
                                    ? () {
                                        _pageController.previousPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    : null,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  maxWidth: 32,
                                  minHeight: 32,
                                  maxHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                                onPressed: _currentPageIndex < _paginatedSalawat.length - 1 && _pageController.hasClients
                                    ? () {
                                        _pageController.nextPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    : null,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  maxWidth: 32,
                                  minHeight: 32,
                                  maxHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPageIndex = index;
                          });
                          
                          if (_paginatedSalawat.isNotEmpty && index < _paginatedSalawat.length) {
                            final pageSalawat = _paginatedSalawat[index];
                            if (pageSalawat.isNotEmpty) {
                              final firstSalat = pageSalawat.first;
                              ref.read(settingsProvider.notifier).updateLastRead(
                                widget.juzNumber,
                                firstSalat.page,
                                firstSalat.id,
                                bab: _selectedBab,
                              );
                            }
                          }
                        },
                        itemCount: _paginatedSalawat.length,
                        itemBuilder: (context, pageIndex) {
                          final pageSalawat = _paginatedSalawat[pageIndex];
                          final firstSalat = pageSalawat.first;
                          final isPageBookmarked = _pageBookmarks.contains(_getPageKey(pageIndex));
                          
                          // Calculate the starting global index for this page
                          int startGlobalIndex = 0;
                          for (int i = 0; i < pageIndex; i++) {
                            startGlobalIndex += _paginatedSalawat[i].length;
                          }
                          
                          return Container(
                            color: settings.isDarkMode 
                                ? const Color(0xFF121212) 
                                : const Color(0xFFF5E8C7),
                            padding: EdgeInsets.all(_isFullScreen ? 8 : 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A5C36).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF0A5C36).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          firstSalat.bab.isNotEmpty ? firstSalat.bab : _selectedBab ?? '',
                                          style: GoogleFonts.amiri(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0A5C36),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0A5C36),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'صفحات ${pageSalawat.first.page} - ${pageSalawat.last.page}',
                                          style: GoogleFonts.amiri(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isPageBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                          color: isPageBookmarked ? Colors.amber : Colors.grey,
                                          size: 32,
                                        ),
                                        onPressed: () => _togglePageBookmark(pageIndex),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      Text(
                                        isPageBookmarked 
                                            ? _getLocalizedText('صفحة في المفضلة', 'Page bookmarked')
                                            : _getLocalizedText('أضف الصفحة للمفضلة', 'Bookmark this page'),
                                        style: GoogleFonts.amiri(
                                          fontSize: 13,
                                          fontWeight: isPageBookmarked ? FontWeight.bold : FontWeight.normal,
                                          color: isPageBookmarked ? Colors.amber[700] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: pageSalawat.length,
                                    itemBuilder: (context, salatIndex) {
                                      final salat = pageSalawat[salatIndex];
                                      final globalSalawatNumber = startGlobalIndex + salatIndex + 1;
                                      
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              margin: const EdgeInsets.only(left: 4, top: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0A5C36).withOpacity(0.1),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(0xFF0A5C36).withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$globalSalawatNumber',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xFF0A5C36),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            const SizedBox(width: 8),
                                            
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                child: HighlightedText(
                                                  text: salat.arabic,
                                                  fontSize: settings.fontSize,
                                                  font: settings.selectedFont,
                                                  isDarkMode: settings.isDarkMode,
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.menu_book,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'صفحة ${_currentPageIndex + 1} من ${_paginatedSalawat.length}',
                                        style: GoogleFonts.amiri(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    if (!_isFullScreen)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: AdSpace(height: 50),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}