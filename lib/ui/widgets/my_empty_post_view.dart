import 'package:flutter/material.dart';
import 'package:nutes/ui/screens/editor_page.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/empty_view.dart';

class MyEmptyPostView extends StatelessWidget {
  const MyEmptyPostView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: <Widget>[
            EmptyView(
              title: 'No Posts Yet',
              subtitle: 'When you post, you will see your posts here',
            ),
            SizedBox(height: 16),
            RaisedButton.icon(
              color: Colors.blueAccent[400],
              onPressed: () => Navigator.of(context, rootNavigator: true)
                  .push(EditorPage.route()),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: Text(
                'Create',
                style: TextStyles.w600Text.copyWith(color: Colors.white),
              ),
              shape: StadiumBorder(),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
