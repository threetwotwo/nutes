import 'package:event_bus/event_bus.dart';
import 'package:nutes/core/models/user.dart';

/// The global [EventBus] object.
EventBus eventBus = EventBus();

/// Event A.
class MyEventA {
  String text;

  MyEventA(this.text);
}

class UserProfileChangedEvent {
  final UserProfile profile;

  UserProfileChangedEvent(this.profile);
}

class UserLoggedInEvent {
  final User user;

  UserLoggedInEvent(this.user);
}

class UserFollowEvent {
  final User user;

  UserFollowEvent(this.user);
}
