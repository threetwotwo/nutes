import 'package:flutter/material.dart';
import 'package:nutes/core/models/filter.dart';
import 'package:nutes/ui/shared/styles.dart';

Filter getFilter(FilterType filterType) {
  switch (filterType) {
    case FilterType.urban:
      return filterUrban();
    case FilterType.canvas:
      return filterCanvas();
    case FilterType.frame:
      return filterFrame();
    case FilterType.ego:
      return filterEgo();
  }
}

///A variant of a [Filter]
///A [Filter] of a [FilterType] can have multiple [FilterVariant]s
///
class FilterVariant {
  final TextStyle textStyle;
  final LinearGradient gradient;
  final BoxDecoration bgDecor;
  final BoxDecoration fgDecor;

  static const urbanText =
      TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600);
  static const canvasText = TextStyle(color: Colors.black, fontSize: 24);
  static const frameText = TextStyle(color: Colors.black, fontSize: 20);

  static final egoText = TextStyles.w300Text.copyWith(fontSize: 20);

  static final frameShadow = [
    BoxShadow(
      color: Colors.grey.withOpacity(0.4),
      blurRadius: 8.0, // has the effect of softening the shadow
      spreadRadius: 6.0, // has the effect of extending the shadow
      offset: Offset(
        0.0, // horizontal, move right 10
        0.0, // vertical, move down 10
      ),
    )
  ];

  FilterVariant({
    @required this.bgDecor,
    this.fgDecor,
    this.textStyle,
    this.gradient,
  });

  FilterVariant copyWith({
    Color bgColor,
    Color fgColor,
    BoxDecoration bgDecor,
    BoxDecoration fgDecor,
    TextStyle text,
    LinearGradient gradient,
  }) {
    return FilterVariant(
      bgDecor: bgDecor ?? this.bgDecor,
      fgDecor: fgDecor ?? this.fgDecor,
      gradient: gradient ?? this.gradient,
      textStyle: text ?? this.textStyle,
    );
  }

  ///
  ///Canvas
  ///
  factory FilterVariant.canvas() {
    return FilterVariant(
      bgDecor: BoxDecoration(color: Colors.white),
      textStyle: canvasText,
    );
  }
  factory FilterVariant.canvasDark() {
    return FilterVariant(
        bgDecor: BoxDecoration(color: Colors.grey[900]),
        textStyle: canvasText.copyWith(
          color: Colors.white,
        ));
  }

  ///
  ///Urban
  ///
  factory FilterVariant.urban() {
    return FilterVariant(
      bgDecor: BoxDecoration(color: ColorStyles.schoolBusYellow),
      textStyle: urbanText,
    );
  }
  factory FilterVariant.urbanWhite() {
    return FilterVariant.urban()
        .copyWith(bgDecor: BoxDecoration(color: Colors.white));
  }
  factory FilterVariant.urbanDark() {
    return FilterVariant.urban().copyWith(
        bgDecor: BoxDecoration(color: Colors.black),
        text: urbanText.copyWith(color: Colors.white));
  }

  factory FilterVariant.urbanRed() {
    return FilterVariant.urban().copyWith(
      text: urbanText.copyWith(color: Colors.white),
      bgDecor: BoxDecoration(color: Colors.redAccent[400]),
    );
  }
  factory FilterVariant.urbanGradientBlueGreen() {
    return FilterVariant.urban().copyWith(
      text: urbanText.copyWith(color: Colors.white),
      bgDecor: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [
              0.2,
              0.85
            ],
            colors: [
              Colors.green[400],
              Colors.lightBlueAccent[200],
            ]),
      ),
    );
  }
  factory FilterVariant.urbanGradientOrange() {
    return FilterVariant.urban().copyWith(
      text: urbanText.copyWith(color: Colors.white),
      bgDecor: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [
              0.2,
              0.85
            ],
            colors: [
              Colors.deepOrange[300],
              Colors.orange[200],
            ]),
      ),
    );
  }

  ///
  ///Frame
  ///
  factory FilterVariant.frame() {
    return FilterVariant(
      bgDecor: BoxDecoration(color: Colors.white),
      fgDecor: BoxDecoration(color: Colors.white, boxShadow: frameShadow),
      textStyle: frameText,
    );
  }
  factory FilterVariant.frameOutline() {
    return FilterVariant(
      bgDecor: BoxDecoration(color: Colors.white),
      fgDecor: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 8)),
      textStyle: frameText.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  factory FilterVariant.frameGradientLight() {
    return FilterVariant(
      fgDecor: BoxDecoration(
        color: Colors.white,
        boxShadow: frameShadow,
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[100]],
          stops: [0.1, 0.95],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      bgDecor: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          colors: [Colors.grey[200], Colors.white],
          stops: [0.1, 0.95],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      textStyle: frameText,
    );
  }
  factory FilterVariant.frameDark() {
    return FilterVariant(
        bgDecor: BoxDecoration(color: Colors.white),
        fgDecor: BoxDecoration(color: Colors.black, boxShadow: frameShadow),
        textStyle: frameText.copyWith(
          color: Colors.white,
        ));
  }

  ///
  ///Ego
  ///
  factory FilterVariant.ego() {
    return FilterVariant(
      bgDecor: BoxDecoration(color: Colors.white),
      textStyle: egoText,
    );
  }
}

