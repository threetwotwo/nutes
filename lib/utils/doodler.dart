import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'dart:ui';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/gestures.dart';

class Painter extends StatefulWidget {
  final Color color;
  final PainterController painterController;
  final VoidCallback onFinish;

  Painter({PainterController painterController, this.onFinish, this.color})
      : this.painterController = painterController,
        super(key: ValueKey<PainterController>(painterController));

  @override
  _PainterState createState() => _PainterState();
}

class _PainterState extends State<Painter> {
  bool _finished;
  Timer _debounce;

  @override
  void initState() {
    super.initState();
    _finished = false;
    widget.painterController._widgetFinish = _finish;

    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 2500), () {
      return widget.onFinish();
    });
  }

  Size _finish() {
    setState(() {
      _finished = true;
    });
    return context.size;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = CustomPaint(
      willChange: true,
      painter: _PainterPainter(
        widget.painterController._pathHistory,
        repaint: widget.painterController,
      ),
    );
    child = new ClipRect(child: child);
    if (!_finished) {
      child = RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          CustomPanGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<CustomPanGestureRecognizer>(
            () => CustomPanGestureRecognizer(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
            ),
            (_) {},
          ),
        },
        child: child,
      );

//    child = new GestureDetector(
//      child: child,
//      onPanStart: onPanStart,
//      onPanUpdate: onPanUpdate,
//      onPanEnd: onPanEnd,
//    );

    }
    return new Container(
      child: child,
      width: double.infinity,
      height: double.infinity,
    );
  }

  bool _onPanStart(Offset start) {
    Offset pos = (context.findRenderObject() as RenderBox).globalToLocal(start);
    widget.painterController._pathHistory.add(pos);
    widget.painterController._notifyListeners();

    return start != null;
  }

  void _onPanUpdate(PointerEvent update) {
    Offset pos = (context.findRenderObject() as RenderBox)
        .globalToLocal(update.position);
    final pressure = update.pressure;

    widget.painterController._pathHistory.updateCurrent(pos, pressure);
    widget.painterController._notifyListeners();

    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 2500), () {
      // do something with _searchQuery.text
      return widget.onFinish();
    });
  }

  void _onPanEnd(Offset end) {
    widget.painterController._pathHistory.endCurrent();
    widget.painterController._notifyListeners();
  }
}

class _PainterPainter extends CustomPainter {
  final _PathHistory _path;

  _PainterPainter(this._path, {Listenable repaint}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    _path.draw(canvas, size);
  }

  @override
  bool shouldRepaint(_PainterPainter oldDelegate) {
    return true;
  }
}

class _PathHistory {
  List<MapEntry<Path, Paint>> _paths;
  Paint currentPaint;
  Paint _backgroundPaint;
  bool _inDrag;

  _PathHistory() {
    _paths = new List<MapEntry<Path, Paint>>();
    _inDrag = false;
    _backgroundPaint = new Paint();
  }

  void setBackgroundColor(Color backgroundColor) {
    _backgroundPaint.color = backgroundColor;
  }

  void undo() {
    if (!_inDrag) {
      _paths.removeLast();
    }
  }

  void clear() {
    if (!_inDrag) {
      _paths.clear();
    }
  }

  void add(Offset startPoint) {
    if (!_inDrag) {
      _inDrag = true;
      Path path = new Path();
      path.moveTo(startPoint.dx, startPoint.dy);

      _paths.add(new MapEntry<Path, Paint>(path, currentPaint));
    }
  }

  void updateCurrent(Offset nextPoint, double pressure) {
    if (_inDrag) {
      Path path = _paths.last.key;

      path.lineTo(nextPoint.dx, nextPoint.dy);

//      Paint paint = _paths.last.value;

//      paint.strokeWidth = pressure;
    }
  }

  void endCurrent() {
    _inDrag = false;
  }

  void draw(Canvas canvas, Size size) {
    canvas.drawRect(
        new Rect.fromLTWH(0.0, 0.0, size.width, size.height), _backgroundPaint);
    for (MapEntry<Path, Paint> path in _paths) {
      canvas.drawPath(path.key, path.value);
    }
  }
}

typedef PictureDetails PictureCallback();

class PictureDetails {
  final Picture picture;
  final int width;
  final int height;

  const PictureDetails(this.picture, this.width, this.height);

  Future<Image> toImage() {
    return picture.toImage(width, height);
  }

  Future<Uint8List> toPNG() async {
    final image = await toImage();
    return (await image.toByteData(format: ImageByteFormat.png))
        .buffer
        .asUint8List();
  }
}

class PainterController extends ChangeNotifier {
  Color _drawColor = Color.fromARGB(255, 0, 0, 0);
  Color _backgroundColor = Color.fromARGB(255, 255, 255, 255);

  double _thickness = 8.0;
  PictureDetails _cached;
  _PathHistory _pathHistory;
  ValueGetter<Size> _widgetFinish;

  PainterController() {
    _pathHistory = _PathHistory();
  }

  Color get drawColor => _drawColor;

  set drawColor(Color color) {
    _drawColor = color;
    _updatePaint();
  }

  Color get backgroundColor => _backgroundColor;

  set backgroundColor(Color color) {
    _backgroundColor = color;
    _updatePaint();
  }

  double get thickness => _thickness;

  set thickness(double t) {
    _thickness = t;
    _updatePaint();
  }

  void _updatePaint() {
    final paint = new Paint()
      ..strokeCap = StrokeCap.round
      ..color = drawColor
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = thickness;

//    paint.color = drawColor;
//    paint.style = PaintingStyle.stroke;
//    paint.strokeWidth = thickness;
    _pathHistory.currentPaint = paint;
    _pathHistory.setBackgroundColor(backgroundColor);
    notifyListeners();
  }

  void undo() {
    if (!isFinished()) {
      _pathHistory.undo();
      notifyListeners();
    }
  }

  void _notifyListeners() {
    notifyListeners();
  }

  void clear() {
//    if (!isFinished()) {
    _pathHistory.clear();
    notifyListeners();
//    }
  }

  PictureDetails finish() {
    if (!isFinished()) {
      _cached = _render(_widgetFinish());
    }
    return _cached;
  }

  PictureDetails _render(Size size) {
    PictureRecorder recorder = new PictureRecorder();
    Canvas canvas = new Canvas(recorder);
    _pathHistory.draw(canvas, size);
    return new PictureDetails(
        recorder.endRecording(), size.width.floor(), size.height.floor());
  }

  bool isFinished() {
    return _cached != null;
  }
}

class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  final Function onPanStart;
  final Function onPanUpdate;
  final Function onPanEnd;

  CustomPanGestureRecognizer(
      {@required this.onPanStart,
      @required this.onPanUpdate,
      @required this.onPanEnd});

  @override
  void addPointer(PointerEvent event) {
    if (onPanStart(event.position)) {
      startTrackingPointer(event.pointer);
      resolve(GestureDisposition.accepted);
    } else {
      stopTrackingPointer(event.pointer);
    }

    return onPanStart(event.position);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      onPanUpdate(event);
    }
    if (event is PointerUpEvent) {
      onPanEnd(event.position);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  String get debugDescription => 'customPan';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
