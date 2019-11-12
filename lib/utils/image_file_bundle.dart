import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

class ImageFileBundle {
  final int index;
  final File original;
  final File medium;
  final File small;

  ImageFileBundle(
      {@required this.index,
      @required this.original,
      @required this.medium,
      @required this.small});
}

class ImageUrlBundle {
  final int index;
  final String original;
  final String medium;
  final String small;

  ImageUrlBundle({
    @required this.index,
    @required this.original,
    @required this.medium,
    @required this.small,
  });

  factory ImageUrlBundle.fromMap(int index, Map map) {
    return ImageUrlBundle(
      index: index,
      small: map['small'] ?? '',
      medium: map['medium'] ?? '',
      original: map['original'] ?? '',
    );
  }
}
