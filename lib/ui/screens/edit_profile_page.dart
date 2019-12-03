import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/core/view_models/profile_model.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

//  final ProfileModel model;
  EditProfilePage({
    Key key,
    this.profile,
//    this.model,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  bool isUpdating = false;

  @override
  void initState() {
    _usernameController.text = widget.profile.user.username;
    _displayNameController.text = widget.profile.user.displayName;
    _bioController.text = widget.profile.bio;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EditProfileAppBar(
        onCancelPressed: () => Navigator.of(context).pop(),
        onDonePressed: () async {
          print('done');

          final displayName = _displayNameController.text;
          final username = _usernameController.text;
          final bio = _bioController.text;

          await FirestoreService().updateProfile(
            username: username,
            displayName: displayName,
            bio: bio,
          );

          final updatedProfile = Repo.currentProfile
              .copyWith(username: username, displayName: displayName, bio: bio);

          return Navigator.of(context).pop(updatedProfile);
        },
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(5),
                  height: 200,
                  width: 200,
                  child: Stack(
                    children: <Widget>[
                      if (isUpdating)
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.grey),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      AvatarImage(
                        onTap: () {
                          print('prof pressed');
                          changeProfilePhoto();
                        },
                        url: Repo.currentProfile.user.photoUrl ?? '',
                        addStoryIndicatorSize: 15,
                        spacing: 4,
                      ),
                    ],
                  ),
                ),
                FlatButton(
                    onPressed: () {
                      print('edit photo pressed');
                      changeProfilePhoto();
                    },
                    child: Text(
                      'Change Photo',
                      style: TextStyles.w600Text
                          .copyWith(color: Colors.blueAccent),
                    )),
              ],
            ),
            EditListItem(
              title: 'Name',
              child: TextField(
                controller: _displayNameController,
              ),
            ),
            EditListItem(
              title: 'Username',
              child: TextField(
                controller: _usernameController,
              ),
            ),
            EditListItem(
              title: 'Bio',
              child: TextField(
                controller: _bioController,
              ),
            ),
          ],
        ),
      )),
    );
  }

  Future<void> changeProfilePhoto() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    final croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      cropStyle: CropStyle.circle,
    );

    setState(() {
      isUpdating = true;
    });
    final updatedProfile =
        await Repo.updatePhotoUrl(uid: widget.profile.uid, file: croppedFile);
    setState(() {
      isUpdating = false;
      Repo.currentProfile = updatedProfile;
    });
  }
}

class EditListItem extends StatelessWidget {
  final String title;
  final Widget child;

  const EditListItem({Key key, this.title, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Text(
              title,
              style: TextStyles.w300Display,
            ),
          ),
          SizedBox(width: 30),
          Flexible(flex: 2, child: child),
        ],
      ),
    );
  }
}
