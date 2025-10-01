import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AnnouncementItem {
  final String title;
  final String date;
  const AnnouncementItem({required this.title, required this.date});
}

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    _load();
  }

  final List<AnnouncementItem> _items = [];
  List<AnnouncementItem> get announcements => List.unmodifiable(_items);

  Future<void> _load() async {
    _items
      ..clear()
      ..addAll(const [
        AnnouncementItem(
          title: 'JEAN MONNET Burs Programı 2026-2027 Duyurusu',
          date: '26 Eylül 2025',
        ),
        AnnouncementItem(
          title: '11. Uluslararası Enerji Verimliliği Forumu',
          date: '01 Eylül 2025',
        ),
        AnnouncementItem(
          title: 'T.C. İstanbul Kent Üniversitesi Duyurusu',
          date: '18 Ağustos 2025',
        ),
      ]);
    notifyListeners();
  }

  Future<void> copySeeAllLink() async {
    const url = 'https://www.kas.bel.tr/';
    await Clipboard.setData(const ClipboardData(text: url));
  }
}
