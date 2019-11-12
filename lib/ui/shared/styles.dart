import 'package:flutter/material.dart';

class GradientStyles {
  static final soft = LinearGradient(
      colors: [ColorStyles.yellowOrange, Colors.deepOrange[300]]);
  static final blue =
      LinearGradient(colors: [Colors.blue[500], Colors.blueAccent[700]]);
  static final green =
      LinearGradient(colors: [Colors.green, Colors.greenAccent]);
  static final titanium =
      RadialGradient(colors: [Colors.blueGrey, ColorStyles.darkPurple]);

  static final alihussein = LinearGradient(
    // Where the linear gradient begins and ends
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    // Add one stop for each color. Stops should increase from 0 to 1
    stops: [0.15, 0.6, 0.8],
    colors: [
      // Colors are easy thanks to Flutter's Colors class.
      Colors.yellow[600],
      Colors.pink[700],
      Colors.purple[800],
    ],
  );
}

class ColorStyles {
  static const schoolBusYellow = Color(0xFFffd800);
  static const gargoyleGas = Color(0xFFfee342);
  static const yellowOrange = Color(0xFFfe9603);
  static const water = Color(0xFFd0f7fc);
  static const darkPurple = Color(0xFF2b202e);
  static const vibrantBlue = Color.fromARGB(255, 3, 54, 255);
}

class TextStyles {
  static final displayFamily = '.SF UI Display';
  static final textFamily = '.SF UI Text';

  static final defaultDisplay = TextStyle(
    fontFamily: displayFamily,
    color: Colors.black,
  );

  static final defaultText = TextStyle(
    fontFamily: textFamily,
    color: Colors.black,
  );

  static final w300Display = defaultDisplay.copyWith(
    fontWeight: FontWeight.w300,
    fontSize: 18,
  );

  static final w300Text = defaultText.copyWith(
    fontWeight: FontWeight.w300,
    fontSize: 15,
  );

  static final W500Text15 = defaultText.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: 15,
  );

  static final large600Display = defaultDisplay.copyWith(
    fontWeight: FontWeight.w600,
    fontSize: 30,
  );
}