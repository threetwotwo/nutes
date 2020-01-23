import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutes/core/models/filter.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/ui/shared/buttons.dart';
import 'package:nutes/ui/screens/confirm_upload_page.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/capturable_area.dart';
import 'package:nutes/ui/widgets/filter_avatar.dart';
import 'package:nutes/ui/widgets/color_avatar.dart';
import 'package:nutes/utils/image_file_bundle.dart';

class EditorPage extends StatefulWidget {
  final Function onBackPressed;
  final bool isStoryMode;

  EditorPage({this.onBackPressed, this.isStoryMode = false});

  static Route route() => MaterialPageRoute(
      fullscreenDialog: true, builder: (context) => EditorPage());

  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage>
    with AutomaticKeepAliveClientMixin {
  int currentPage = 0;
  int currentFilter = 1;

  bool isLoading = false;

  final filterController =
      PageController(viewportFraction: 0.23, initialPage: 1);

  bool isKeyboardVisible = false;
  bool isVisible = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    ///hide system overlays when not in story mode
//    if (!widget.isStoryMode) SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    cache.filters.clear();

    super.dispose();
  }

  final _pageController = PageController();

  PageController get pageController => this._pageController;

  final cache = LocalCache.instance;

  List<CapturePage> capturePages = [
    CapturePage(
        controller: CaptureController(), filter: getFilter(FilterType.canvas))
  ];

  void onPage() {}

  void onFilter(int filterIndex, Filter filter) {
    print('change filter');
    currentFilter = filterIndex;
//    final existingController = capturePages[currentPage].controller;

    ///update local cache filter
//    cache.filters[filterIndex] = filter;
    capturePages[currentPage] =
        capturePages[currentPage].copyWith(filter: filter);
    if (mounted) setState(() {});
//    FocusScope.of(context).requestFocus(node);
  }

  void changeTextColor(Color color) {
    print('change text color to $color');

    var filter = capturePages[currentPage].filter;
    final variantIndex = capturePages[currentPage].filter.variantIndex;

    var variants = filter.variants;

    final variant = variants[variantIndex];

    variants[variantIndex] =
        variant.copyWith(text: variant.textStyle.copyWith(color: color));

//    capturePages[index].filterType = filterType;
    capturePages[currentPage] = capturePages[currentPage]
        .copyWith(filter: filter.copyWith(isChanged: true, variants: variants));

    filter = filter.copyWith(isChanged: true, variants: variants);

    ///update local cache filter
    cache.filters[currentPage] = Map()..[currentFilter] = filter;

    if (mounted) setState(() {});
  }

  void onVariant(int variantIndex) {
    print('change variant');

//    final existingController = capturePages[currentPage].controller;

    final filter =
        capturePages[currentPage].filter.copyWith(variantIndex: variantIndex);

    capturePages[currentPage] = capturePages[currentPage].copyWith(
        filter: filter.copyWith(variantIndex: variantIndex, isChanged: true));

    ///update local cache filter
    cache.filters[currentPage] = Map()..[currentFilter] = filter;

    if (mounted) setState(() {});
  }

  Future deletePage(BuildContext context) async {
    ///delete page and update current page
    capturePages.removeAt(currentPage);
    currentPage -= 1;
    if (mounted) setState(() {});

    ///Go to the page right before and focus on it;
    await _pageController.animateToPage(currentPage,
        duration: Duration(milliseconds: 100), curve: Curves.easeOut);
    final node = capturePages[currentPage].controller.focusNode;
    FocusScope.of(context).requestFocus(node);
  }

  ///Adds a new page
  Future incrementPageCount(BuildContext context) async {
    ///index of last page
    final lastIndex = capturePages.length - 1;

    ///max length is 7
    if (capturePages.length > 6) return;

    ///get filter of last page
    final lastFilter = capturePages[lastIndex].filter;

    ///create new page
    capturePages
        .add(CapturePage(controller: CaptureController(), filter: lastFilter));

    currentPage += 1;

    if (mounted) setState(() {});

    ///go to new page
    await _pageController.animateToPage(capturePages.length - 1,
        duration: Duration(milliseconds: 100), curve: Curves.easeOut);

    ///focus on the new page
    ///Dont user lastIndex since it is not updated
    final node = capturePages[capturePages.length - 1].controller.focusNode;
    FocusScope.of(context).requestFocus(node);
  }

