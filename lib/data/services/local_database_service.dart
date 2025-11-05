import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  // CRUD operations will be implemented in Phase 3
  // - insertUser, getUser, updateUser, deleteUser
  // - insertProject, getProjects, updateProject, deleteProject
  // - insertMessage, getMessages, updateMessage, deleteMessage
  // - insertFile, getFiles, updateFile, deleteFile
  // - insertKnowledgeEntry, getKnowledgeEntries, updateKnowledgeEntry, deleteKnowledgeEntry

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
