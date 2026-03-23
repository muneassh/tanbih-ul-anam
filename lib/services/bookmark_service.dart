import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/salat_model.dart';

class BookmarkService {
  static const String _boxName = 'bookmarks';
  static const String _pageBookmarksKey = 'pageBookmarks';

  static Future<Box<dynamic>> _getBox() async {
    return await Hive.openBox(_boxName);
  }

  static Future<List<int>> getBookmarks() async {
    try {
      // On web, return empty list if no box
      if (kIsWeb) {
        return [];
      }
      final box = await _getBox();
      final bookmarks = box.get('bookmarkedIds', defaultValue: <int>[]);
      if (bookmarks is List) {
        return List<int>.from(bookmarks);
      }
      return [];
    } catch (e) {
      print('Error getting bookmarks: $e');
      return [];
    }
  }

  static Future<void> addBookmark(int id) async {
    try {
      if (kIsWeb) return; // Skip on web
      final box = await _getBox();
      final bookmarks = await getBookmarks();
      if (!bookmarks.contains(id)) {
        bookmarks.add(id);
        await box.put('bookmarkedIds', bookmarks);
        print('Bookmark added: $id. Total bookmarks: ${bookmarks.length}');
      }
    } catch (e) {
      print('Error adding bookmark: $e');
      rethrow;
    }
  }

  static Future<void> removeBookmark(int id) async {
    try {
      if (kIsWeb) return; // Skip on web
      final box = await _getBox();
      final bookmarks = await getBookmarks();
      bookmarks.remove(id);
      await box.put('bookmarkedIds', bookmarks);
      print('Bookmark removed: $id. Total bookmarks: ${bookmarks.length}');
    } catch (e) {
      print('Error removing bookmark: $e');
      rethrow;
    }
  }

  static Future<bool> isBookmarked(int id) async {
    try {
      final bookmarks = await getBookmarks();
      return bookmarks.contains(id);
    } catch (e) {
      print('Error checking bookmark: $e');
      return false;
    }
  }

  // Page-level bookmark methods
  static Future<Set<String>> getPageBookmarks() async {
    try {
      if (kIsWeb) return {}; // Skip on web
      final box = await _getBox();
      final pageBookmarks = box.get(_pageBookmarksKey, defaultValue: <String>[]);
      if (pageBookmarks is List) {
        return Set<String>.from(pageBookmarks);
      }
      return {};
    } catch (e) {
      print('Error getting page bookmarks: $e');
      return {};
    }
  }

  static Future<void> addPageBookmark(String pageKey) async {
    try {
      if (kIsWeb) return; // Skip on web
      final box = await _getBox();
      final pageBookmarks = await getPageBookmarks();
      if (!pageBookmarks.contains(pageKey)) {
        pageBookmarks.add(pageKey);
        await box.put(_pageBookmarksKey, pageBookmarks.toList());
        print('Page bookmark added: $pageKey. Total page bookmarks: ${pageBookmarks.length}');
      }
    } catch (e) {
      print('Error adding page bookmark: $e');
      rethrow;
    }
  }

  static Future<void> removePageBookmark(String pageKey) async {
    try {
      if (kIsWeb) return; // Skip on web
      final box = await _getBox();
      final pageBookmarks = await getPageBookmarks();
      pageBookmarks.remove(pageKey);
      await box.put(_pageBookmarksKey, pageBookmarks.toList());
      print('Page bookmark removed: $pageKey. Total page bookmarks: ${pageBookmarks.length}');
    } catch (e) {
      print('Error removing page bookmark: $e');
      rethrow;
    }
  }

  static Future<bool> isPageBookmarked(String pageKey) async {
    try {
      final pageBookmarks = await getPageBookmarks();
      return pageBookmarks.contains(pageKey);
    } catch (e) {
      print('Error checking page bookmark: $e');
      return false;
    }
  }

  static Future<void> clearAllBookmarks() async {
    try {
      if (kIsWeb) return; // Skip on web
      final box = await _getBox();
      await box.clear();
      print('All bookmarks cleared');
    } catch (e) {
      print('Error clearing bookmarks: $e');
    }
  }
}