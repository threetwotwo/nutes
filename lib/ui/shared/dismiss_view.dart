import 'package:flutter/material.dart';
import 'package:nutes/core/services/local_cache.dart';

class DismissView extends StatelessWidget {
  final Widget child;
  final VoidCallback onDismiss;
  const DismissView({Key key, this.child, this.onDismiss}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (_) {},
      child: Container(
        height: double.infinity,
        child: child,
      ),
    );
  }
}
