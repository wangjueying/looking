import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item_model.dart';
import '../../../../core/errors/exceptions.dart';

class LocalItemDataSource {
  static const String _databaseName = 'item_tracker.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'items';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        item_name TEXT NOT NULL,
        description TEXT,
        location TEXT,
        confidence REAL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create indexes for faster search
    await db.execute('''
      CREATE INDEX idx_item_name ON $_tableName(item_name)
    ''');

    await db.execute('''
      CREATE INDEX idx_description ON $_tableName(description)
    ''');

    await db.execute('''
      CREATE INDEX idx_location ON $_tableName(location)
    ''');
  }

  Future<ItemModel> insertItem(ItemModel item) async {
    try {
      final db = await database;
      final id = await db.insert(
        _tableName,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return item.copyWith(id: id);
    } catch (e) {
      throw CacheException('Failed to insert item: ${e.toString()}');
    }
  }

  Future<List<ItemModel>> getAllItems() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => ItemModel.fromMap(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get items: ${e.toString()}');
    }
  }

  Future<ItemModel?> getItemById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return ItemModel.fromMap(maps.first);
    } catch (e) {
      throw CacheException('Failed to get item: ${e.toString()}');
    }
  }

  Future<List<ItemModel>> searchItems(String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '''
          item_name LIKE ? OR
          description LIKE ? OR
          location LIKE ?
        ''',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => ItemModel.fromMap(map)).toList();
    } catch (e) {
      throw CacheException('Failed to search items: ${e.toString()}');
    }
  }

  Future<int> deleteItem(int id) async {
    try {
      final db = await database;
      return await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException('Failed to delete item: ${e.toString()}');
    }
  }

  Future<int> deleteAllItems() async {
    try {
      final db = await database;
      return await db.delete(_tableName);
    } catch (e) {
      throw CacheException('Failed to delete all items: ${e.toString()}');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
