import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/view_models/comment_model.dart';
import 'package:nutes/core/view_models/feed_model.dart';
import 'package:nutes/core/view_models/home_model.dart';
import 'package:nutes/core/view_models/login_model.dart';
import 'package:nutes/core/view_models/profile_model.dart';
import 'package:nutes/core/view_models/upload_model.dart';

GetIt locator = GetIt.instance;

void setUpLocator() {
  locator.registerSingleton(FirebaseAuth.instance);
//  locator.registerSingleton(HomeModel());
  locator.registerSingleton(RouteObserver<PageRoute>());
  locator.registerFactory(() => HomeModel());
  locator.registerFactory(() => LoginModel());
  locator.registerFactory(() => FeedModel());
  locator.registerFactory(() => ProfileModel());
  locator.registerLazySingleton(() => FirestoreService());
  locator.registerFactory(() => UploadModel());
  locator.registerFactory(() => CommentModel());
}
