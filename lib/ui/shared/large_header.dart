import 'package:flutter/material.dart';

class LargeHeader extends StatelessWidget {
  final String title;

  const LargeHeader({Key key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Text(
        title,
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}
