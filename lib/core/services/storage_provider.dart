import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:nutes/utils/image_file_bundle.dart';

class FIRStorage {
  static final storage = FirebaseStorage.instance.ref();
  final usersRef = storage.child('users');
  final chatsRef = storage.child('chats');

  Future<String> uploadChatImage(
      {@required String chatId, @required File file}) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final originalRef = chatsRef.child(chatId).child(fileName);
    final uploadTask = originalRef.putFile(file);
    final c = await uploadTask.onComplete;
    final String url = await c.ref.getDownloadURL();
    return url;
  }

  Future<String> uploadPhoto(
      {@required String uid, @required File file}) async {
    final originalRef = usersRef.child(uid).child('photo.jpg');
    final uploadTask = originalRef.putFile(file);
    final c = await uploadTask.onComplete;
    final String url = await c.ref.getDownloadURL();
    return url;
  }

  Future<String> uploadStoryFiles({
    @required String storyId,
    @required String uid,
    @required ImageFileBundle fileBundle,
  }) async {
    print('upload started');

    final postRef = usersRef.child(uid).child('stories').child(storyId);

    final urlRef = postRef.child('url');

    final url = await _upload(ref: urlRef, file: fileBundle.original);

    print('upload finished');
    return url;
  }

  Future getDownloadUrl(String postId) {}

  ///Uploads a list of files to storage
  ///Returns a list of urls upon upload completion
  Future<ImageUrlBundle> uploadPostFiles({
    @required String postId,
    @required int index,
    @required String uid,
    @required ImageFileBundle fileBundle,
  }) async {
    print('upload started');

    final postRef = usersRef
        .child(uid)
        .child('posts')
        .child(postId)
        .child(index.toString());

    final originalRef = postRef.child('original');
    final mediumRef = postRef.child('medium');
    final smallRef = postRef.child('small');

    final urls = await Future.wait([
      _upload(ref: originalRef, file: fileBundle.original),
      _upload(ref: mediumRef, file: fileBundle.medium),
      _upload(ref: smallRef, file: fileBundle.small),
    ]);

    print('upload finished');
    return ImageUrlBundle(
      index: index,
      aspectRatio: fileBundle.aspectRatio,
      original: urls[0],
      medium: urls[1],
      small: urls[2],
    );
  }

  Future<String> _upload(
      {@required StorageReference ref, @required File file}) async {
    final snap = await ref.putFile(file).onComplete;
    final String url = await snap.ref.getDownloadURL();
    return url;
  }
}
