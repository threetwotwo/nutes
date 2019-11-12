import 'package:flutter/material.dart';
import 'dart:math';

const double baseHeight = 896;

double screenAwareSize(double size, BuildContext context) {
  return size * MediaQuery.of(context).size.height / baseHeight;
}

double defaultSize(double size, BuildContext context,
    {@required double defaultTo}) {
  return max(screenAwareSize(size, context), defaultTo);
}
