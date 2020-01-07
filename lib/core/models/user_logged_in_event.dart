import 'package:nutes/core/models/user.dart';

class UserLoggedInEvent {
  final User user;

  UserLoggedInEvent(this.user);
}

class UserFollowEvent {
  final User user;

  UserFollowEvent(this.user);
}
