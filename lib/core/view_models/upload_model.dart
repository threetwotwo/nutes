import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:nutes/core/models/filter.dart';
import 'package:nutes/ui/widgets/capturable_area.dart';
import 'package:nutes/ui/widgets/filter_avatar.dart';
import 'package:nutes/utils/image_file_bundle.dart';

import 'base_model.dart';

class UploadModel extends BaseModel {
  final _pageController = PreloadPageController();

  PreloadPageController get pageController => this._pageController;

  List<CapturePage> capturePages = [
    CapturePage(
        controller: CaptureController(), filter: getFilter(FilterType.canvas))
  ];

//  void changeFilter(int index, FilterType filterType) {
//    final existingController = capturePages[index].controller;
//    capturePages[index] =
//        CapturePage(controller: existingController, filterType: filterType);
//    notifyListeners();
//  }
//
//  ///Adds a new page
//  Future incrementPageCount(BuildContext context) async {
//    ///index of last page
//    final lastIndex = capturePages.length - 1;
//
//    final text = capturePages[lastIndex].controller.textController.text;
//
//    ///dont create a new page if last page is empty
//    ///max length is 7
//    if (capturePages.length > 6 || text.isEmpty) return;
//
//    ///get filter of last page
//    final lastFilter = capturePages[lastIndex].filterType;
//
//    ///create new page
//    capturePages.add(
//        CapturePage(controller: CaptureController(), filterType: lastFilter));
//    notifyListeners();
//
//    ///go to new page
//    await _pageController.animateToPage(capturePages.length - 1,
//        duration: Duration(milliseconds: 100), curve: Curves.easeOut);
//
//    ///focus on the new page
//    ///Dont user lastIndex since it is not updated
//    final node = capturePages[capturePages.length - 1].controller.focusNode;
//    FocusScope.of(context).requestFocus(node);
//  }

  ///Iterates over an array of [CaptureController]s
  ///and creates an [ImageFileBundle] for each controller
  Future<List<ImageFileBundle>> takeScreenshots() async {
    List<ImageFileBundle> bundles = [];

    setState(ViewState.Busy);

    for (var i = 0; i < capturePages.length; i++) {
      await _pageController.animateToPage(
        i,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
      final bundle = await capturePages[i]
          .controller
          .screenshotController
          .capture(index: i, pixelRatio: 5);

      bundles.add(bundle);
    }

    setState(ViewState.Idle);

    return bundles;
  }
}
