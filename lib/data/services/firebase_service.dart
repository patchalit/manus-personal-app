import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/message_model.dart';
import '../models/file_metadata_model.dart';
import '../models/knowledge_entry_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== Authentication ====================
  
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
      String email, String password, String displayName) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Update display name
    await credential.user?.updateDisplayName(displayName);
    
    // Create user document in Firestore
    if (credential.user != null) {
      await createUserDocument(credential.user!.uid, email, displayName);
    }
    
    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ==================== Users ====================
  
  CollectionReference get usersCollection => _firestore.collection('users');

  Future<void> createUserDocument(String uid, String email, String displayName) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await usersCollection.doc(uid).set({
      'id': uid,
      'email': email,
      'display_name': displayName,
      'created_at': now,
      'updated_at': now,
      'synced_at': now,
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await usersCollection.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await usersCollection.doc(user.id).update({
      'display_name': user.displayName,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
      'synced_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ==================== Projects ====================
  
  CollectionReference get projectsCollection => _firestore.collection('projects');

  Future<void> syncProject(ProjectModel project) async {
    await projectsCollection.doc(project.id).set({
      'id': project.id,
      'user_id': project.userId,
      'name': project.name,
      'created_at': project.createdAt.millisecondsSinceEpoch,
      'updated_at': project.updatedAt.millisecondsSinceEpoch,
      'synced_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<ProjectModel>> getUserProjects(String userId) async {
    final snapshot = await projectsCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => ProjectModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteProject(String projectId) async {
    await projectsCollection.doc(projectId).delete();
    
    // Delete related messages
    final messagesSnapshot = await messagesCollection
        .where('project_id', isEqualTo: projectId)
        .get();
    for (var doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }
    
    // Delete related knowledge entries
    final knowledgeSnapshot = await knowledgeEntriesCollection
        .where('project_id', isEqualTo: projectId)
        .get();
    for (var doc in knowledgeSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // ==================== Messages ====================
  
  CollectionReference get messagesCollection => _firestore.collection('messages');

  Future<void> syncMessage(MessageModel message) async {
    await messagesCollection.doc(message.id).set({
      'id': message.id,
      'project_id': message.projectId,
      'sender': message.sender,
      'content': message.content,
      'created_at': message.createdAt.millisecondsSinceEpoch,
      'updated_at': message.updatedAt.millisecondsSinceEpoch,
      'synced_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<MessageModel>> getProjectMessages(String projectId) async {
    final snapshot = await messagesCollection
        .where('project_id', isEqualTo: projectId)
        .orderBy('created_at', descending: false)
        .get();
    
    return snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<MessageModel>> watchProjectMessages(String projectId) {
    return messagesCollection
        .where('project_id', isEqualTo: projectId)
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ==================== Files ====================
  
  CollectionReference get filesCollection => _firestore.collection('files');

  Future<String> uploadFile(File file, String projectId, String messageId) async {
    final fileName = file.path.split('/').last;
    final ref = _storage.ref().child('projects/$projectId/$messageId/$fileName');
    
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();
    
    return downloadUrl;
  }

  Future<void> syncFileMetadata(FileMetadataModel fileMetadata) async {
    await filesCollection.doc(fileMetadata.id).set({
      'id': fileMetadata.id,
      'project_id': fileMetadata.projectId,
      'message_id': fileMetadata.messageId,
      'original_filename': fileMetadata.originalFilename,
      'file_size': fileMetadata.fileSize,
      'mime_type': fileMetadata.mimeType,
      'local_path': fileMetadata.localPath,
      'cloud_url': fileMetadata.cloudUrl,
      'uploaded_at': fileMetadata.uploadedAt.millisecondsSinceEpoch,
      'synced_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<FileMetadataModel>> getProjectFiles(String projectId) async {
    final snapshot = await filesCollection
        .where('project_id', isEqualTo: projectId)
        .orderBy('uploaded_at', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => FileMetadataModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ==================== Knowledge Entries ====================
  
  CollectionReference get knowledgeEntriesCollection =>
      _firestore.collection('knowledge_entries');

  Future<void> syncKnowledgeEntry(KnowledgeEntryModel entry) async {
    await knowledgeEntriesCollection.doc(entry.id).set({
      'id': entry.id,
      'project_id': entry.projectId,
      'title': entry.title,
      'content': entry.content,
      'category': entry.category,
      'tags': entry.tags,
      'source_message_id': entry.sourceMessageId,
      'created_at': entry.createdAt.millisecondsSinceEpoch,
      'updated_at': entry.updatedAt.millisecondsSinceEpoch,
      'synced_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<KnowledgeEntryModel>> getProjectKnowledgeEntries(String projectId) async {
    final snapshot = await knowledgeEntriesCollection
        .where('project_id', isEqualTo: projectId)
        .orderBy('created_at', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => KnowledgeEntryModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteKnowledgeEntry(String entryId) async {
    await knowledgeEntriesCollection.doc(entryId).delete();
  }

  Stream<List<KnowledgeEntryModel>> watchProjectKnowledgeEntries(String projectId) {
    return knowledgeEntriesCollection
        .where('project_id', isEqualTo: projectId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => KnowledgeEntryModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ==================== Sync Operations ====================
  
  Future<void> syncAllLocalData(String userId) async {
    // This will be called to sync all local SQLite data to Firestore
    // Implementation will be in the providers
  }

  Future<void> downloadAllCloudData(String userId) async {
    // This will be called to download all Firestore data to local SQLite
    // Implementation will be in the providers
  }
}
