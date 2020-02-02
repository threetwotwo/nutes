import 'package:flutter/material.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/buttons.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/icon_shadow.dart';

class MomentView extends StatefulWidget {
//  final String url;
  final VoidCallback onLoad;
  final VoidCallback onError;
//  final bool isOwner;
  final Moment moment;
  final User uploader;
  final bool isFooterVisible;

  final VoidCallback onDeleteTapped;
  final VoidCallback onSeenByTapped;

  const MomentView({
    Key key,
//    this.url,
    this.onLoad,
//    this.isOwner = false,
    this.moment,
    this.uploader,
    this.onError,
    this.isFooterVisible = true,
    this.onDeleteTapped,
    this.onSeenByTapped,
  }) : super(key: key);

  @override
  _MomentViewState createState() => _MomentViewState();
}

class _MomentViewState extends State<MomentView> {
  List<User> seenBy = [];

  var isOwner = false;

  Image _image;

  ImageStreamListener imageStreamListener() =>
      ImageStreamListener((info, call) async {
        if (info != null && mounted) {
          print('moment loaded');

          widget.onLoad();
        }
      }, onError: (_, __) {
        print('error loading moment');

        setState(() {});
        return widget.onError();
      });

  Future<void> _getSeenBy() async {
    final owner = widget.uploader.uid;

    final result = await Repo.getMomentSeenBy(owner, widget.moment.id);

    setState(() {
      seenBy = result;
    });
  }

  @override
  void initState() {
    print(
        '*** init moment view ${widget.moment.id} belonging to ${widget.uploader.uid}');

    _image = Image.network(
      widget.moment.url,
      fit: BoxFit.cover,
//      cacheWidth: 640,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          Repo.setMomentAsSeen(widget.uploader.uid, widget.moment.id);

          return child;
        }

        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
            value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes,
          ),
        );
      },
    )..image.resolve(ImageConfiguration()).addListener(imageStreamListener());

    setState(() {
      isOwner = FirestoreService.ath.uid == widget.uploader.uid;
      if (isOwner) _getSeenBy();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: _image),

        ///footer
        if (isOwner && seenBy.isNotEmpty && widget.isFooterVisible)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomLeft,
              height: 128,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
//                          Colors.black.withOpacity(0.04),
                    Colors.black.withOpacity(0.04),
                  ],
                  stops: [0.06, 0.86],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Container(
//                color: Colors.green,
                height: 64,
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, top: 16, bottom: 16),
                      child: Text(
                        'seen by ${seenBy.length}',
                        style: TextStyles.w500Text.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
//                        color: Colors.blue.withOpacity(0.32),
                        height: 48,
                        child: Stack(
                          children: List<Widget>.generate(
                            seenBy.length,
                            (idx) => Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: idx * 16.0,
                                ),
                                child: AvatarImage(
                                  url: seenBy[idx].urls.small,
                                  spacing: 4,
                                  padding: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        print('delete this story');
                        return widget.onDeleteTapped();
                      },
                      child: Text(
                        'Delete',
                        style: TextStyles.w500Text.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
