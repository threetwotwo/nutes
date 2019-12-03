import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/dots_indicator.dart';
import 'package:nutes/ui/shared/page_viewer.dart';
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

  @override
  void initState() {
    _textController.text = widget.post.caption;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

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
              onPressed: () {print('done pressed');},
              child: Text(
                'Done',
                style: TextStyles.defaultText,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: widget.post.urls.first.aspectRatio,
                child: PageViewer(
                  controller: _pageController,
                  builder: (context, index) => Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: widget.post.urls[index].original,
                          fit: BoxFit.cover,
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
                            Icons.delete,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                  length: widget.post.urls.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DotsIndicator(
                  preloadController: _pageController,
                  length: widget.post.urls.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _textController,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText: 'Write a caption',
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
