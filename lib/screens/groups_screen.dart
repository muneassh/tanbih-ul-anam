import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tanbihulanam/providers/settings_provider.dart';
import 'package:tanbihulanam/data/groups_data.dart';
import 'package:tanbihulanam/screens/group_detail_screen.dart';
import 'package:tanbihulanam/services/optimized_classification_service.dart';
import 'package:tanbihulanam/providers/data_provider.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  String _searchQuery = '';
  Map<int, List<int>>? _classification;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClassification();
  }

  Future<void> _loadClassification() async {
    final allSalawat = await ref.read(salawatProvider.future);
    final classification = OptimizedClassificationService.getClassification(allSalawat);
    setState(() {
      _classification = classification;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final groups = GroupsData.getGroups();
    
    final filteredGroups = _searchQuery.isEmpty
        ? groups
        : groups.where((group) {
            final searchLower = _searchQuery.toLowerCase();
            return group.nameAr.contains(_searchQuery) ||
                group.nameEn.toLowerCase().contains(searchLower) ||
                group.descriptionAr.contains(_searchQuery) ||
                group.descriptionEn.toLowerCase().contains(searchLower);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          settings.language == AppLanguage.arabic ? 'المجموعات' : 'Categories',
          style: GoogleFonts.amiri(fontSize: 24),
        ),
        backgroundColor: const Color(0xFF0A5C36),
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
                    ? 'ابحث عن مجموعة...'
                    : 'Search categories...',
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
          : filteredGroups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        settings.language == AppLanguage.arabic
                            ? 'لا توجد مجموعات تطابق بحثك'
                            : 'No categories match your search',
                        style: GoogleFonts.amiri(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final group = filteredGroups[index];
                    final salawatCount = _classification?[group.id]?.length ?? 0;
                    return _buildGroupCard(group, salawatCount, settings);
                  },
                ),
    );
  }

  Widget _buildGroupCard(SalawatGroup group, int salawatCount, SettingsState settings) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetailScreen(group: group),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                group.color.withOpacity(0.8),
                group.color.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                group.icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                settings.language == AppLanguage.arabic
                    ? group.nameAr
                    : group.nameEn,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  settings.language == AppLanguage.arabic
                      ? '$salawatCount صلاة'
                      : '$salawatCount prayers',
                  style: GoogleFonts.amiri(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}