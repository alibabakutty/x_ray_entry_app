import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserAccount({
    required String username,
    required String email,
    required String password,
  }) async {
    // create user in Firebase Auth
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store additional user info in Firestore
    if (userCredential.user != null) {
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<String?> getUserName(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['username'] as String?;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Re-authentication (these are extras)
  Future<void> reauthenticateWithCredential(
      {required String email, required String password}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user is currently signed in');

    // create auth credential
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    // Reauthenticate
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> updatePassword(
      {required String currentPassword, required String newPassword}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user is currently signed in');

    // first reauthenticate
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    // update password
    await user.updatePassword(newPassword);
  }

  Future<bool> checkEmailVerified() async {
    await _firebaseAuth.currentUser?.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  // modify the updateemail method to be more robust
  Future<void> updateEmail(
      {required String currentPassword, required String newEmail}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user is currently signed in');
    // first reauthenticate
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    // verify before update email
    await user.verifyBeforeUpdateEmail(newEmail);
    // Note: Don't update Firestore yet - wait for email verification
    // The email will only be updated after the user clicks the verification link
    // You should listen for auth state changes to detect when the email is actually updated
  }

  Future<void> deleteAccount({required String currentPassword}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user is currently signed in');
    // first reauthenticate
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    // delete account
    await _firestore.collection('users').doc(user.uid).delete();
    // then delete auth accounts
    await user.delete();
  }
}
