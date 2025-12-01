import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Register and create user document
  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;

    final appUser = AppUser(uid: uid, name: name, email: email, role: role, phone: phone, fcmToken: '');
    await _db.collection('users').doc(uid).set(appUser.toMap());
    return appUser;
  }

  // Login
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final uid = cred.user!.uid;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream of auth state + user doc
  Stream<AppUser?> userStream() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) return null;
      return AppUser.fromMap(firebaseUser.uid, doc.data()!);
    });
  }

  // Optional: fetch current user
  Future<AppUser?> currentUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    final doc = await _db.collection('users').doc(u.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(u.uid, doc.data()!);
  }
}
