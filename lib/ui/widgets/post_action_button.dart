import 'package:flutter/material.dart';

class PostActionButton extends StatelessWidget {
  final iconSize = 24.0;
  final Color color;
  final Function onTap;
  final IconData icon;
  final Image image;

  const PostActionButton({
    Key key,
    @required this.onTap,
    @required this.icon,
    this.color = Colors.black,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: icon != null
            ? Icon(
                icon,
                color: this.color,
                size: iconSize,
              )
            : Container(
                height: 24,
                child: Image.asset(
                  'assets/images/spiral.png',
                  fit: BoxFit.contain,
                ),
              ));
  }
}
