import 'package:flutter/foundation.dart';

///Represents the state of the view
enum ViewState { Idle, Busy }

///Base view model that all view models extends from.
///
///Contains [ViewState] that tells what UI layout to show.
///Models will ONLY request data from Services and reduce state from that DATA. Nothing else.
class BaseModel extends ChangeNotifier {
  ViewState _state = ViewState.Idle;

  ViewState get state => _state;

  void setState(ViewState state) {
    _state = state;
    if (hasListeners) notifyListeners();
  }

  void notify() {
    if (hasListeners) notifyListeners();
  }
}
