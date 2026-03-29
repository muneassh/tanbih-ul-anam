import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tanbihulanam/data/groups_data.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/providers/data_provider.dart';
import 'package:tanbihulanam/models/salat_model.dart';
import 'package:tanbihulanam/screens/juz_screen.dart';
import 'package:tanbihulanam/widgets/highlighted_text.dart';
import 'package:tanbihulanam/services/optimized_classification_service.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final SalawatGroup group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  String _searchQuery = '';
  List<SalatModel> _groupSalawat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroupSalawat();
  }

  Future<void> _loadGroupSalawat() async {
    final allSalawat = await ref.read(salawatProvider.future);
    final groupSalawat = OptimizedClassificationService.getSalawatForGroup(
      widget.group.id, 
      allSalawat,
    );
    
    if (mounted) {
      setState(() {
        _groupSalawat = groupSalawat;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    
    final filteredSalawat = _searchQuery.isEmpty
        ? _groupSalawat
        : _groupSalawat.where((salat) {
            return salat.arabic.contains(_searchQuery) ||
                salat.bab.contains(_searchQuery);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          settings.language == AppLanguage.arabic
              ? widget.group.nameAr
              : widget.group.nameEn,
          style: GoogleFonts.amiri(fontSize: 24),
        ),
        backgroundColor: widget.group.color,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: settings.language == AppLanguage.arabic
                    ? 'ابحث في المجموعة...'
                    : 'Search in this category...',
                hintStyle: GoogleFonts.amiri(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                fillColor: Colors.white.withOpacity(0.2),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.amiri(color: Colors.white),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredSalawat.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.group.icon,
                        size: 64,
                        color: widget.group.color,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        settings.language == AppLanguage.arabic
                            ? _searchQuery.isEmpty
                                ? 'لا توجد صلوات في هذه المجموعة'
                                : 'لا توجد نتائج مطابقة للبحث'
                            : _searchQuery.isEmpty
                                ? 'No prayers in this category'
                                : 'No matching results',
                        style: GoogleFonts.amiri(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filteredSalawat.length,
                  itemBuilder: (context, index) {
                    final salat = filteredSalawat[index];
                    final isLast = index == filteredSalawat.length - 1;
                    
                    return _buildSalawatItem(salat, settings, isLast);
                  },
                ),
    );
  }

  Widget _buildSalawatItem(SalatModel salat, SettingsState settings, bool isLast) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JuzScreen(
                  juzNumber: salat.juz,
                  initialSalatId: salat.id,
                  initialPage: salat.page,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: widget.group.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              widget.group.icon,
                              color: widget.group.color,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${settings.language == AppLanguage.arabic ? 'صفحة' : 'Page'} ${salat.page}',
                          style: GoogleFonts.amiri(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: widget.group.color,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${settings.language == AppLanguage.arabic ? 'الجزء' : 'Part'} ${salat.juz}',
                        style: GoogleFonts.amiri(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (salat.bab.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      salat.bab,
                      style: GoogleFonts.amiri(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                HighlightedText(
                  text: salat.arabic,
                  fontSize: settings.fontSize,
                  font: settings.selectedFont,
                  isDarkMode: settings.isDarkMode,
                  textAlign: TextAlign.right,
                  searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.grey[300],
          ),
      ],
    );
  }
}