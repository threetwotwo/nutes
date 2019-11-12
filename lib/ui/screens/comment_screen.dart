import 'package:flutter/material.dart';
import 'package:nutes/core/view_models/comment_model.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/comment_textfield.dart';
import 'package:nutes/ui/shared/provider_view.dart';
import 'package:nutes/ui/widgets/comment_list_item.dart';

class CommentScreen extends StatelessWidget {
  final String postId;

  const CommentScreen({Key key, this.postId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        title: Text(
          'Comments',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: ProviderView<CommentModel>(
          builder: (context, model, child) => Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                    child: Container(
                  child: ListView.separated(
                      separatorBuilder: (context, index) => Container(
                            height: 10,
//                            color: Colors.grey,
                          ),
                      itemCount: model.comments.length,
                      itemBuilder: (context, index) => CommentListItem(
                            comment: model.comments[index],
                          )),
                )),
                CommentTextField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
