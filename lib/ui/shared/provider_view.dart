import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutes/core/services/locator.dart';
import 'package:nutes/core/view_models/base_model.dart';

class ProviderView<T extends ChangeNotifier> extends StatefulWidget {
  final Widget Function(BuildContext context, T value, Widget child) builder;
  final Function(T) onModelReady;
  ProviderView({@required this.builder, this.onModelReady});
  @override
  _ProviderViewState<T> createState() => _ProviderViewState<T>();
}

class _ProviderViewState<T extends ChangeNotifier>
    extends State<ProviderView<T>> {
  T model = locator<T>();
  @override
  void initState() {
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      builder: (context) => model,
      child: Consumer<T>(builder: widget.builder),
    );
  }
}
