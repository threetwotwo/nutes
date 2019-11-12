import 'package:flutter/material.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/ui/shared/shout_post.dart';

class PostGridView extends StatelessWidget {
  final void Function(int) onTap;
  final List<Post> posts;

  const PostGridView({
    Key key,
    @required this.posts,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: posts.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final post = posts[index];

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(index),
            child: post.type == PostType.shout
                ? Center(
                    child: Wrap(
                      runSpacing: 5,
                      children: <Widget>[
                        GridShoutBubble(
                          post: post,
                          isChallenger: true,
                        ),
                        GridShoutBubble(
                          post: post,
                          isChallenger: false,
                        ),
                      ],
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Image.network(
                      ///show the first image if post has multiple images
                      post.urls.first.medium,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
