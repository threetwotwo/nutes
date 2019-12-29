import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/dots_indicator.dart';
import 'package:nutes/ui/shared/page_viewer.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/image_file_bundle.dart';

class ConfirmUploadPage extends StatelessWidget {
  final bool enableStory;
  final List<ImageFileBundle> fileBundles;
  final _controller = PreloadPageController();

  final captionController = TextEditingController();

  ConfirmUploadPage({
    Key key,
    this.fileBundles,
    this.enableStory = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final aspectRatios = fileBundles.map((b) => b.aspectRatio).toList();
    final biggestAspectRatio = aspectRatios.reduce(min);
    final auth = Auth.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context)),
//        trailing: IconButton(
//            icon: Icon(
//              Icons.more_horiz,
//              color: Colors.black,
//            ),
//            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst)),
        title: Text(
          'Share',
          style: TextStyles.w600Text,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
//          physics: ClampingScrollPhysics(),
          child: Column(
            children: <Widget>[
              AspectRatio(
                  aspectRatio: biggestAspectRatio ?? 1,
                  child: PageViewer(
                    controller: _controller,
                    length: fileBundles.length,
                    builder: (context, index) {
                      return Image.file(
                        fileBundles[index].medium,
                        fit: BoxFit.cover,
                      );
                    },
                  )),
              if (fileBundles.length > 1)
                Container(
                  height: 40,
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Container(),
                      ),
                      DotsIndicator(
                        preloadController: _controller,
                        length: fileBundles.length,
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              if (enableStory) ...[
                Container(height: 1, color: Colors.grey[100]),
                AvatarListItem(
                  avatar: AvatarImage(
                    url: auth.profile.user.urls.small,
                    spacing: 0,
                    padding: 10,
                    addStoryIndicatorSize: null,
                  ),
                  trailingFlexFactor: 2,
                  onTrailingWidgetPressed: () => print('hey'),
                  title: 'Your Story',
                  trailingWidget: Padding(
                    padding: const EdgeInsets.all(8),
                    child: RaisedButton(
                      onPressed: () async {
                        print('posting to story');

                        Repo.uploadStory(fileBundle: fileBundles.first);

                        return Navigator.pop(context, true);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      padding: const EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: GradientStyles.alihusseinButton,
                          borderRadius: BorderRadius.all(Radius.circular(80.0)),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Story',
                            style: TextStyles.w600Text
                                .copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
//                    child: Container(
//                      width: double.infinity,
//                      height: double.infinity,
//                      child: Center(
//                        child: Text(
//                          'Story',
//                          style: TextStyles.W500Text15.copyWith(
//                              color: Colors.white),
//                        ),
//                      ),
//                      decoration: BoxDecoration(
//                          gradient: GradientStyles.alihusseinButton),
////                      color: Colors.redAccent[400],
//                    ),
                  ),
                ),
              ],
              Container(height: 1, color: Colors.grey[100]),
              TextField(
                controller: captionController,
                style: TextStyles.defaultText.copyWith(fontSize: 15),
                maxLines: 4,
                minLines: 1,
                maxLength: 2000,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Write a post caption...',
                ),
              ),
              AvatarListItem(
                avatar: AvatarImage(
                  url: auth.profile.user.urls.small,
                  spacing: 0,
                  padding: 10,
                  addStoryIndicatorSize: null,
                ),
                title: 'Your Post',
                trailingFlexFactor: 2,
                trailingWidget: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () {
                      print('pressed share to post');
                      Repo.uploadPost(
                        type: PostType.text,
                        fileBundles: fileBundles,
                        isPrivate: auth.profile.user.isPrivate,
                        caption: captionController.text,
                      );
                      Navigator.popUntil(context, (r) => r.isFirst);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0)),
                    padding: const EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: GradientStyles.blue,
                        borderRadius: BorderRadius.all(Radius.circular(80.0)),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Share',
                          style:
                              TextStyles.w600Text.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
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
