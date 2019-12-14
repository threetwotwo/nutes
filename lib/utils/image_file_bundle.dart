import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    this.index,
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
    this.index,
    @required this.original,
    @required this.medium,
    @required this.small,
    this.aspectRatio = 1,
  });

  factory ImageUrlBundle.empty() {
    return ImageUrlBundle(
      index: 0,
      small: '',
      medium: '',
      original: '',
      aspectRatio: 1.0,
    );
  }

  factory ImageUrlBundle.fromUserDoc(DocumentSnapshot doc) {
    return ImageUrlBundle(
      small: doc['photo_url_small'] ?? '',
      medium: doc['photo_url_medium'] ?? '',
      original: doc['photo_url'] ?? '',
    );
  }

  factory ImageUrlBundle.fromMap(int index, Map map) {
    return ImageUrlBundle(
      index: index,
      small: map['small'] ?? '',
      medium: map['medium'] ?? '',
      original: map['original'] ?? '',
      aspectRatio: (map['aspect_ratio'] ?? 1.0).toDouble(),
    );
  }
}
