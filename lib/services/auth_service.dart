import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<void> signIn(String email, String pass) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: pass);

  Future<void> register(String email, String pass) =>
      _auth.createUserWithEmailAndPassword(email: email.trim(), password: pass);

  Future<void> google() async {
    if (kIsWeb) {
      await _auth.signInWithPopup(GoogleAuthProvider());
      return;
    }
    final u = await GoogleSignIn().signIn();
    if (u == null) return;
    final a = await u.authentication;
    await _auth.signInWithCredential(
        GoogleAuthProvider.credential(accessToken: a.accessToken, idToken: a.idToken));
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
