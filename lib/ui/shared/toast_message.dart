import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/styles.dart';

class ToastMessage extends StatelessWidget {
  final String title;
  final Widget leading;

  const ToastMessage({Key key, this.title, this.leading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 8.0,
      ),
      margin: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        color: Colors.black87,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (leading != null) leading,
          Text(
            title,
            style: TextStyles.defaultText.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
