import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'native_bridge.dart';

/// Lazy, cached fetcher for real Android app icons. Each icon is loaded once
/// per app process, kept in memory as a [Uint8List], and decoded by Flutter on
/// first paint. Failed lookups also cache (as null) so we don't hammer
/// PackageManager every rebuild.
class AppIconService {
  AppIconService._();

  static final Map<String, Uint8List?> _cache = <String, Uint8List?>{};
  static final Map<String, Future<Uint8List?>> _inflight =
      <String, Future<Uint8List?>>{};

  static Future<Uint8List?> get(String packageName) {
    if (_cache.containsKey(packageName)) {
      return Future<Uint8List?>.value(_cache[packageName]);
    }
    final pending = _inflight[packageName];
    if (pending != null) return pending;
    final f = NativeBridge.getAppIcon(packageName).then((bytes) {
      _cache[packageName] = bytes;
      _inflight.remove(packageName);
      return bytes;
    });
    _inflight[packageName] = f;
    return f;
  }

  /// Synchronous lookup — only returns cached value, or null. Useful inside
  /// build() to avoid FutureBuilder churn after the first load.
  static Uint8List? cached(String packageName) => _cache[packageName];
}

final appIconsProvider = Provider<AppIconService>((_) => AppIconService._());

/// A drop-in widget that renders the real app icon when available, falling
/// back to a colored letter tile while loading or when the icon can't be
/// fetched. Designed to never flash — fades the icon in when it lands.
class AppIconAvatar extends StatefulWidget {
  const AppIconAvatar({
    super.key,
    required this.packageName,
    required this.fallbackLabel,
    required this.fallbackColor,
    this.size = 36,
    this.radius = 10,
  });

  final String packageName;
  final String fallbackLabel;
  final Color fallbackColor;
  final double size;
  final double radius;

  @override
  State<AppIconAvatar> createState() => _AppIconAvatarState();
}

class _AppIconAvatarState extends State<AppIconAvatar> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    final cached = AppIconService.cached(widget.packageName);
    if (cached != null) {
      _bytes = cached;
    } else {
      AppIconService.get(widget.packageName).then((b) {
        if (mounted && b != null) setState(() => _bytes = b);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.fallbackColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: Text(
        widget.fallbackLabel.isEmpty ? '?' : widget.fallbackLabel[0],
        style: TextStyle(
          fontSize: widget.size * 0.42,
          fontWeight: FontWeight.w800,
          color: widget.fallbackColor,
        ),
      ),
    );

    if (_bytes == null) return fallback;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: ClipRRect(
        key: ValueKey<String>(widget.packageName),
        borderRadius: BorderRadius.circular(widget.radius),
        child: Image.memory(
          _bytes!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}

