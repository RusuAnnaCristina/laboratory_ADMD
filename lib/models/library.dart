
import 'library_item.dart';
import 'user.dart';

class Library {
  final List<LibraryItem> _items = [];

  List<LibraryItem> get items => List.unmodifiable(_items);

  void addItem(LibraryItem item) {
    if (item.title.trim().isNotEmpty) {
      _items.add(item);
    }
  }

List<LibraryItem> searchByTitle(String? text) {
  final q = text?.trim().toLowerCase();
  if (q == null || q.isEmpty) return [];
  return _items
      .where((item) => item.title.toLowerCase().contains(q))
      .toList();
}

List<LibraryItem> getItemsByAuthor(String? author) {
  final q = author?.trim().toLowerCase();
  if (q == null || q.isEmpty) return [];
  return _items
      .where((item) => item.author?.toLowerCase().contains(q) ?? false)
      .toList();
}

  List<LibraryItem> getRecentItems({int days = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _items
        .where((item) =>
            item.publishDate != null && item.publishDate!.isAfter(cutoff))
        .toList();
  }

  bool borrowItem(LibraryItem item, User user, {Duration duration = const Duration(days: 14)}) {
    if (item.isBorrowed) return false;
    item.borrower = user;
    item.dueDate = DateTime.now().add(duration);
    return true;
  }

  bool returnItem(LibraryItem item) {
    if (!item.isBorrowed) return false;
    item.borrower = null;
    item.dueDate = null;
    return true;
  }
}