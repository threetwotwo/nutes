import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';

class PostDeleteEvent {
  final String postId;

  PostDeleteEvent(this.postId);
}

class PostUploadEvent {
  final Post post;

  PostUploadEvent(this.post);
}

class ProfileUpdateEvent {
  final UserProfile profile;

  ProfileUpdateEvent(this.profile);
}
