import 'package:firebase_auth/firebase_auth.dart';

class AuthModel {
  final String uid;
  final String? phoneNumber;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isEmailVerified;

  AuthModel({
    required this.uid,
    this.phoneNumber,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isEmailVerified = false,
  });

  factory AuthModel.fromFirebase(User? user) {
    return AuthModel(
      uid: user?.uid ?? '',
      phoneNumber: user?.phoneNumber,
      displayName: user?.displayName,
      email: user?.email,
      photoUrl: user?.photoURL,
      isEmailVerified: user?.emailVerified ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
    };
  }
}
