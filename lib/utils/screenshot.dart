import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import 'image_file_bundle.dart';

class ScreenshotController {
  GlobalKey _containerKey;
  ScreenshotController() {
    _containerKey = GlobalKey();
  }
  Future<ImageFileBundle> capture({
    @required int index,
    String path = "",
    double pixelRatio: 4,
    double aspectRatio = 1,
  }) async {
    try {
      final original = await _createImageFile(pixelRatio, path);
      final medium = await _createImageFile(pixelRatio / 4, path);
      final small = await _createImageFile(pixelRatio / 8, path);
      return ImageFileBundle(
        index: index,
        aspectRatio: aspectRatio,
        original: original,
        medium: medium,
        small: small,
      );
    } catch (Exception) {
      throw (Exception);
    }
  }

  Future<File> _createImageFile(double pixelRatio, String path) async {
    RenderRepaintBoundary boundary =
        this._containerKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    if (path == "") {
      final directory = (await getApplicationDocumentsDirectory()).path;
      String fileName = DateTime.now().toIso8601String();
      path = '$directory/$fileName.png';
    }
    File imgFile = new File(path);
    await imgFile.writeAsBytes(pngBytes).then((onValue) {});
    return imgFile;
  }
}

class Screenshot<T> extends StatefulWidget {
  final Widget child;
  final ScreenshotController controller;
  final GlobalKey containerKey;
  const Screenshot({Key key, this.child, this.controller, this.containerKey})
      : super(key: key);
  @override
  State<Screenshot> createState() {
    return new ScreenshotState();
  }
}

class ScreenshotState extends State<Screenshot> with TickerProviderStateMixin {
  ScreenshotController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = ScreenshotController();
    } else
      _controller = widget.controller;
  }

  @override
  void didUpdateWidget(Screenshot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      widget.controller._containerKey = oldWidget.controller._containerKey;
      if (oldWidget.controller != null && widget.controller == null)
        _controller._containerKey = oldWidget.controller._containerKey;
      if (widget.controller != null) {
        if (oldWidget.controller == null) {
          _controller = null;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _controller._containerKey,
      child: widget.child,
    );
  }
}
