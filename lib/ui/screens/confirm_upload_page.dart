import 'package:flutter/material.dart';
import 'package:nutes/core/services/local_cache.dart';
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
  final cache = LocalCache.instance;

  final captionController = TextEditingController();

  ConfirmUploadPage({Key key, this.fileBundles, this.enableStory = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context)),
        trailing: IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: Colors.black,
            ),
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst)),
        title: Text(
          'Share',
          style: TextStyles.W500Text15,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
//          physics: ClampingScrollPhysics(),
          child: Column(
            children: <Widget>[
              AspectRatio(
                  aspectRatio: fileBundles.first.aspectRatio ?? 1,
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
              if (enableStory)
                AvatarListItem(
                  avatar: AvatarImage(
                    url: Repo.currentProfile.user.photoUrl,
                    spacing: 0,
                    addStoryIndicatorSize: null,
                  ),
                  onTrailingWidgetPressed: () => print('hey'),
                  title: 'Your Story',
                  trailingWidget: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      onPressed: () {
                        print('posting to story');
                        Repo.uploadStory(fileBundle: fileBundles.first);

                        Navigator.popUntil(context, (r) => r.isFirst);

                        cache.animateTo(1);
                      },
                      child: Text(
                        'Story',
                        style:
                            TextStyles.W500Text15.copyWith(color: Colors.white),
                      ),
                      color: Colors.redAccent[400],
                    ),
                  ),
                ),
              Container(
//                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: captionController,
                  style: TextStyles.defaultText.copyWith(fontSize: 15),
                  maxLines: 5,
                  minLines: 1,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Write a caption...',
                  ),
                ),
              ),
              AvatarListItem(
                avatar: AvatarImage(
                  url: Repo.currentProfile.user.photoUrl,
                  spacing: 0,
                  addStoryIndicatorSize: null,
                ),
                title: 'Your Post',
                trailingWidget: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    onPressed: () {
                      print('pressed share to post');
                      Repo.uploadPost(
                        type: PostType.text,
                        fileBundles: fileBundles,
                        isPrivate: Repo.currentProfile.user.isPrivate,
                        caption: captionController.text,
                      );
                      Navigator.popUntil(context, (r) => r.isFirst);
                    },
                    child: Text(
                      'Share',
                      style:
                          TextStyles.W500Text15.copyWith(color: Colors.white),
                    ),
                    color: Colors.blue,
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
