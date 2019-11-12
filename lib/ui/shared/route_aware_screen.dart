import 'package:flutter/material.dart';

class RouteAwareScreen extends StatefulWidget {
  @override
  _RouteAwareScreenState createState() => _RouteAwareScreenState();
}

class _RouteAwareScreenState extends State<RouteAwareScreen> with RouteAware {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
