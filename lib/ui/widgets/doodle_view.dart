import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutes/core/models/doodle.dart';
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
  Image _image;

  bool isLoaded = false;

  List<Image> _images;

  final pageController = PageController();

  Timer _debounce;

  int currentPage = 0;

  ImageStreamListener imageStreamListener() =>
      ImageStreamListener((info, call) async {
        print(info);
        print(call);
        if (info != null && mounted) {
          print('doodle loaded');
          setState(() {
            isLoaded = true;
          });

          if (_debounce?.isActive ?? false) _debounce.cancel();

          _debounce =
              Timer(const Duration(milliseconds: 2500), () => _nextDoodle());
        }
      }, onError: (_, __) {
        print('error loading doodle');

        return widget.onError;
      });

  void _nextDoodle() async {
    if (!pageController.hasClients) return;

    final isLast = pageController.page.toInt() == widget.doodles.length - 1;
    if (isLast) {
      return widget.onFinish();
    }
    pageController.nextPage(
        duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
//    if (!pageController.hasClients) return;
    print('next or finish');
    if (_debounce?.isActive ?? false) _debounce.cancel();
//
    _debounce = Timer(const Duration(milliseconds: 2500), () => _nextDoodle());
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

    if (_debounce?.isActive ?? false) _debounce.cancel();

//    _debounce = Timer(const Duration(milliseconds: 2500), () => _nextDoodle());

    _debounce = Timer(const Duration(milliseconds: 2500), () => _nextDoodle());
    return;

//    if (_debounce?.isActive ?? false) _debounce.cancel();
//    _debounce =
//        Timer(const Duration(milliseconds: 2500), () => _nextDoodleOrFinish());
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    _images = widget.doodles
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
    return !isLoaded
        ? LoadingIndicator()
        : PageView.builder(
            physics: NeverScrollableScrollPhysics(),
            controller: pageController,
            itemCount: widget.doodles.length,
            onPageChanged: (page) async {
              final isLast = page == widget.doodles.length - 1;

              if (isLast)
                _debounce = Timer(const Duration(milliseconds: 2500),
                    () => widget.onFinish());
              setState(() {
                currentPage = page;
              });
              return;
            },
            itemBuilder: (context, index) {
              final doodle = widget.doodles[index];
              return Stack(
                children: <Widget>[
                  ///Doodle image
                  Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: _debounce.isActive ? 1 : 0,
                      duration: Duration(milliseconds: 400),
                      child: Image.network(
                        doodle.url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) {
                            return child;
                          }

                          if (progress.cumulativeBytesLoaded ==
                              progress.expectedTotalBytes) {
                            print('doodle load complete');
                          }
                          return SizedBox();
                        },
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: _previousDoodle,
                            child: Container(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: GestureDetector(
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
                  Align(
                    alignment: Alignment.topCenter,
                    child: Visibility(
                      visible: isLoaded,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        margin: const EdgeInsets.all(4),
                        decoration: ShapeDecoration(
                          shape: StadiumBorder(),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              height: 22,
                              width: 22,
                              margin: const EdgeInsets.all(4.0),
                              child: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  doodle.owner.urls.small,
                                ),
                              ),
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
                ],
              );
            });
  }
}
