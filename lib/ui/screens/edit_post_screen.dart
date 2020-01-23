import 'package:flutter/material.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/dots_indicator.dart';
import 'package:nutes/ui/shared/page_viewer.dart';
import 'package:nutes/ui/shared/search_overlay.dart';
import 'package:nutes/ui/shared/shout_post.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:preload_page_view/preload_page_view.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;
  static Route route(Post post) => MaterialPageRoute(
      builder: (context) => EditPostScreen(
            post: post,
          ));
  const EditPostScreen({Key key, this.post}) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _pageController = PreloadPageController();
  final _textController = TextEditingController();
  final _textScrollController = ScrollController();

  @override
  void initState() {
    _textController.text = widget.post.caption;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_textScrollController.hasClients)
      _textScrollController
          .jumpTo(_textScrollController.position.maxScrollExtent);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final isShout = widget.post.type == PostType.shout;

    return Scaffold(
      appBar: BaseAppBar(
        ///Hide leading
        automaticallyImplyLeading: false,
        title: Row(
          children: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyles.defaultText,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Edit post',
                  style: TextStyles.defaultText,
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                print('done pressed');
                final updatedPost =
                    widget.post.copyWith(caption: _textController.text);
                Repo.updatePost(post: updatedPost);

                return Navigator.pop(context, updatedPost);
              },
              child: Text(
                'Done',
                style: TextStyles.defaultText,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SearchOverlay(
            onScroll: () {},
            controller: _textController,
            child: Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  isShout
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              GridShoutBubble(
                                data: widget.post.metadata,
                                isChallenger: true,
                              ),
                              GridShoutBubble(
                                data: widget.post.metadata,
                                isChallenger: false,
                              )
                            ],
                          ),
                        )
                      : AspectRatio(
                          aspectRatio:
                              widget.post.urlBundles?.first?.aspectRatio ?? 1,
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: PageViewer(
                                  controller: _pageController,
                                  builder: (context, index) => Image.network(
                                    widget.post.urlBundles[index].original,
                                    fit: BoxFit.cover,
                                  ),
//                                CachedNetworkImage(
//                              imageUrl: widget.post.urlBundles[index].original,
//                              fit: BoxFit.cover,
//                            ),
                                  length: widget.post.urlBundles.length,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  margin: const EdgeInsets.all(8.0),
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                  if (widget.post.type == PostType.text &&
                      widget.post.urlBundles.length > 1)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DotsIndicator(
                        preloadController: _pageController,
                        length: widget.post.urlBundles.length,
                      ),
                    ),
                  Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      scrollController: _textScrollController,
                      keyboardType: TextInputType.emailAddress,
                      controller: _textController,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 2000,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        hintText: 'Add a caption',
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
