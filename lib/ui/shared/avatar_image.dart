import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/profile_header.dart';

class AvatarImage extends StatelessWidget {
  final String url;

  ///spacing between story ring and avatar
  final double spacing;

  ///width of story ring
  final double ringWidth;

  final double addStoryIndicatorSize;

  ///has story
//  final bool showStoryIndicator;

  final StoryState storyState;

  final Function onTap;

  final bool addStory;
  final double padding;
  final bool bordered;

  const AvatarImage({
    Key key,
    @required this.url,
    this.spacing = 2,
    this.addStoryIndicatorSize = 8,
//    this.showStoryIndicator = false,
    this.addStory = false,
    this.onTap,
    this.padding = 8,
    this.bordered = true,
    this.storyState = StoryState.none,
    this.ringWidth = 2,
//    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double outerPadding = spacing;
    final double innerPadding = outerPadding * 2;

    return Transform.rotate(
      angle: -0.8,
      child: Container(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
//              storyState == StoryState.none
//                  ? Positioned.fill(
//                      child: Padding(
//                      padding: EdgeInsets.all(padding),
//                      child: Container(),
//                    ))
//                  : SizedBox(),
              if (storyState == StoryState.loading)
                Positioned.fill(
                    child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    valueColor: AlwaysStoppedAnimation(Colors.grey[400]),
                  ),
                )),
              if (storyState == StoryState.seen)
                Positioned.fill(
                    child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.grey[300], width: ringWidth / 2),
                      shape: BoxShape.circle,
                    ),
                  ),
                )),
              if (storyState == StoryState.unseen)
                Positioned.fill(
                    child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: CircleStoryGradient(),
                )),
              Padding(
                padding: EdgeInsets.all(ringWidth + padding),
                child: CircleSpacer(
                  color: storyState == StoryState.unseen
                      ? Colors.white
                      : Colors.transparent,
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(innerPadding + padding),
                  child: PhotoImage(
                    bordered: bordered,
                    url: url ?? '',
                    onTap: onTap,
                  )),

              ///AddStory Indicator
              if (addStory)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: onTap,
                    child: AddStoryIndicator(
                      size: addStoryIndicatorSize,
                      spacing: spacing,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhotoImage extends StatelessWidget {
  final Function onTap;
  final bool bordered;

  const PhotoImage({
    Key key,
    @required this.url,
    this.onTap,
    this.bordered = true,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Transform.rotate(
          angle: 0.8,
          child: Container(
            decoration: BoxDecoration(
              border: bordered
                  ? Border.all(color: Colors.grey[200], width: 1)
                  : null,
              borderRadius: BorderRadius.circular(1000),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: Container(
//                color: Colors.grey[200],
                child: url.isEmpty
                    ?
//                Center(
//                        child: Icon(
//                          Icons.person,
//                          color: Colors.white,
//                        ),
//                      )
                    Transform.scale(
                        scale: 1,
                        child: Image.asset(
                          'assets/images/profile.png',
                          fit: BoxFit.cover,
                        ))
                    : CachedNetworkImage(
                        placeholder: (context, _) => Container(
                          color: Colors.grey[200],
                        ),
                        errorWidget: (_, __, ___) => Transform.scale(
                            scale: 0.65,
                            child: Image.asset(
                              'assets/images/profile.png',
                              fit: BoxFit.cover,
                            )),
                        imageUrl: url,
                        fit: BoxFit.cover,
                      ),
//                FadeInImage(
//                        placeholder: MemoryImage(kTransparentImage),
//                        image: NetworkImage(url),
//                        fit: BoxFit.cover,
//                      ),
              ),
            ),
//                CachedNetworkImage(
//                        imageUrl: url,
//                        placeholder: (context, _) => Container(
//                          color: Colors.grey[200],
//                        ),
//                        errorWidget: (context, url, obj) => Transform.scale(
//                          scale: 0.65,
//                          child: Image.asset(
//                            'assets/images/avatar.png',
//                            fit: BoxFit.cover,
//                          ),
//                        ),
//                      )),
          ),
        ),
      ),
    );
  }
}

class CircleStoryGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(900),
      child: Container(
        decoration: BoxDecoration(gradient: GradientStyles.alihussein),
      ),
    );
  }
}

class CircleSpacer extends StatelessWidget {
  final Color color;

  const CircleSpacer({Key key, this.color = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10000),
      child: Container(
        color: color,
      ),
    );
  }
}

class AddStoryIndicator extends StatelessWidget {
  final double size;
  final double paddingFactor;
  final double spacing;
  const AddStoryIndicator({
    Key key,
    @required this.size,
    this.paddingFactor = 1,
    @required this.spacing,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.8,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(999)),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.blue,
          radius: size,
          child: Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: size * 1.7,
            ),
          ),
        ),
      ),
    );
  }
}
