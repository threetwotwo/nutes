import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nutes/core/models/doodle.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/styles.dart';

class DoodleView extends StatefulWidget {
  final List<Doodle> doodles;
  final bool isVisible;
  final VoidCallback onError;
  final VoidCallback onFinish;

  const DoodleView(
      {Key key,
      this.doodles,
      this.isVisible = false,
      this.onError,
      this.onFinish})
      : super(key: key);

  @override
  _DoodleViewState createState() => _DoodleViewState();
}

class _DoodleViewState extends State<DoodleView> {
  bool isLoaded = false;

  List<Image> _images;

  final pageController = PageController();

  Timer _debounce;

  List<Doodle> doodles = [];

//  Stopwatch _timer = Stopwatch()..;

  int currentPage = 0;

  bool _headerIsVisible = true;

  ImageStreamListener imageStreamListener() =>
      ImageStreamListener((info, call) async {
        print(info);
        print(call);
        if (info != null && mounted) {
          print('doodle loaded');
          setState(() {
            doodles[currentPage] =
                doodles[currentPage].copyWith(isLoaded: true);
          });

          if (_debounce?.isActive ?? false) _debounce.cancel();

          _debounce =
              Timer(const Duration(milliseconds: 3500), () => _nextDoodle());
        }
      }, onError: (_, __) {
        print('error loading doodle');

        return widget.onError();
      });

  void _nextDoodle() async {
    if (!pageController.hasClients) return;

    final isLast = pageController.page.toInt() == doodles.length - 1;
    if (isLast) {
      return widget.onFinish();
    }

    pageController.nextPage(
        duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
//    if (!pageController.hasClients) return;
    print('next or finish');
    if (_debounce?.isActive ?? false) _debounce.cancel();
//
    _debounce = Timer(const Duration(milliseconds: 3500), () => _nextDoodle());
//
//    _debounce = Timer(const Duration(milliseconds: 2500), () => _nextDoodle());
//    return;

//    if (pageController.hasClients)
//      pageController.nextPage(
//          duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
  }

  void _previousDoodle() {
    if (pageController.hasClients)
      pageController.previousPage(
          duration: Duration(milliseconds: 1), curve: Curves.easeInOut);

//    if (_debounce?.isActive ?? false) _debounce.cancel();

//    _debounce = Timer(const Duration(milliseconds: 3500), () => _nextDoodle());
    return;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    doodles = widget.doodles;

    _images = doodles
        .map((d) => Image.network(d.url)
          ..image
              .resolve(ImageConfiguration())
              .addListener(imageStreamListener()))
        .toList();

//    _image = Image.network(widget.doodles.first.url)
//      ..image.resolve(ImageConfiguration()).addListener(imageStreamListener());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        itemCount: doodles.length,
        onPageChanged: (page) {
          print('page: $page');
          setState(() {
            currentPage = page;
          });
          return;
        },
        itemBuilder: (context, index) {
          final doodle = doodles[index];
          return (!doodles.first.isLoaded)
              ? LoadingIndicator()
              : Stack(
                  children: <Widget>[
                    ///Doodle image
                    Positioned.fill(
                      child: DoodleImage(doodle: doodle),
                    ),
                    Positioned.fill(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  _headerIsVisible = false;
                                });
                                if (_debounce?.isActive ?? false)
                                  _debounce.cancel();
                              },
                              onLongPressUp: () {
                                setState(() {
                                  _headerIsVisible = true;
                                });
                                _debounce = Timer(
                                    const Duration(milliseconds: 2500),
                                    () => _nextDoodle());
                              },
                              onTap: _previousDoodle,
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
                              },
                              onLongPressUp: () {
                                setState(() {
                                  _headerIsVisible = true;
                                });
                                _debounce = Timer(
                                    const Duration(milliseconds: 2500),
                                    () => _nextDoodle());
                              },
                              onTap: _nextDoodle,
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
//                    if (_headerIsVisible)
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
                            onTap: () => Navigator.push(
                                context, ProfileScreen.route(doodle.owner.uid)),
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
                                    url: doodle.owner.urls.small,
                                  ),
//                              child: CircleAvatar(
//                                backgroundImage: CachedNetworkImageProvider(
//                                  doodle.owner.urls.small,
//                                ),
//                              ),
                                ),
                                Text(
                                  doodle.owner.username,
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
                );
        });
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
