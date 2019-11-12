import 'package:flutter/material.dart';
import 'package:nutes/ui/widgets/filter_avatar.dart';

enum FilterType {
  urban,
  canvas,
  frame,
  ego,
}

class Filter {
  final bool isChanged;
  final FilterType type;
  final FilterAvatar avatar;
//  final Color backgroundColor;
//  final TextStyle textStyle;
  final List<FilterVariant> variants;
  final int variantIndex;

  Filter({
    this.variantIndex = 0,
    this.isChanged = false,
    this.type,
    this.avatar,
//    this.backgroundColor,
//    this.textStyle,
    this.variants,
  });

  ///Current variant at this [variantIndex]
  FilterVariant get variant => variants[variantIndex];

  Filter copyWith(
      {Color bgColor,
      TextStyle textStyle,
      bool isChanged,
      int variantIndex,
      List<FilterVariant> variants}) {
    return Filter(
      isChanged: isChanged ?? this.isChanged,
      type: this.type,
      avatar: this.avatar,
//      backgroundColor: bgColor ?? this.backgroundColor,
//      textStyle: textStyle ?? this.textStyle,
      variantIndex: variantIndex ?? this.variantIndex,
      variants: variants ?? this.variants,
    );
  }
}
