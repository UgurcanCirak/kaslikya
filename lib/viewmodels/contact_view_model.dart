import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactViewModel extends ChangeNotifier {
  static const double lat = 36.20205974539514;
  static const double lng = 29.64003517685688;

  Future<void> copyMapLinkToClipboard(BuildContext context) async {
    final url =
        'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=16/$lat/$lng';
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harita bağlantısı kopyalandı. Tarayıcıya yapıştırabilirsiniz.',
          ),
        ),
      );
    }
  }
}
