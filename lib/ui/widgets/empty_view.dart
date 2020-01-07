import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/styles.dart';

class EmptyView extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyView({Key key, @required this.title, @required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyles.w600Text,
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyles.defaultText.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
