import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'diagnostics.dart';

/// Captures any [RepaintBoundary] under [boundaryKey] as a PNG and hands it to
/// the OS share sheet. Designed for the Daily Replay outro and any other
/// "save / share this moment" surface the app exposes later.
class ShareExport {
  ShareExport._();

  /// Capture the boundary as a PNG byte buffer at the given pixel ratio.
  static Future<Uint8List?> capturePng(
    GlobalKey boundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    try {
      final ctx = boundaryKey.currentContext;
      if (ctx == null) return null;
      final boundary =
          ctx.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return byteData?.buffer.asUint8List();
    } catch (e, st) {
      WxLog.error('share-export.capture', 'png capture failed', e, st);
      return null;
    }
  }

  /// Capture a boundary, write it to a temp PNG, hand it to the share sheet.
  /// Returns true if the share sheet was opened.
  static Future<bool> shareBoundary(
    GlobalKey boundaryKey, {
    String filename = 'wellbeingx-replay.png',
    String text = 'My day, in 60 seconds — WellbeingX',
    double pixelRatio = 3.0,
  }) async {
    final bytes = await capturePng(boundaryKey, pixelRatio: pixelRatio);
    if (bytes == null) return false;
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        <XFile>[XFile(file.path, mimeType: 'image/png')],
        text: text,
      );
      return true;
    } catch (e, st) {
      WxLog.error('share-export.share', 'share intent failed', e, st);
      return false;
    }
  }
}
