import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/styles.dart';

class NutesLogoPlain extends StatelessWidget {
  const NutesLogoPlain({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'nutes',
      style: TextStyles.large600Display,
    );
  }
}

class NutesLogoRoundedBorder extends StatelessWidget {
  const NutesLogoRoundedBorder({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: ColorStyles.schoolBusYellow,
          borderRadius: BorderRadius.circular(100)),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
      child: Text(
        'nutes',
        style: TextStyles.large600Display,
      ),
    );
  }
}
