import 'package:nutes/core/models/comment.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/view_models/base_model.dart';

class CommentModel extends BaseModel {
  final Post post;
  List<Comment> comments = [];

  CommentModel({this.post});

  void addComment(Comment comment) {
    comments.add(comment);
    notifyListeners();
  }
}