  ///Iterates over an array of [CaptureController]s
  ///and creates an [ImageFileBundle] for each controller
  Future<List<ImageFileBundle>> takeScreenshots() async {
    List<ImageFileBundle> bundles = [];

    setState(() {
      isLoading = true;
    });
    for (var i = 0; i < capturePages.length; i++) {
      await _pageController.animateToPage(
        i,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );

      final page = capturePages[i];

      final filter = page.filter;

      double aspectRatio;

      final text = page.controller.textController.text.length;

      switch (filter.type) {
        case FilterType.urban:
          if (text > 150)
            aspectRatio = 0.8;
          else if (text > 90)
            aspectRatio = 1;
          else
            aspectRatio = 1.4;
          break;

        case FilterType.canvas:
        case FilterType.ego:
          if (text > 200)
            aspectRatio = 0.8;
          else if (text > 100)
            aspectRatio = 1;
          else
            aspectRatio = 1.4;
          break;

        case FilterType.frame:
          aspectRatio = 1;
          break;

        default:
          aspectRatio = 1;
          break;
      }

      print('suggested aspect ratio for image: $aspectRatio');

      final bundle =
          await capturePages[i].controller.screenshotController.capture(
                index: i,
                pixelRatio: 5,
                aspectRatio: aspectRatio,
              );

      bundles.add(bundle);
    }

    setState(() {
      isLoading = false;
    });
    return bundles;
  }

