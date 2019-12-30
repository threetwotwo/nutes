import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/post_grid_view.dart';
import 'package:nutes/ui/shared/shout_post.dart';

class ChatPostContent extends StatelessWidget {
  final Map data;

  const ChatPostContent({Key key, this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    switch (data['type']) {
      case 'text':
        return AspectRatio(
          aspectRatio: data['urls'][0]['aspect_ratio'] ?? 1,
          child: CachedNetworkImage(
            imageUrl: data['urls'][0]['small'],
            placeholder: (_, __) => Container(
              color: Colors.grey[200],
            ),
            fit: BoxFit.cover,
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              GridShoutBubble(
                data: data['metadata'],
                isChallenger: true,
                avatarSize: 28,
              ),
              SizedBox(height: 8),
              GridShoutBubble(
                data: data['metadata'],
                isChallenger: false,
                avatarSize: 28,
              ),
            ],
          ),
        );
    }
  }
}
