import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssetCarousel extends StatefulWidget {
  const AssetCarousel({
    super.key,
    required this.assetPrefix,
    this.fallbackSingleImage,
  });
  final String assetPrefix;
  final String? fallbackSingleImage;

  @override
  State<AssetCarousel> createState() => _AssetCarouselState();
}

class _AssetCarouselState extends State<AssetCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  List<String> _images = [];
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
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

      if (filtered.isEmpty && widget.fallbackSingleImage != null) {
        filtered.add(widget.fallbackSingleImage!);
      }

      setState(() {
        _images = filtered;
      });

      if (_images.length > 1) {
        _timer = Timer.periodic(const Duration(milliseconds: 4000), (t) {
          if (!mounted) return;
          _current = (_current + 1) % _images.length;
          _controller.animateToPage(
            _current,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        });
      }
    } catch (_) {
      if (widget.fallbackSingleImage != null) {
        setState(() {
          _images = [widget.fallbackSingleImage!];
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.photo_library_outlined, size: 56),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: _images.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (context, index) {
            return Image.asset(_images[index], fit: BoxFit.cover);
          },
        ),
        if (_images.length > 1)
          Positioned(
            bottom: 12,
            child: Row(
              children: List.generate(
                _images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: i == _current ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == _current ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