  @override
  Widget build(BuildContext context) {
    ///TODO: review if need to call super

    super.build(context);

    final filter = capturePages[currentPage].filter;

    return Scaffold(
      body: Container(
        decoration: filter.variant.bgDecor,
        child: Stack(
          children: <Widget>[
            ///Main view
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: PageView.builder(
                onPageChanged: (value) {
                  print('on page change $value filter type ${filter.type}');
                  setState(() {
                    currentPage = value;
                    filterController.animateToPage(
                      FilterType.values
                          .indexOf(capturePages[currentPage].filter.type),
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  });
                },
                itemCount: capturePages.length,
                controller: pageController,
                itemBuilder: (context, index) {
                  return capturePages[index];
                },
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  EditorDefaultTopButtons(
                    currentPage: currentPage,
                    pages: capturePages,
                    onAddPressed: () => incrementPageCount(context),
                    onBackPressed: widget.onBackPressed,
                    isStory: widget.isStoryMode,
                    controller: filterController,
                    onFilterChanged: (filterIndex, filter) =>
                        onFilter(filterIndex, filter),
                    onVariantChange: (val) {
                      return onVariant(val);
                    },
                  ),
                  Expanded(
                    child: capturePages.length < 2
                        ? SizedBox()
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              currentPage == 0
                                  ? SizedBox()
                                  : Container(
                                      padding: const EdgeInsets.all(5.0),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: InkWell(
                                        onTap: () => deletePage(context),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Text(
                                  ' ${currentPage + 1}/${capturePages.length} ',
                                  style: TextStyles.defaultText
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                  ),
                  EditorFooter(
                      onColor: (val) {
                        return changeTextColor(val);
                      },
                      pageController: _pageController,
//                            currentPage: currentPage,
                      itemCount: capturePages.length,
                      isLoading: isLoading,
                      onSendPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());

                        ///hacky way to ensure keyboard is fully dismissed
                        await Future.delayed(Duration(milliseconds: 100));

                        final bundles = await takeScreenshots();

                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) => ConfirmUploadPage(
                                      fileBundles: bundles,
                                      enableStory: bundles.length <= 1,
                                    )));

                        if (result is bool && result == true) {
                          print('should go to home');
                          Navigator.popUntil(context, (r) => r.isFirst);

                          await cache.animateTo(1);
                          BotToast.showText(
                            text: 'Shared story',
                            align: Alignment(0, -0.75),
                          );
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditorDefaultTopButtons extends StatefulWidget {
  final void Function(int, Filter) onFilterChanged;
  final void Function(int) onVariantChange;
  final PageController controller;
  final bool isStory;
  final Function onBackPressed;
  final VoidCallback onAddPressed;
  final List<CapturePage> pages;
  final int currentPage;

  const EditorDefaultTopButtons({
    Key key,
    this.onFilterChanged,
    @required this.controller,
    @required this.isStory,
    this.onBackPressed,
    this.onAddPressed,
    this.onVariantChange,
    this.pages,
    this.currentPage,
  }) : super(key: key);

  @override
  _EditorDefaultTopButtonsState createState() =>
      _EditorDefaultTopButtonsState();
}

class _EditorDefaultTopButtonsState extends State<EditorDefaultTopButtons> {
  ///Current filter index
  int filterIndex = 1;

  final filters = [
    filterUrban(),
    filterCanvas(),
    filterFrame(),
    filterEgo(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.22),
            Colors.transparent,
          ],
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
        ),
      ),
      child: Row(
        children: <Widget>[
          widget.isStory
              ? SettingsButton(
                  color: Colors.transparent,
                  onPressed: () {
                    print('settings pressed');
                  },
                )
              : Row(
                  children: <Widget>[
                    AddButton(
                      onPressed:
                          widget.currentPage == 6 ? null : widget.onAddPressed,
                    ),
                  ],
                ),
          buildFilterAvatars(widget.pages),
          widget.isStory
              ? RightBackButton(
                  onPressed: widget.onBackPressed,
                )
              : CancelButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
        ],
      ),
    );
  }

  Expanded buildFilterAvatars(List<CapturePage> pages) {
    return Expanded(
      child: Column(
        children: <Widget>[
          ///filter label
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  filters[filterIndex].avatar.title,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
//                InkWell(
////                  highlightColor: Colors.transparent,
//                  splashColor: Colors.red,
//                  onTap: () => print('tapped filter bookmark'),
//                  child: Padding(
//                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                    child: Icon(
//                      Icons.bookmark_border,
//                      color: Colors.white,
//                      size: 22,
//                    ),
//                  ),
//                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 60,
            child: Stack(
              children: <Widget>[
                ///Filter avatars
                PageView.builder(
                  onPageChanged: (filter) {
                    setState(() {
                      filterIndex = filter;

                      final cache = LocalCache.instance;

                      final Filter existingFilter =
                          cache.filters[widget.currentPage] == null
                              ? null
                              : cache.filters[widget.currentPage][filter];

                      widget.onFilterChanged(
                          filterIndex, existingFilter ?? filters[filter]);
                    });
                  },
                  controller: widget.controller,
                  itemCount: filters.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        print('tapped page: $index');

                        widget.controller.animateToPage(index,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeInOut);
                      },
                      child: AnimatedBuilder(
                        animation: widget.controller,
                        builder: (context, child) {
                          double value = 1;

                          //for exception: Page value is only available after content dimensions are established.
                          if (widget.controller.position.haveDimensions) {
//                      value = widget.controller.page.round();
                            value = widget.controller.page - index;
                            value = (1 - (value.abs() * .18)).clamp(0.0, 1.0);
                          }
                          return Container(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Transform.scale(
                                scale: Curves.easeInOut.transform(value),
                                child: filters[index].avatar,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                ///Ring
                Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onTap: () {
                        final currentVariantIndex =
                            pages[widget.currentPage].filter.variantIndex;

                        final variantLength =
                            pages[widget.currentPage].filter.variants.length;

                        widget.onVariantChange(
                            currentVariantIndex == variantLength - 1
                                ? 0
                                : currentVariantIndex + 1);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: Colors.grey, width: 0.5),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              border:
                                  Border.all(color: Colors.grey, width: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditorFooter extends StatelessWidget {
  final Function onSendPressed;
  final PageController pageController;
  final bool isLoading;
//  final int filterIndex;
//  final int currentPage;
  final int itemCount;
  final void Function(Color) onColor;

  const EditorFooter({
    Key key,
    this.onSendPressed,
    this.pageController,
    this.isLoading,
//    this.currentPage,
    this.itemCount,
    this.onColor,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(8),
            child: FlatButton(
              onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: Text(
                'Done',
                style: TextStyle(color: Colors.blueAccent, fontSize: 16),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: ColorAvatars(
            onColor: (val) => onColor(val),
          ),
        ),
        Expanded(
          flex: 1,
          child: SendToButton(
            isLoading: isLoading,
            onPressed: onSendPressed,
          ),
        )
      ],
    );
  }
}
