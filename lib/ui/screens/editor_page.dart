import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nutes/core/models/filter.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/view_models/base_model.dart';
import 'package:nutes/core/view_models/upload_model.dart';
import 'package:nutes/ui/shared/buttons.dart';
import 'package:nutes/ui/shared/provider_view.dart';
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
      PageController(viewportFraction: 0.25, initialPage: 1);

  bool isKeyboardVisible = false;
  bool isVisible = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    ///hide system overlays
    SystemChrome.setEnabledSystemUIOverlays([]);
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

    final existingController = capturePages[currentPage].controller;

    final filter =
        capturePages[currentPage].filter.copyWith(variantIndex: variantIndex);

    capturePages[currentPage] = capturePages[currentPage].copyWith(
        filter: filter.copyWith(variantIndex: variantIndex, isChanged: true));

    ///update local cache filter
    cache.filters[currentPage] = Map()..[currentFilter] = filter;
//    [currentFilter] = filter;
//    print(cache.filters[page].type);

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
      final bundle = await capturePages[i]
          .controller
          .screenshotController
          .capture(index: i, pixelRatio: 5);

      bundles.add(bundle);
    }

    setState(() {
      isLoading = false;
    });
    return bundles;
  }

  @override
  Widget build(BuildContext context) {
    return ProviderView<UploadModel>(
      builder: (context, model, child) {
        final filter = capturePages[currentPage].filter;

        return Scaffold(
          body: Container(
            decoration: filter.variant.bgDecor,
            child: SafeArea(
              child: Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: PageView.builder(
                      onPageChanged: (value) {
                        print(
                            'on page change $value filter type ${filter.type}');
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
                          onDeletePressed: () => deletePage(context),
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
                          child: SizedBox(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: capturePages.length < 2
                                  ? SizedBox()
                                  : Container(
                                      padding: const EdgeInsets.all(5.0),
                                      margin: const EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: Text(
                                        ' ${currentPage + 1}/${capturePages.length} ',
                                        style: TextStyles.defaultText
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        EditorFooter(
                            doneColor: Colors.blueAccent,
                            onColor: (val) {
                              return changeTextColor(val);
                            },
                            pageController: _pageController,
//                            currentPage: currentPage,
                            itemCount: capturePages.length,
                            isLoading: isLoading,
                            onSendPressed: () async {
                              print('hide keyboard on send');
                              FocusScope.of(context).requestFocus(FocusNode());

                              ///hacky way to ensure keyboard is fully dismissed
                              await Future.delayed(Duration(milliseconds: 100));

                              final bundles = await takeScreenshots();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (ctx) => ConfirmUploadPage(
                                            fileBundles: bundles,
                                            enableStory: bundles.length <= 1,
                                          )));
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class EditorStoryTopButtons extends StatelessWidget {
  final Function onBackPressed;
  const EditorStoryTopButtons({Key key, this.onBackPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.05),
            Colors.black12,
          ],
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SettingsButton(
            onPressed: () {
              print('settings pressed');
            },
          ),
          RightBackButton(
            onPressed: onBackPressed,
          ),
        ],
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
  final VoidCallback onDeletePressed;
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
    this.onDeletePressed,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.05),
            Colors.black12,
          ],
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
        ),
      ),
      child: Row(
        children: <Widget>[
          widget.isStory
              ? SettingsButton(
                  onPressed: () {
                    print('settings pressed');
                  },
                )
              : CancelButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
          buildFilterAvatars(widget.pages),
          widget.isStory
              ? RightBackButton(
                  onPressed: widget.onBackPressed,
                )
              : Row(
                  children: <Widget>[
                    if (widget.pages.length > 1 && widget.currentPage != 0)
                      DeleteButton(
                        onPressed: widget.onDeletePressed,
                      ),
                    if (widget.currentPage != 6)
                      AddButton(
                        onPressed: widget.onAddPressed,
                      ),
                  ],
                ),
        ],
      ),
    );
  }

  Expanded buildFilterAvatars(List<CapturePage> pages) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Container(
            height: 60,
            child: Stack(
              children: <Widget>[
                PageView.builder(
                  onPageChanged: (filter) {
//                    print('change to page $page');
                    setState(() {
                      filterIndex = filter;

                      final cache = LocalCache.instance;

                      print('cached filter: ${cache.filters}');

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
                            value = (1 - (value.abs() * .35)).clamp(0.0, 1.0);
                          }
                          return Container(
//                            color: Colors.red,
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
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.grey, width: 0.5),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              filters[filterIndex].avatar.title,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
  final Color doneColor;

  const EditorFooter({
    Key key,
    this.onSendPressed,
    this.pageController,
    this.isLoading,
//    this.currentPage,
    this.itemCount,
    this.onColor,
    this.doneColor,
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
                style: TextStyle(color: doneColor, fontSize: 16),
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