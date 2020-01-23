import 'package:flutter/material.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/post_type.dart';
//import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nutes/ui/screens/post_detail_screen.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/shout_grid_item.dart';
//import 'package:nutes/ui/shared/shout_post.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExploreScreen extends StatefulWidget {
  final void Function(int) onTab;
  final ScrollController popularSearchController;
  final ScrollController newestSearchController;

  const ExploreScreen(
      {Key key,
      this.onTab,
      this.popularSearchController,
      this.newestSearchController})
      : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  List<Post> trendingPosts = [];
  List<Post> newestPosts = [];

  DocumentSnapshot newestLastDoc;
  DocumentSnapshot trendingLastDoc;

  List blockedBy = [];

//  final cache = LocalCache.instance;

  Future _getInitialTrending() async {
    await _getBlockedBy();
    print('get init trending posts');
    final result = await Repo.getTrendingPosts(null);

//    print('trending initial: ${result.posts.length}');

    if (result.posts.isNotEmpty && mounted)
      setState(() {
        trendingPosts = result.posts
          ..removeWhere((p) => blockedBy.contains(p.owner.uid));
        trendingLastDoc = result.startAfter;
      });
  }

  Future _getMoreTrending() async {
    print('get more trending posts');
    final result = await Repo.getTrendingPosts(trendingLastDoc);

//    print('trending initial: ${result.posts.length}');

    if (result.posts.isNotEmpty && mounted)
      setState(() {
        trendingPosts.addAll(
            result.posts..removeWhere((p) => blockedBy.contains(p.owner.uid)));
        trendingLastDoc = result.startAfter;
      });
  }

  Future _getInitialNewest() async {
    await _getBlockedBy();
    print('get newest posts');
    final result = await Repo.getNewestPosts(null);

    if (result.posts.isNotEmpty && mounted)
      setState(() {
        newestPosts = result.posts
          ..removeWhere((p) => blockedBy.contains(p.owner.uid));

        newestLastDoc = result.startAfter;
      });
  }

  Future _getMoreNewest() async {
    print('get more newest posts');
    final result = await Repo.getNewestPosts(newestLastDoc);

    if (result.posts.isNotEmpty && mounted)
      setState(() {
        newestPosts.addAll(
            result.posts..removeWhere((p) => blockedBy.contains(p.owner.uid)));
        newestLastDoc = result.startAfter;
      });
  }

  _getBlockedBy() async {
    final result = await Repo.getBlockedBy();

    if (mounted)
      setState(() {
        blockedBy = result;
      });

    print('blocked by: $result');
  }

  @override
  void initState() {
    _getInitialTrending();
    _getInitialNewest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          TabBar(
            onTap: (idx) {
              print('on explore tap $idx');
              return widget.onTab(idx);
            },
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            labelStyle: TextStyles.w600Text,
            unselectedLabelStyle:
                TextStyles.w300Text.copyWith(color: Colors.grey[300]),
            tabs: [
              Tab(text: 'Most Popular'),
              Tab(text: 'User Submitted'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ExploreTabView(
                  controller: widget.popularSearchController,
                  posts: trendingPosts,
                  onRefresh: _getInitialTrending,
                  onLoadMore: _getMoreTrending,
                ),
                ExploreTabView(
                  controller: widget.newestSearchController,
                  posts: newestPosts,
                  onRefresh: _getInitialNewest,
                  onLoadMore: _getMoreNewest,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ExploreTabView extends StatefulWidget {
  final List<Post> posts;
  final Future<PostCursor> getPosts;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final ScrollController controller;

  const ExploreTabView(
      {Key key,
      this.getPosts,
      this.onLoadMore,
      this.posts,
      this.onRefresh,
      this.controller})
      : super(key: key);

  @override
  _ExploreTabViewState createState() => _ExploreTabViewState();
}

class _ExploreTabViewState extends State<ExploreTabView>
    with AutomaticKeepAliveClientMixin {
//  List<Post> posts;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
//    posts = widget.posts;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshListView(
      onRefresh: widget.onRefresh,
      onLoadMore: widget.onLoadMore,
      controller: widget.controller,
      children: <Widget>[
        widget.posts == null
            ? SizedBox()
            : StaggeredGridView.countBuilder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                mainAxisSpacing: 1,
                itemCount: widget.posts.length,
                crossAxisCount: 2,
                itemBuilder: (context, index) {
                  final post = widget.posts[index];

                  return GestureDetector(
                    onTap: () =>
                        Navigator.push(context, PostDetailScreen.route(post)),
                    child: Container(
//                      color: Colors.grey[200],
                      child: post.type == PostType.shout
                          ? Center(
                              child: ShoutGridItem(
                                metadata: post.metadata,
                              ),
                            )
                          : Image.network(
                              widget.posts[index].urlBundles.first.medium,
                              fit: BoxFit.cover,
                            ),
//                      CachedNetworkImage(
//                              imageUrl: posts[index].urlBundles.first.medium,
//                              fit: BoxFit.cover,
//                            ),
                    ),
                  );
                },
                staggeredTileBuilder: (index) => StaggeredTile.extent(
                    1, widget.posts[index].type == PostType.shout ? 200 : 200)),
      ],
    );
  }
}
