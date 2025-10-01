import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundSlideshow extends StatefulWidget {
  const BackgroundSlideshow({
    super.key,
    required this.assetPrefix,
    required this.fallbackSingleImage,
    this.opacity = 0.08,
    this.intervalMs = 6000,
    this.fadeMs = 900,
  });

  final String assetPrefix;
  final String fallbackSingleImage;
  final double opacity;
  final int intervalMs;
  final int fadeMs;

  @override
  State<BackgroundSlideshow> createState() => _BackgroundSlideshowState();
}

class _BackgroundSlideshowState extends State<BackgroundSlideshow>
    with SingleTickerProviderStateMixin {
  List<String> _images = [];
  int _current = 0;
  int _next = 0;
  Timer? _timer;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.fadeMs),
    );
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestJson);
      final List<String> all = manifest.keys.cast<String>().toList();
      final List<String> filtered =
          all
              .where((p) => p.startsWith(widget.assetPrefix))
              .where(
                (p) =>
                    p.endsWith('.png') ||
                    p.endsWith('.jpg') ||
                    p.endsWith('.jpeg') ||
                    p.endsWith('.webp'),
              )
              .toList()
            ..sort();

      if (filtered.isEmpty) {
        filtered.add(widget.fallbackSingleImage);
      }

      setState(() {
        _images = filtered;
        _current = 0;
        _next = _images.length > 1 ? 1 : 0;
      });

      if (_images.length > 1) {
        _timer = Timer.periodic(Duration(milliseconds: widget.intervalMs), (
          t,
        ) async {
          if (!mounted) return;
          await _fadeController.forward(from: 0);
          setState(() {
            _current = _next;
            _next = (_next + 1) % _images.length;
          });
          _fadeController.reset();
        });
      }
    } catch (_) {
      setState(() {
        _images = [widget.fallbackSingleImage];
        _current = 0;
        _next = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }
    return Opacity(
      opacity: widget.opacity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(images[_current], fit: BoxFit.cover),
          if (images.length > 1)
            FadeTransition(
              opacity: _fadeController,
              child: Image.asset(images[_next], fit: BoxFit.cover),
            ),
        ],
      ),
    );
  }
}
