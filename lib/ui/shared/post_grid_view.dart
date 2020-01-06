import 'package:cached_network_image/cached_network_image.dart';
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
              ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Center(
                    child: Wrap(
                      runSpacing: 8,
                      children: <Widget>[
                        GridShoutBubble(
                          data: post.metadata,
                          isChallenger: true,
                          avatarSize: 30,
                        ),
                        GridShoutBubble(
                          data: post.metadata,
                          isChallenger: false,
                          avatarSize: 30,
                        ),
                      ],
                    ),
                  ),
                )
              : CachedNetworkImage(
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[100],
                  ),
                  imageUrl: post.urlBundles.first.medium,
                ),
        );
      },
    );
  }
}
