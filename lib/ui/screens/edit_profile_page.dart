import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutes/core/events/events.dart';
import 'package:nutes/core/services/events.dart';
import 'package:nutes/ui/screens/change_bio_screen.dart';
import 'package:nutes/ui/screens/change_email_sceen.dart';
import 'package:nutes/ui/screens/change_username_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/logos.dart';
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

  bool isUpdatingPhoto = false;
  bool isUpdatingProfile = false;

  final auth = Repo.auth;
  UserProfile profile;

  bool isLoadingPrivateInfo = false;

//  UserProfile profile;

  @override
  void initState() {
    profile = widget.profile;
    _usernameController.text = profile.user.username;
    _displayNameController.text = profile.user.displayName;
    _bioController.text = profile.bio;

    _emailController.addListener(() {
      final emailText = _emailController.text;
      print(emailText);
    });

    _getEmail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            eventBus.fire(ProfileUpdateEvent(profile));
            return Navigator.of(context).pop();
          },
          color: Colors.black,
          tooltip: 'Cancel',
        ),
        title: NutesLogoPlain(),
        trailing: Tooltip(
          message: "Done",
          child: isUpdatingProfile
              ? LoadingIndicator()
              : FlatButton(
                  child: Text(
                    'Done',
                    style: TextStyles.defaultText
                        .copyWith(color: Colors.blueAccent),
                  ),
                  onPressed: () async {
                    final displayName = _displayNameController.text;
                    final username = _usernameController.text;
                    final bio = _bioController.text;

                    setState(() {
                      isUpdatingProfile = true;
                    });

                    await FirestoreService().updateProfile(
                      username: username,
                      displayName: displayName,
                      bio: bio,
                    );

                    final updatedProfile = auth.copyWith(
                        username: username, displayName: displayName, bio: bio);

                    setState(() {
                      isUpdatingProfile = false;
                    });

                    eventBus.fire(ProfileUpdateEvent(updatedProfile));

                    return Navigator.of(context).pop(updatedProfile);
                  },
                ),
        ),
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
                      if (isUpdatingPhoto)
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
              controller: _usernameController..text = profile.user.username,
              onTap: () async {
                final result = await Navigator.push(
                    context, ChangeUsernameScreen.route(profile));

                if (result is UserProfile) {
                  setState(() {
                    profile = result;
                  });
                }
              },
            ),
            EditListItem(
              maxLines: 2,
              title: 'Bio',
              controller: _bioController..text = profile.bio,
              readOnly: true,
              onTap: () async {
                final prof = await Navigator.push(
                    context, ChangeBioScreen.route(profile));

                if (prof is UserProfile)
                  setState(() {
                    profile = prof;
                  });
              },
            ),

            SizedBox(height: 8),

            ///Private

            if (isLoadingPrivateInfo)
              LoadingIndicator(),
            if (!isLoadingPrivateInfo)
              EditListItem(
                title: 'Email',
                controller: _emailController,
                readOnly: true,
                onTap: () async {
                  final email = await Navigator.push(
                      context, ChangeEmailScreen.route(_emailController.text));

                  if (email is String) {
                    if (email.isNotEmpty)
                      setState(() {
                        _emailController.text = email;
                      });
                  }
                },
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
      isUpdatingPhoto = true;
    });
    final updatedProfile = await Repo.removeCurrentPhoto();
    setState(() {
      isUpdatingPhoto = false;
      profile = updatedProfile;
    });

    eventBus.fire(ProfileUpdateEvent(updatedProfile));
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
      isUpdatingPhoto = true;
    });
    final updatedProfile =
        await Repo.updatePhotoUrl(uid: widget.profile.uid, original: cropped);

    setState(() {
      isUpdatingPhoto = false;
      profile = updatedProfile;
//      profile = updatedProfile;
    });

    eventBus.fire(ProfileUpdateEvent(updatedProfile));
  }

  Future<void> _getEmail() async {
    setState(() {
      isLoadingPrivateInfo = true;
    });

//    final result = await Repo.getMyInfo();

    final email = await Repo.getMyEmail();

    setState(() {
      isLoadingPrivateInfo = false;
//      _emailController.text = result['email'] ?? 'HAHA';
      _emailController.text = email;
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
  final int maxLines;
  final int maxLength;

  const EditListItem({
    Key key,
    this.title,
    this.child,
    this.controller,
    this.readOnly = false,
    this.hint = '',
    this.onTap,
    this.maxLines = 1,
    this.maxLength = 150,
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
                maxLength: 150,
                maxLines: maxLines,
                readOnly: readOnly,
                controller: controller,
                onTap: onTap,
                decoration: InputDecoration(
                  counterText: '',
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
