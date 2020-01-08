import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/toast_message.dart';
import 'package:nutes/utils/painter.dart';
import 'package:path_provider/path_provider.dart';

class DoodleEditor extends StatefulWidget {
  final bool isDoodling;

  final PainterController controller;

//  final VoidCallback onCancel;

  final void Function(File file) onFinish;

  final void Function(Color color) onColor;

  const DoodleEditor(
      {Key key, this.isDoodling, this.controller, this.onFinish, this.onColor})
      : super(key: key);

  @override
  _DoodleEditorState createState() => _DoodleEditorState();
}

class _DoodleEditorState extends State<DoodleEditor> {
  Timer timer;

  bool showMessage = false;

  Color pickedColor;

  bool showEditor = false;

  void onColor(Color color) {
    setState(() {
      pickedColor = color;
    });
    return widget.onColor(color);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    setState(() {
      showMessage = true;
    });

    timer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        showMessage = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isDoodling,
      child: Container(
        color: Colors.grey[50].withOpacity(0.6),
        child: Stack(
          children: <Widget>[
            if (pickedColor != null)
              Align(
                  alignment: Alignment.topCenter,
                  child: ToastMessage(
                    title: 'Start drawing!',
                  )),

            ///Color picker
            if (pickedColor == null)
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ToastMessage(title: 'Pick a color'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ColorAvatar(
                            color: Colors.black,
                            onTap: (val) => onColor(val),
                          ),
                          ColorAvatar(
                            color: Colors.white,
                            onTap: (val) => onColor(val),
                          ),
                          ColorAvatar(
                            color: Colors.blueAccent,
                            onTap: (val) => onColor(val),
                          ),
                          ColorAvatar(
                            color: Colors.green,
                            onTap: (val) => onColor(val),
                          ),
                          ColorAvatar(
                            color: Colors.redAccent,
                            onTap: (val) => onColor(val),
                          ),
                          ColorAvatar(
                            color: Colors.yellow,
                            onTap: (val) => onColor(val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ///Editor
            if (pickedColor != null)
              Positioned.fill(
                child: Painter(
                  painterController: widget.controller,
                  onFinish: () async {
                    print('on finished');
                    if (widget.controller.pathHistory.paths.isEmpty) {
                      print('no doodle paths');
                      return widget.onFinish(null);
                    }

                    final png = await widget.controller.finish().toPNG();

                    final systemTempDir = await getTemporaryDirectory();

                    String fileName = DateTime.now().toIso8601String();

                    final file =
                        await File('${systemTempDir.path}/$fileName.png')
                            .create()
                          ..writeAsBytesSync(png);

                    return widget.onFinish(file);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ColorAvatar extends StatelessWidget {
  final Color color;

  final void Function(Color color) onTap;

  const ColorAvatar({Key key, this.color, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(color),
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8,
            )
          ],
        ),
      ),
    );
  }
}
