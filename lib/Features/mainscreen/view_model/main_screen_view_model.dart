import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreenViewModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;

  Future<bool> signOut() async {
    // Implement sign out logic here
    _auth.signOut();
    LoggedInUser.clearUserData();

    notifyListeners();
    return true;
  }
}
