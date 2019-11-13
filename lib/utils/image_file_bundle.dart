import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

///Object use to upload image urls to storage and firestore
///Representation of an image
class ImageFileBundle {
  final int index;
  final File original;
  final File medium;
  final File small;
  final double aspectRatio;

  ImageFileBundle({
    @required this.index,
    @required this.original,
    @required this.medium,
    @required this.small,
    this.aspectRatio,
  });
}

///Object retrieved from firestore to display an image
class ImageUrlBundle {
  final int index;
  final String original;
  final String medium;
  final String small;
  final double aspectRatio;

  ImageUrlBundle({
    @required this.index,
    @required this.original,
    @required this.medium,
    @required this.small,
    this.aspectRatio = 1,
  });

  factory ImageUrlBundle.fromMap(int index, Map map) {
    return ImageUrlBundle(
      index: index,
      small: map['small'] ?? '',
      medium: map['medium'] ?? '',
      original: map['original'] ?? '',
      aspectRatio: map['aspect_ratio'] ?? 1,
    );
  }
}
