import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/styles.dart';

class EmptyIndicator extends StatelessWidget {
  final String title;

  const EmptyIndicator(this.title);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: TextStyles.defaultText.copyWith(color: Colors.grey),
      ),
    );
  }
}
