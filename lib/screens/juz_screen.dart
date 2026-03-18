import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tanbihulanam/providers/data_provider.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/screens/reading_screen.dart';
import 'package:tanbihulanam/models/salat_model.dart';
import 'package:tanbihulanam/widgets/ad_widget.dart';

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
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final allSalawat = await ref.read(salawatProvider.future);
    final juzItems = allSalawat.where((s) => s.juz == widget.juzNumber).toList();
    
    if (juzItems.isNotEmpty && mounted) {
      // Group by bab
      final Map<String, List<SalatModel>> grouped = {};
      for (var item in juzItems) {
        final key = item.bab.isNotEmpty ? item.bab : 'غير مصنف';
        grouped.putIfAbsent(key, () => []).add(item);
      }
      
      setState(() {
        _currentSalawat = juzItems;
      });
      
      // If initialSalatId is provided, find its index and bab
      if (widget.initialSalatId != null) {
        final index = _currentSalawat.indexWhere((s) => s.id == widget.initialSalatId);
        if (index != -1 && mounted) {
          // Find which bab this salat belongs to
          for (var entry in grouped.entries) {
            if (entry.value.any((s) => s.id == widget.initialSalatId)) {
              setState(() {
                _selectedBab = entry.key;
                _currentSalawat = entry.value;
                _currentIndex = entry.value.indexWhere((s) => s.id == widget.initialSalatId);
              });
              _pageController.jumpToPage(_currentIndex);
              break;
            }
          }
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
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: _isFullScreen 
          ? null // No app bar in full screen
          : AppBar(
              title: _selectedBab == null
                  ? Text(
                      _getLocalizedText('الجزء ${widget.juzNumber}', 'Part ${widget.juzNumber}'),
                      style: GoogleFonts.amiri(fontSize: 22),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLocalizedText('الجزء ${widget.juzNumber}', 'Part ${widget.juzNumber}'),
                          style: GoogleFonts.amiri(fontSize: 14),
                        ),
                        Text(
                          _selectedBab!,
                          style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
              backgroundColor: const Color(0xFF0A5C36),
              foregroundColor: Colors.white,
              actions: [
                if (_selectedBab != null)
                  IconButton(
                    icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
                    onPressed: _toggleFullScreen,
                  ),
                if (_selectedBab != null)
                  IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: () {
                      setState(() {
                        _selectedBab = null;
                      });
                    },
                  ),
              ],
            ),
      body: Consumer(
        builder: (context, ref, child) {
          final salawatAsync = ref.watch(salawatProvider);
          
          return salawatAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(_getLocalizedText('خطأ: $err', 'Error: $err')),
            ),
            data: (allSalawat) {
              final juzItems = allSalawat
                  .where((s) => s.juz == widget.juzNumber)
                  .toList();

              if (juzItems.isEmpty) {
                return Center(
                  child: Text(
                    _getLocalizedText('لا توجد بيانات', 'No data'),
                  ),
                );
              }

              // If a bab is selected, show paginated view
              if (_selectedBab != null) {
                return _buildBabView(settings);
              }

              // Group by bab
              final Map<String, List<SalatModel>> grouped = {};
              for (var item in juzItems) {
                final key = item.bab.isNotEmpty ? item.bab : _getLocalizedText('غير مصنف', 'Uncategorized');
                grouped.putIfAbsent(key, () => []).add(item);
              }

              final sortedKeys = grouped.keys.toList()..sort();

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: sortedKeys.length,
                      itemBuilder: (context, index) {
                        final babName = sortedKeys[index];
                        final items = grouped[babName]!;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedBab = babName;
                                _currentSalawat = items;
                                _currentIndex = 0;
                              });
                              _pageController.jumpToPage(0);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A5C36),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${items.length}',
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
                                          babName,
                                          style: GoogleFonts.amiri(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0A5C36),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: const Color(0xFF0A5C36),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (!_isFullScreen) const AdSpace(height: 50),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBabView(SettingsState settings) {
    return Column(
      children: [
        // Anchored header - always visible
        if (!_isFullScreen)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0A5C36).withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF0A5C36).withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Chapter name
                Expanded(
                  child: Text(
                    _selectedBab!,
                    style: GoogleFonts.amiri(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A5C36),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Page indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A5C36),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${_currentSalawat.length}',
                    style: GoogleFonts.amiri(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Navigation buttons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 14),
                      color: const Color(0xFF0A5C36),
                      onPressed: _currentIndex > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        maxWidth: 30,
                        minHeight: 30,
                        maxHeight: 30,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 14),
                      color: const Color(0xFF0A5C36),
                      onPressed: _currentIndex < _currentSalawat.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        maxWidth: 30,
                        minHeight: 30,
                        maxHeight: 30,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
        
        // Page view for flipping through salawat
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Save last read position - exact page
              final currentSalat = _currentSalawat[index];
              ref.read(settingsProvider.notifier).updateLastRead(
                widget.juzNumber,
                currentSalat.page,
                currentSalat.id,
              );
            },
            itemCount: _currentSalawat.length,
            itemBuilder: (context, index) {
              final salat = _currentSalawat[index];
              return ReadingScreen(
                salat: salat,
                isInJuzView: !_isFullScreen,
                allSalawat: _currentSalawat,
                currentIndex: index,
                isFullScreen: _isFullScreen,
                onToggleFullScreen: _toggleFullScreen,
              );
            },
          ),
        ),
        
        // Bottom ad
        if (!_isFullScreen)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: AdSpace(height: 50),
          ),
      ],
    );
  }
}