import 'package:flutter/material.dart';
import 'package:nutes/core/services/local_cache.dart';

class DismissView extends StatelessWidget {
  final bool enabled;
  final Widget child;
  const DismissView({
    Key key,
    this.child,
    this.enabled = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: enabled ? (_) {} : null,
      child: Container(
        height: double.infinity,
        child: child,
      ),
    );
  }
}
