import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/comment_model.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/styles.dart';

class CommentTextField extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
//  const CommentTextField({
//    Key key,
//    this.controller,
//  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<CommentModel>(context);
    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                AvatarImage(url: Repo.currentProfile.user.photoUrl, spacing: 0),
          )),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: this.controller,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: 2200,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            hintText:
                                ' Add comment as ${Repo.currentProfile.user.username}...'),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        InkWell(
                          borderRadius: BorderRadius.circular(200),
                          splashColor: Colors.white,
                          onTap: () {
                            if (this.controller.text.isEmpty ||
                                this.controller.text == null) return;
                            final comment = Comment(
                                postId: '',
                                timestamp: null,
                                text: controller.text,
                                uploader: Repo.currentProfile.user);
                            model.addComment(comment);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Post',
                              style: TextStyles.W500Text15.copyWith(
                                  color: Colors.blueAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.grey[300], width: 1.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
