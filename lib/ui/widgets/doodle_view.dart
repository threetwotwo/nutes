import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nutes/core/models/doodle.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/styles.dart';

class DoodleView extends StatefulWidget {
  final VoidCallback onLongPress;
  final VoidCallback onLongPressUp;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Doodle doodle;
  final VoidCallback onError;
  const DoodleView({
    Key key,
    this.onLongPress,
    this.onLongPressUp,
    this.onNext,
    this.onPrevious,
    @required this.doodle,
    this.onError,
  }) : super(key: key);

  @override
  _DoodleViewState createState() => _DoodleViewState();
}

class _DoodleViewState extends State<DoodleView> {
  bool _headerIsVisible = true;

  Image _image;

  bool isLoaded = false;
  bool isVisible = false;

  Timer _debounce;

  ImageStreamListener imageStreamListener() =>
      ImageStreamListener((info, call) async {
        print(info);
        print(call);
        if (info != null && mounted) {
          print('doodle loaded');

          setState(() {
//            doodles[currentPage] =
//                doodles[currentPage].copyWith(isLoaded: true);
            isLoaded = true;
          });

          await Future.delayed(Duration(milliseconds: 50));
          setState(() {
            isVisible = true;
          });
          if (_debounce?.isActive ?? false) _debounce.cancel();

          _debounce =
              Timer(const Duration(milliseconds: 3500), () => widget.onNext());
        }
      }, onError: (_, __) {
        print('error loading doodle');

        return widget.onError();
      });

  @override
  void initState() {
    _image = Image.network(
      widget.doodle.url,
      fit: BoxFit.contain,
    )..image.resolve(ImageConfiguration()).addListener(imageStreamListener());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoaded
        ? LoadingIndicator()
        : AnimatedOpacity(
            opacity: isVisible ? 1 : 0,
            duration: Duration(milliseconds: 200),
            child: Stack(
              children: <Widget>[
                ///Doodle image
                Positioned.fill(
//          child: DoodleImage(doodle: widget.doodle),
                  child: _image,
                ),
                Positioned.fill(
                  child: Row(
                    children: <Widget>[
                      ///Go back gesture
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onLongPress: () {
                            setState(() {
                              _headerIsVisible = false;
                            });
                            if (_debounce?.isActive ?? false)
                              _debounce.cancel();
                            return widget.onLongPress();
                          },
                          onLongPressUp: () {
                            setState(() {
                              _headerIsVisible = true;
                            });
                            _debounce = Timer(
                                const Duration(milliseconds: 2500),
                                () => widget.onLongPressUp());
                            return;
                          },
                          onTap: () {
                            if (_debounce?.isActive ?? false)
                              _debounce.cancel();
                            return widget.onPrevious();
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: GestureDetector(
                          onLongPress: () {
                            setState(() {
                              _headerIsVisible = false;
                            });
                            if (_debounce?.isActive ?? false)
                              _debounce.cancel();
                            return widget.onLongPress();
                          },
                          onLongPressUp: () {
                            setState(() {
                              _headerIsVisible = true;
                            });
                            _debounce = Timer(
                                const Duration(milliseconds: 2500),
                                () => widget.onLongPressUp());
                            return;
                          },
                          onTap: () {
                            if (_debounce?.isActive ?? false)
                              _debounce.cancel();
                            return widget.onNext();
                          },
                          child: Container(
//                              color: Colors.green,
                            color: Colors.green[300].withOpacity(0.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ///Header
//        if (_headerIsVisible)
                Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedOpacity(
                    opacity: _headerIsVisible ? 1 : 0,
                    duration: Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      margin: const EdgeInsets.all(4),
                      decoration: ShapeDecoration(
                        shape: StadiumBorder(),
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.push(context,
                            ProfileScreen.route(widget.doodle.owner.uid)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              height: 36,
                              width: 36,
//                              margin: const EdgeInsets.all(4.0),
                              child: AvatarImage(
                                padding: 4,
                                spacing: 0,
                                url: widget.doodle.owner.urls.small,
                              ),
//                              child: CircleAvatar(
//                                backgroundImage: CachedNetworkImageProvider(
//                                  doodle.owner.urls.small,
//                                ),
//                              ),
                            ),
                            Text(
                              widget.doodle.owner.username,
                              style: TextStyles.defaultText.copyWith(
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.8,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

class DoodleImage extends StatefulWidget {
  const DoodleImage({
    Key key,
    @required this.doodle,
  }) : super(key: key);

  final Doodle doodle;

  @override
  _DoodleImageState createState() => _DoodleImageState();
}

class _DoodleImageState extends State<DoodleImage> {
  bool isVisible = false;

  void _showImage() async {
    await Future.delayed(Duration(milliseconds: 50));
    setState(() {
      isVisible = true;
    });
  }

  @override
  void initState() {
    print('init doodle image');
    _showImage();
    super.initState();
  }

  @override
  void dispose() {
    print('dispose doodle image');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    return CachedNetworkImage(
//      imageUrl: widget.doodle.url,
//    );
    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInSine,
      child: Image.network(
        widget.doodle.url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }

          if (progress.cumulativeBytesLoaded == progress.expectedTotalBytes) {
            print('doodle load complete');
          }
          return SizedBox();
        },
      ),
    );
  }
}