class FilterAvatar extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Widget child;

  const FilterAvatar({Key key, this.backgroundColor, this.child, this.title})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: backgroundColor,
      child: Center(child: child),
    );
  }
}

Filter filterUrban() {
  return Filter(
    variants: [
      FilterVariant.urban(),
      FilterVariant.urbanDark(),
      FilterVariant.urbanWhite(),
      FilterVariant.urbanGradientOrange(),
      FilterVariant.urbanGradientBlueGreen(),
      FilterVariant.urbanRed(),
    ],
    type: FilterType.urban,
//    backgroundColor: ColorStyles.schoolBusYellow,
//    textStyle: TextStyles.large600Display,
    avatar: FilterAvatar(
      title: 'Urban',
      backgroundColor: Colors.yellow,
      child: Text(
        '#',
        style: TextStyles.large600Display,
      ),
    ),
  );
}

Filter filterCanvas() {
  return Filter(
    variants: [
      FilterVariant.canvas(),
      FilterVariant.canvasDark(),
    ],
    type: FilterType.canvas,
    avatar: FilterAvatar(
      title: 'Canvas',
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            child: Center(
                child: Text(
              'Aa',
              style: TextStyles.defaultDisplay,
              overflow: TextOverflow.fade,
            )),
//            decoration: BoxDecoration(
//              color: Colors.white,
//              gradient: LinearGradient(
//                colors: [Colors.white, Colors.grey[100]],
//                begin: Alignment.topCenter,
//                end: Alignment.center,
//              ),
//              boxShadow: [
//                BoxShadow(
//                  color: Colors.black.withOpacity(0.2),
//                  blurRadius: 3.0, // has the effect of softening the shadow
//                  spreadRadius: 2.0, // has the effect of extending the shadow
//                  offset: Offset(
//                    0.0, // horizontal, move right 10
//                    2.0, // vertical, move down 10
//                  ),
//                )
//              ],
//            ),
          ),
        ),
      ),
    ),
  );
}

Filter filterFrame() {
  return Filter(
    variants: [
      FilterVariant.frame(),
      FilterVariant.frameOutline(),
      FilterVariant.frameGradientLight(),
      FilterVariant.frameDark(),
    ],
    type: FilterType.frame,
    avatar: FilterAvatar(
      title: 'Frame',
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            child: Icon(
              Icons.dehaze,
              color: Colors.black87,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[100]],
                begin: Alignment.topCenter,
                end: Alignment.center,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 3.0, // has the effect of softening the shadow
                  spreadRadius: 2.0, // has the effect of extending the shadow
                  offset: Offset(
                    0.0, // horizontal, move right 10
                    2.0, // vertical, move down 10
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Filter filterEgo() {
  return Filter(
    variants: [
      FilterVariant.ego(),
    ],
    type: FilterType.ego,
    avatar: FilterAvatar(
      backgroundColor: Colors.white,
      title: 'Ego',
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          color: Colors.white,
          child: Icon(
            Icons.person_outline,
            color: Colors.black87,
          ),
        ),
      ),
    ),
  );
}
