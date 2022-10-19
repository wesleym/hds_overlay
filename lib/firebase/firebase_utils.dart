import 'package:firebase/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hds_overlay/controllers/connection_controller.dart';

class FirebaseUtils {
  final ConnectionController connectionController = Get.find();
  late final auth;

  void init() {
    if (apps.isEmpty) {
      final dbUrl;
      if (kDebugMode) {
        dbUrl = 'http://localhost:9000/?ns=health-data-server-default-rtdb';
      } else {
        dbUrl =
            'https://wesleys-health-data-server-default-rtdb.firebaseio.com';
      }
      initializeApp(
        apiKey: "AIzaSyA6n7zUD4CQ_lwPwz4_usGYcVGEcyH83vQ",
        authDomain: "wesleys-health-data-server.firebaseapp.com",
        databaseURL: dbUrl,
        projectId: "wesleys-health-data-server",
        storageBucket: "wesleys-health-data-server.appspot.com",
        messagingSenderId: "338831917267",
        appId: "1:338831917267:web:d1739010022ea3e1915426",
        measurementId: "G-8Y6ESLMMEM",
      );
    }

    auth = FirebaseAuth.instance;
    if (kDebugMode) {
      auth.useEmulator("http://localhost:9099");
    }
  }

  Future<void> signIn() async {
    print('Starting Firebase authorization');
    if (auth.currentUser == null) {
      print('Not authenticated, signing in');
      await auth.signInAnonymously();
      print('User is authenticated as: ${auth.currentUser?.uid}');
    } else {
      print('User is already authenticated');
    }
  }

  Future<String> getIdToken() async {
    return await auth.currentUser?.getIdToken(true) ?? '';
  }
}
