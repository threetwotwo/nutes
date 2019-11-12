import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/responsive.dart';
//import 'package:extended_image/extended_image.dart';

class AvatarImage extends StatelessWidget {
  final String url;

  ///spacing between stories indicator and avatar
  final double spacing;
  final double addStoryIndicatorSize;
  final bool showStoryIndicator;

  final Function onTap;

  final bool addStory;
  final String heroTag;
  final double padding;
  final bool bordered;
  final UStoryState storyState;

  const AvatarImage({
    Key key,
    @required this.url,
    this.spacing = 1.6,
    this.addStoryIndicatorSize = 8,
    this.showStoryIndicator = false,
    this.addStory = false,
    this.onTap,
    this.heroTag,
    this.padding = 8,
    this.bordered = true,
    this.storyState = UStoryState.none,
//    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double outerPadding = screenAwareSize(spacing, context);
    final double innerPadding = outerPadding * 2;

    return Transform.rotate(
      angle: -0.8,
      child: Container(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              storyState == UStoryState.none
                  ? Positioned.fill(
                      child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Container(),
                    ))
                  : SizedBox(),
              if (showStoryIndicator)
                Positioned.fill(
                    child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: CircleStoryGradient(),
                )),
              Padding(
                padding: EdgeInsets.all(outerPadding + padding),
                child: CircleSpacer(
                  color: showStoryIndicator ? Colors.white : Colors.transparent,
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(innerPadding + padding),
                  child: PhotoImage(
                    bordered: bordered,
                    url: url ?? '',
                    onTap: onTap,
                  )),
              if (!showStoryIndicator && addStory)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AddStoryIndicator(
//                  shouldHugBorder: addStoryIndicatorShouldHugBorder,
                    size: addStoryIndicatorSize,
                    spacing: spacing,
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
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Transform.rotate(
          angle: 0.8,
          child: Container(
            decoration: BoxDecoration(
              border: bordered
                  ? Border.all(color: Colors.grey[300], width: 1)
                  : null,
              borderRadius: BorderRadius.circular(1000),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(1000),
//              child: FadeInImage(
//                fit: BoxFit.cover,
//                placeholder: AssetImage('assets/images/avatar.png'),
//                image: NetworkImage(url),
//              ),
                child: url.isEmpty
                    ? Transform.scale(
                        scale: 0.65,
                        child: Image.asset(
                          'assets/images/avatar.png',
                          fit: BoxFit.cover,
                        ))
                    : CachedNetworkImage(
                        imageUrl: url,
                        placeholder: (context, _) => Container(
                          color: Colors.grey[200],
                        ),
                        errorWidget: (context, url, obj) => Transform.scale(
                          scale: 0.65,
                          child: Image.asset(
                            'assets/images/avatar.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      )

//                child: ExtendedImage.network(
//                  url,
//                  loadStateChanged: (state) {
//                    switch (state.extendedImageLoadState) {
//                      case LoadState.loading:
//                        return Container(
//                          decoration: BoxDecoration(
//                            shape: BoxShape.circle,
//                            color: Colors.grey[300],
//                          ),
//                        );
//                      case LoadState.completed:
//                        final image = state.extendedImageInfo.image;
//                        return ExtendedRawImage(image: image);
//                      case LoadState.failed:
//                        return Transform.scale(
//                          scale: 0.7,
//                          child: Image.asset(
//                            'assets/images/avatar.png',
//                            fit: BoxFit.cover,
//                          ),
//                        );
//
//                      default:
//                        return SizedBox();
//                    }
//                  },
//                )
                ),
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
