import 'package:flutter/material.dart';
import 'package:nutes/core/models/filter.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/utils/screenshot.dart';

///maintains a bundle of [CaptureController]s
///and return a list of [CapturePage]s
class CaptureBundle {
  List<CaptureController> controllers;

  CaptureBundle({Key key, this.controllers});
}

///contains a [FocusNode], [ScreenshotController] and a [TextEditingController]
class CaptureController {
  final FocusNode focusNode = FocusNode();
  final ScreenshotController screenshotController = ScreenshotController();
  final TextEditingController textController = TextEditingController();
}

class CapturePage extends StatelessWidget {
  final Filter filter;
  final CaptureController controller;

  CapturePage({
    Key key,
    @required this.controller,
//      @required this.filterType,
    @required this.filter,
//    this.variantIdx = 0,
  }) : super(key: key);

  CapturePage copyWith({Filter filter}) {
    return CapturePage(
      controller: this.controller,
      filter: filter ?? this.filter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final variant = filter.variants[filter.variantIndex];

    return Center(
        child: GestureDetector(
      onTap: () {
        print('tap to focus');
        return FocusScope.of(context).requestFocus(controller.focusNode);
      },
      child: Screenshot(
        controller: controller.screenshotController,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: variant.bgDecor,
          child: Center(
            child: NotificationListener(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is ScrollUpdateNotification) {
                  if (scrollInfo.dragDetails != null &&
                      scrollInfo.dragDetails.primaryDelta >= 15.0) {
                    print('hide keyboard');
                    FocusScope.of(context).requestFocus(FocusNode());
                  }
                }
                return true;
              },
              child: CapturePageBody(
                filter: filter,
                controller: controller,
                focusNode: controller.focusNode,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class CapturePageBody extends StatelessWidget {
  final Filter filter;
  final CaptureController controller;
  final FocusNode focusNode;

  final auth = Auth.instance;

  CapturePageBody({
    Key key,
    @required this.filter,
    @required this.controller,
    this.focusNode,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    switch (filter.type) {
      case FilterType.urban:
      case FilterType.canvas:
        return CapturePageTextField(
          filter: filter,
          focusNode: focusNode,
          controller: controller,
        );
      case FilterType.frame:
        return AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            margin: const EdgeInsets.all(40),
            decoration: filter.variant.fgDecor,
            child: CapturePageTextField(
              filter: filter,
              focusNode: focusNode,
              controller: controller,
            ),
          ),
        );
      case FilterType.ego:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AvatarListItem(
                avatar: AvatarImage(
                  url: Auth.instance.profile.user.urls.small,
                ),
                title: auth.profile.user.displayName,
                subtitle: '@${auth.profile.user.username}',
                trailingWidget: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: filter.variant.fgDecor,
                child: CapturePageTextField(
                  filter: filter,
                  focusNode: focusNode,
                  controller: controller,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        );
    }
  }
}

class CapturePageTextField extends StatelessWidget {
  final TextAlign textAlign;
  final Filter filter;
  final FocusNode focusNode;
  final CaptureController controller;

  const CapturePageTextField({
    Key key,
    this.textAlign = TextAlign.center,
    @required this.focusNode,
    @required this.controller,
    @required this.filter,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextField(
        ///to help focus on the text field when
        ///there are little or no text available
        focusNode: focusNode,
        controller: controller.textController,
        maxLength: 2500,
        maxLines: null,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Text',
          hintStyle: filter.variants[filter.variantIndex].textStyle.copyWith(
              color: filter.variants[filter.variantIndex].textStyle.color
                  .withOpacity(0.4)),
          border: InputBorder.none,
          counterText: '',
        ),
        textAlign: textAlign,
        cursorColor: Colors.blueGrey,
        style: filter.variants[filter.variantIndex].textStyle,
      ),
    );
  }
}
