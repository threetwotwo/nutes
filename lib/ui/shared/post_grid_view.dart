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
    return GridView.builder(
      itemCount: posts.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
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
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
//                    border: Border.all(color: Colors.grey[50]),
                  ),
                  child: Image.network(
                    ///show the first image if post has multiple images
                    post.urlBundles.first.medium,
                    fit: BoxFit.fitWidth,
                  ),
                ),
        );
      },
    );
  }
}
