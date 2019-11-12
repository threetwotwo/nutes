import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';

class PageViewer extends StatelessWidget {
  final int length;
  final PreloadPageController controller;
  final Widget Function(BuildContext context, int index) builder;
  final Function(int) onPageChanged;

  const PageViewer(
      {Key key,
      @required this.length,
      @required this.controller,
      this.builder,
      this.onPageChanged})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PreloadPageView.builder(
      ///Call on null error
      onPageChanged:
          onPageChanged == null ? null : (value) => onPageChanged(value),
      preloadPagesCount: 2,
      itemCount: length,
      physics: length > 1
          ? AlwaysScrollableScrollPhysics()
          : ClampingScrollPhysics(),
      controller: controller,
      itemBuilder: builder,
    );
  }
}
