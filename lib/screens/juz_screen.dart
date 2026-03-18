import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tanbihulanam/providers/data_provider.dart';
import 'package:tanbihulanam/screens/reading_screen.dart';
import 'package:tanbihulanam/models/salat_model.dart';

class JuzScreen extends ConsumerStatefulWidget {
  final int juzNumber;

  const JuzScreen({super.key, required this.juzNumber});

  @override
  ConsumerState<JuzScreen> createState() => _JuzScreenState();
}

class _JuzScreenState extends ConsumerState<JuzScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _visibleItems = 20; // Show only 20 items initially

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      setState(() {
        _visibleItems += 20;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الجزء ${widget.juzNumber}',
          style: GoogleFonts.amiri(fontSize: 24),
        ),
        backgroundColor: const Color(0xFF0A5C36),
        foregroundColor: Colors.white,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final salawatAsync = ref.watch(salawatProvider);
          
          return salawatAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (err, stack) => Center(
              child: Text('خطأ: $err'),
            ),
            data: (allSalawat) {
              final juzItems = allSalawat
                  .where((s) => s.juz == widget.juzNumber)
                  .toList();

              if (juzItems.isEmpty) {
                return const Center(
                  child: Text('لا توجد بيانات لهذا الجزء'),
                );
              }

              // Group by bab (chapter)
              final Map<String, List<SalatModel>> grouped = {};
              for (var item in juzItems) {
                final key = item.bab.isNotEmpty ? item.bab : 'غير مصنف';
                grouped.putIfAbsent(key, () => []).add(item);
              }

              final sortedKeys = grouped.keys.toList()..sort();

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final babName = sortedKeys[index];
                  final items = grouped[babName]!;
                  
                  // Show limited items initially
                  final displayItems = items.take(_visibleItems).toList();
                  final hasMore = items.length > _visibleItems;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        title: Text(
                          babName,
                          style: GoogleFonts.amiri(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A5C36),
                          ),
                        ),
                        subtitle: Text(
                          '${items.length} صلاة',
                          style: GoogleFonts.amiri(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        children: [
                          ...displayItems.map((salat) {
                            return ListTile(
                              title: Text(
                                'صفحة ${salat.page} • رقم ${salat.id}',
                                style: GoogleFonts.amiri(fontSize: 18),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios, 
                                size: 16,
                                color: Color(0xFF0A5C36),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReadingScreen(
                                      salat: salat,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                          if (hasMore)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _visibleItems += 20;
                                    });
                                  },
                                  child: Text(
                                    'عرض المزيد...',
                                    style: GoogleFonts.amiri(
                                      color: const Color(0xFF0A5C36),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: Colors.black12,
        alignment: Alignment.center,
        child: Text(
          'AD SPACE',
          style: GoogleFonts.amiri(color: Colors.grey[600]),
        ),
      ),
    );
  }
}