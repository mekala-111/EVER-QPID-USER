import 'package:mocktail/mocktail.dart';

/// Lightweight stand-ins for Firebase Auth flows in unit tests.
/// Real Firebase is not initialized in `flutter test` by default.
class FakeFirebaseUser extends Fake {
  FakeFirebaseUser({this.uid = 'test-uid', this.phoneNumber = '+911234567890'});

  final String uid;
  final String? phoneNumber;
}

class FakeFirebaseAuthSession {
  FakeFirebaseUser? currentUser;
  bool signedOut = false;

  Future<void> signOut() async {
    currentUser = null;
    signedOut = true;
  }

  Future<FakeFirebaseUser> signInWithCredential() async {
    currentUser = FakeFirebaseUser();
    return currentUser!;
  }
}
