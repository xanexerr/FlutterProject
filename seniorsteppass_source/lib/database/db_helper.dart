import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;
  
  // Check and get Database
  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    
    _database = await _initDB();
    return _database!;
  }

  // Create Database Schema
  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'seniorsteppass.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) =>  db.execute('PRAGMA foreign_keys = ON'), // Enable foreign key constraints
    );
  }

  // Create Tables
  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,        -- for login
        password TEXT NOT NULL,               -- for login
        full_name TEXT,                       -- display name on project cards
        email TEXT UNIQUE,
        office_id TEXT,                       -- ex. 6787086 
        role TEXT CHECK(role IN ('Student', 'Instructor', 'Staff', 'Admin')) DEFAULT 'Student',  -- user role
        department TEXT,                      -- ex. ICT / DST (student)
        profile_pic TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    // Insert default admin user
    await db.insert('users', {
      'username': 'admin',      
      'password': '123',
      'full_name': 'Admin User',
      'email': 'admin@example.com',
      'office_id': '6787086',
      'role': 'Admin',
      'department': null,
      'profile_pic': null,
    });


  // Projects pages
    // Create projects table
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT DEFAULT 'Developing',
        img_url TEXT
      )
    ''');

    // Create tags table
    await db.execute('''
      CREATE TABLE project_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        tag_name TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    // Create team members table
    await db.execute('''
      CREATE TABLE project_team (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        member_id INTEGER NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
        FOREIGN KEY (member_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // Insert User
  Future<int> insertUser({
    required String username,
    required String password,
    String? fullName,
    String? email,
    String? officeId,
    String role = 'Student',
    String? department,
  }) async {
    final db = await getDatabase();
    return await db.insert('users', {
      'username': username, 
      'password': password,
      'full_name': fullName,
      'email': email,
      'office_id': officeId,
      'role': role,
      'department': department,
    });
  }
  
  // Login User
  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await getDatabase();
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
  
  // Update User Profile
  Future<int> updateUserProfile(int userId, {
    required String fullName,
    required String email,
    required String officeId,
    required String role,
    String? department,
  }) async {
    final db = await getDatabase();
    return await db.update(
      'users',
      {
        'full_name': fullName,
        'email': email,
        'office_id': officeId,
        'role': role,
        'department': department,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Get projects info (Tags + Team members)
  Future<Map<String, dynamic>> getProjectDetails(int projectId) async {
    final db = await getDatabase();

    // Get project info
    final projectResult = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [projectId],
    );

    if (projectResult.isEmpty) return {};

    final projectInfo = projectResult.first;

    // Get tags
    final tagsResult = await db.query(
      'project_tags',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
    final tags = tagsResult.map((e) => e['tag_name'] as String).toList();

    // Get team members
    final teamResult = await db.rawQuery('''
      SELECT users.full_name, users.email 
      FROM project_team 
      JOIN users ON project_team.member_id = users.id 
      WHERE project_team.project_id = ?
    ''', [projectId]);
    
    return {
      'project': projectInfo,
      'tags': tags,
      'team': teamResult,
    };
  }
}