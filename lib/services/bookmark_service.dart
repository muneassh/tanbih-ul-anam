import 'package:hive_flutter/hive_flutter.dart';
import '../models/salat_model.dart';

class BookmarkService {
  static const String _boxName = 'bookmarks';

  static Future<Box<dynamic>> _getBox() async {
    return await Hive.openBox(_boxName);
  }

  static Future<List<int>> getBookmarks() async {
    final box = await _getBox();
    return box.get('bookmarkedIds', defaultValue: <int>[]).cast<int>();
  }

  static Future<void> addBookmark(int id) async {
    final box = await _getBox();
    final bookmarks = await getBookmarks();
    if (!bookmarks.contains(id)) {
      bookmarks.add(id);
      await box.put('bookmarkedIds', bookmarks);
    }
  }

  static Future<void> removeBookmark(int id) async {
    final box = await _getBox();
    final bookmarks = await getBookmarks();
    bookmarks.remove(id);
    await box.put('bookmarkedIds', bookmarks);
  }

  static Future<bool> isBookmarked(int id) async {
    final bookmarks = await getBookmarks();
    return bookmarks.contains(id);
  }
}