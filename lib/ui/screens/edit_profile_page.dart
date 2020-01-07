import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/ui/screens/change_username_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/styles.dart';
//import 'package:image_cropper/image_cropper.dart';

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
  final _emailController = TextEditingController();
  bool isUpdating = false;

  final auth = Repo.auth;
  UserProfile profile;

//  UserProfile profile;

  @override
  void initState() {
    profile = widget.profile;
    _usernameController.text = auth.user.username;
    _displayNameController.text = auth.user.displayName;
    _bioController.text = auth.bio;
    _emailController.text = auth.user.username;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

          final updatedProfile = auth.copyWith(
              username: username, displayName: displayName, bio: bio);

          return Navigator.of(context).pop(updatedProfile);
        },
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ///Avatar
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(4),
                  height: 200,
                  width: 200,
                  child: Stack(
                    children: <Widget>[
                      if (isUpdating)
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.grey),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      Positioned.fill(
                        child: AvatarImage(
                          onTap: () => _showModalPopup(context),
                          url: profile.user.urls.original ?? '',
                          addStoryIndicatorSize: 15,
                          spacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                FlatButton(
                    onPressed: () => _showModalPopup(context),
                    child: Text(
                      'Change Photo',
                      style: TextStyles.w600Text
                          .copyWith(color: Colors.blueAccent),
                    )),
              ],
            ),

            ///Public info
            EditListItem(
              title: 'Name',
              controller: _displayNameController,
              hint: 'Enter a display name',
            ),
            EditListItem(
              title: 'Username',
              readOnly: true,
              controller: _usernameController,
              onTap: () =>
                  Navigator.push(context, ChangeUsernameScreen.route(profile)),
            ),
            EditListItem(
              title: 'Bio',
              controller: _bioController,
            ),

            SizedBox(height: 8),

            ///Private
            ///TODO: figure out how to get email
//            LargeHeader(title: 'Private information'),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Text(
//                'Private info',
//                style: TextStyles.w600Display,
//              ),
//            ),
            EditListItem(
              title: 'Email',
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration.collapsed(hintText: 'Enter email'),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Future _showModalPopup(BuildContext context) {
    return showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text('Remove Current Photo',
                    style: TextStyles.defaultDisplay.copyWith(
                      color: Colors.red,
                    )),
                onPressed: () {
                  removeCurrentPhoto();
                  return Navigator.pop(context);
                },
              ),
              CupertinoActionSheetAction(
                child: Text('Choose from Library',
                    style: TextStyles.defaultDisplay),
                onPressed: () {
                  pickImageFromLibrary();
                  return Navigator.pop(context);
                },
              ),
            ],
            cancelButton: FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyles.defaultDisplay),
            ),
          );
        });
  }

  Future removeCurrentPhoto() async {
    setState(() {
      isUpdating = true;
    });
    final updatedProfile = await Repo.removeCurrentPhoto();
    setState(() {
      isUpdating = false;
      profile = updatedProfile;
    });
  }

  Future<void> pickImageFromLibrary() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    final cropped = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      cropStyle: CropStyle.circle,
      maxHeight: 600,
      maxWidth: 600,
    );

    ///If cancelled image picking and/or image cropping
    if (cropped == null) return;

    setState(() {
      isUpdating = true;
    });
    final updatedProfile =
        await Repo.updatePhotoUrl(uid: widget.profile.uid, original: cropped);

    setState(() {
      isUpdating = false;
      profile = updatedProfile;
//      profile = updatedProfile;
    });
  }
}

class EditListItem extends StatelessWidget {
  final String title;
  final Widget child;
  final TextEditingController controller;

  final bool readOnly;
  final String hint;

  final VoidCallback onTap;

  const EditListItem({
    Key key,
    this.title,
    this.child,
    this.controller,
    this.readOnly = false,
    this.hint = '',
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Text(
              title,
              style: TextStyles.defaultText.copyWith(color: Colors.grey),
            ),
          ),
          SizedBox(width: 16),
          Flexible(
              flex: 2,
              child: TextField(
                readOnly: readOnly,
                controller: controller,
                onTap: onTap,
                decoration: InputDecoration(
                  hintText: hint,
//                  filled: true,
//                  fillColor: Colors.grey[200],
//                  border: OutlineInputBorder(
//                    borderRadius: BorderRadius.circular(16),
//                    borderSide: BorderSide(
//                      width: 0,
//                      style: BorderStyle.none,
//                    ),
//                  ),
                ),
              )),
        ],
      ),
    );
  }
}
