import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';

class RefreshListView extends StatefulWidget {
  final ScrollController controller;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final List<Widget> children;
  final ScrollPhysics physics;

  const RefreshListView(
      {Key key,
      this.controller,
      this.onRefresh,
      this.children,
      this.onLoadMore,
      this.physics})
      : super(key: key);

  @override
  _RefreshListViewState createState() => _RefreshListViewState();
}

class _RefreshListViewState extends State<RefreshListView> {
  bool isLoadingMore = false;
  ScrollController _controller;

  _loadMore() async {
    if (widget.onLoadMore == null) return;

    if (mounted)
      setState(() {
        isLoadingMore = true;
      });

    if (widget.onLoadMore != null) {
      await widget.onLoadMore();
      isLoadingMore = false;

      if (mounted) setState(() {});
    }

    return;
  }

  @override
  void initState() {
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(() {
      if (widget.onLoadMore == null) return;
      if (!isLoadingMore &&
          _controller.position.pixels >= _controller.position.maxScrollExtent) {
        print('load more');
        _loadMore();

        if (mounted) setState(() {});

        Future.delayed(Duration(seconds: 15))
          ..whenComplete(() {
            isLoadingMore = false;

            if (mounted) setState(() {});
          });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _controller,
      physics: widget.physics ?? Platform.isAndroid
          ? BouncingScrollPhysics()
          : AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverRefreshControl(
          refreshIndicatorExtent: 80,
          refreshTriggerPullDistance: 120,
          onRefresh: widget.onRefresh,
          builder: (context, mode, _, __, ___) => Padding(
            padding: const EdgeInsets.all(20.0),
            child: CupertinoActivityIndicator(
              radius: 12,
            ),
          ),
        ),
        ...widget.children.map((child) => SliverToBoxAdapter(
              child: child,
            )),
        if (isLoadingMore)
          SliverToBoxAdapter(
            child: LoadingIndicator(),
          )
      ],
    );
  }
}
