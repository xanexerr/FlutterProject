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
    );
  }

  // Create Tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');
    // Insert default admin user
    await db.insert('users', {
      'username': 'admin',      
      'password': '123'         
    });
  }

  // Insert User
  Future<int> insertUser(String username, String password) async {
    final db = await getDatabase();
    return await db.insert('users', {
      'username': username, 
      'password': password
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
}