import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:nutes/utils/page_indicator.dart';

class DotsIndicator extends StatelessWidget {
  final PreloadPageController preloadController;
  final length;
  final color;
  const DotsIndicator({
    Key key,
    this.preloadController,
    @required this.length,
    this.color = Colors.grey,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Visibility(
      ///only visible if multiple pages
      visible: length > 1,
      child: PageIndicator(
        color: color.withOpacity(0.5),
        activeColor: Colors.black.withOpacity(0.9),
        layout: PageIndicatorLayout.WARM,
        size: 6.0,
        preloadController: preloadController,
        space: 4.0,
        count: length,
      ),
    );
  }
}
