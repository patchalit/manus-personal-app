import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmailPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Firestore - Users
  CollectionReference get usersCollection => _firestore.collection('users');

  // Firestore - Projects
  CollectionReference get projectsCollection =>
      _firestore.collection('projects');

  // Firestore - Messages
  CollectionReference get messagesCollection =>
      _firestore.collection('messages');

  // Firestore - Files
  CollectionReference get filesCollection => _firestore.collection('files');

  // Firestore - Knowledge Entries
  CollectionReference get knowledgeEntriesCollection =>
      _firestore.collection('knowledge_entries');

  // Storage
  Reference storageRef(String path) => _storage.ref(path);

  // Detailed CRUD operations will be implemented in Phase 4
}
