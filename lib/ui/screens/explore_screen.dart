import 'package:flutter/material.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nutes/ui/screens/post_detail_screen.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/shout_grid_item.dart';
import 'package:nutes/ui/shared/shout_post.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExploreScreen extends StatefulWidget {
  final void Function(int) onTab;

  const ExploreScreen({Key key, this.onTab}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  List<Post> trendingPosts = [];
  List<Post> newestPosts = [];

  DocumentSnapshot newestLastDoc;
  DocumentSnapshot trendingLastDoc;

  final cache = LocalCache.instance;

  Future _getTrendingPosts() async {
    ///Clear posts if cursor is null
    if (trendingLastDoc == null) trendingPosts.clear();

    print('get trending posts');
    final result = await Repo.getTrendingPosts(trendingLastDoc);

    if (result.posts.isNotEmpty && mounted)
      setState(() {
        trendingPosts.addAll(result.posts);
      });

    trendingLastDoc = result.startAfter;
  }

  Future _getNewestPosts() async {
    ///Clear posts if cursor is null
    if (newestLastDoc == null) newestPosts.clear();

    print('get newest posts');
    final result = await Repo.getNewestPosts(newestLastDoc);

    if (result.posts.isNotEmpty && mounted)
      setState(() {
        newestPosts.addAll(result.posts);
      });

    newestLastDoc = result.startAfter;
  }

  @override
  void initState() {
    _getTrendingPosts();
    _getNewestPosts();
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
            onTap: (idx) => widget.onTab(idx),
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
                  controller: cache.searchPopularScrollController,
                  posts: trendingPosts,
                  onRefresh: () {
                    trendingLastDoc = null;
                    return _getTrendingPosts();
                  },
                  onLoadMore: _getTrendingPosts,
                ),
                ExploreTabView(
                  controller: cache.searchSubmittedScrollController,
                  posts: newestPosts,
                  onRefresh: () {
                    newestLastDoc = null;
                    return _getNewestPosts();
                  },
                  onLoadMore: _getNewestPosts,
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
