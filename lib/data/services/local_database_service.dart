import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/message_model.dart';
import '../models/file_metadata_model.dart';
import '../models/knowledge_entry_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'manus_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        display_name TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced_at INTEGER
      )
    ''');

    // Create projects table
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Create messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        sender TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced_at INTEGER,
        FOREIGN KEY (project_id) REFERENCES projects(id)
      )
    ''');

    // Create files table
    await db.execute('''
      CREATE TABLE files (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        message_id TEXT,
        original_filename TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        mime_type TEXT NOT NULL,
        local_path TEXT,
        cloud_url TEXT,
        uploaded_at INTEGER NOT NULL,
        synced_at INTEGER,
        FOREIGN KEY (project_id) REFERENCES projects(id),
        FOREIGN KEY (message_id) REFERENCES messages(id)
      )
    ''');

    // Create knowledge_entries table
    await db.execute('''
      CREATE TABLE knowledge_entries (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT,
        tags TEXT,
        source_message_id TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced_at INTEGER,
        FOREIGN KEY (project_id) REFERENCES projects(id),
        FOREIGN KEY (source_message_id) REFERENCES messages(id)
      )
    ''');
  }

  // ============================================================================
  // USER CRUD OPERATIONS
  // ============================================================================

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================================
  // PROJECT CRUD OPERATIONS
  // ============================================================================

  Future<int> insertProject(ProjectModel project) async {
    final db = await database;
    return await db.insert(
      'projects',
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ProjectModel?> getProject(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ProjectModel.fromMap(maps.first);
  }

  Future<List<ProjectModel>> getProjectsByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
    return List.generate(maps.length, (i) => ProjectModel.fromMap(maps[i]));
  }

  Future<List<ProjectModel>> getAllProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      orderBy: 'updated_at DESC',
    );
    return List.generate(maps.length, (i) => ProjectModel.fromMap(maps[i]));
  }

  Future<int> updateProject(ProjectModel project) async {
    final db = await database;
    return await db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<int> deleteProject(String id) async {
    final db = await database;
    return await db.delete(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================================
  // MESSAGE CRUD OPERATIONS
  // ============================================================================

  Future<int> insertMessage(MessageModel message) async {
    final db = await database;
    return await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MessageModel?> getMessage(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return MessageModel.fromMap(maps.first);
  }

  Future<List<MessageModel>> getMessagesByProjectId(String projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => MessageModel.fromMap(maps[i]));
  }

  Future<List<MessageModel>> getAllMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => MessageModel.fromMap(maps[i]));
  }

  Future<int> updateMessage(MessageModel message) async {
    final db = await database;
    return await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  Future<int> deleteMessage(String id) async {
    final db = await database;
    return await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMessagesByProjectId(String projectId) async {
    final db = await database;
    return await db.delete(
      'messages',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
  }

  // ============================================================================
  // FILE CRUD OPERATIONS
  // ============================================================================

  Future<int> insertFile(FileMetadataModel file) async {
    final db = await database;
    return await db.insert(
      'files',
      file.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<FileMetadataModel?> getFile(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'files',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return FileMetadataModel.fromMap(maps.first);
  }

  Future<List<FileMetadataModel>> getFilesByProjectId(String projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'files',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'uploaded_at DESC',
    );
    return List.generate(maps.length, (i) => FileMetadataModel.fromMap(maps[i]));
  }

  Future<List<FileMetadataModel>> getFilesByMessageId(String messageId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'files',
      where: 'message_id = ?',
      whereArgs: [messageId],
      orderBy: 'uploaded_at DESC',
    );
    return List.generate(maps.length, (i) => FileMetadataModel.fromMap(maps[i]));
  }

  Future<List<FileMetadataModel>> getAllFiles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'files',
      orderBy: 'uploaded_at DESC',
    );
    return List.generate(maps.length, (i) => FileMetadataModel.fromMap(maps[i]));
  }

  Future<int> updateFile(FileMetadataModel file) async {
    final db = await database;
    return await db.update(
      'files',
      file.toMap(),
      where: 'id = ?',
      whereArgs: [file.id],
    );
  }

  Future<int> deleteFile(String id) async {
    final db = await database;
    return await db.delete(
      'files',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFilesByProjectId(String projectId) async {
    final db = await database;
    return await db.delete(
      'files',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
  }

  // ============================================================================
  // KNOWLEDGE ENTRY CRUD OPERATIONS
  // ============================================================================

  Future<int> insertKnowledgeEntry(KnowledgeEntryModel entry) async {
    final db = await database;
    return await db.insert(
      'knowledge_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<KnowledgeEntryModel?> getKnowledgeEntry(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'knowledge_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return KnowledgeEntryModel.fromMap(maps.first);
  }

  Future<List<KnowledgeEntryModel>> getKnowledgeEntriesByProjectId(
      String projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'knowledge_entries',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'created_at DESC',
    );
    return List.generate(
        maps.length, (i) => KnowledgeEntryModel.fromMap(maps[i]));
  }

  Future<List<KnowledgeEntryModel>> getKnowledgeEntriesByCategory(
      String projectId, String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'knowledge_entries',
      where: 'project_id = ? AND category = ?',
      whereArgs: [projectId, category],
      orderBy: 'created_at DESC',
    );
    return List.generate(
        maps.length, (i) => KnowledgeEntryModel.fromMap(maps[i]));
  }

  Future<List<KnowledgeEntryModel>> searchKnowledgeEntries(
      String projectId, String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'knowledge_entries',
      where: 'project_id = ? AND (title LIKE ? OR content LIKE ? OR tags LIKE ?)',
      whereArgs: [projectId, '%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return List.generate(
        maps.length, (i) => KnowledgeEntryModel.fromMap(maps[i]));
  }

  Future<List<KnowledgeEntryModel>> getAllKnowledgeEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'knowledge_entries',
      orderBy: 'created_at DESC',
    );
    return List.generate(
        maps.length, (i) => KnowledgeEntryModel.fromMap(maps[i]));
  }

  Future<int> updateKnowledgeEntry(KnowledgeEntryModel entry) async {
    final db = await database;
    return await db.update(
      'knowledge_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteKnowledgeEntry(String id) async {
    final db = await database;
    return await db.delete(
      'knowledge_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteKnowledgeEntriesByProjectId(String projectId) async {
    final db = await database;
    return await db.delete(
      'knowledge_entries',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
  }

  // ============================================================================
  // UTILITY OPERATIONS
  // ============================================================================

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('knowledge_entries');
    await db.delete('files');
    await db.delete('messages');
    await db.delete('projects');
    await db.delete('users');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
