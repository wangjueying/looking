import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/item_model.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  // 获取单例实例
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  // 获取数据库
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // 创建表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.itemsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        item_name TEXT NOT NULL,
        description TEXT,
        location TEXT,
        confidence REAL,
        is_hidden INTEGER NOT NULL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 创建索引以提高搜索性能
    await db.execute('''
      CREATE INDEX idx_item_name ON ${AppConstants.itemsTable}(item_name)
    ''');

    await db.execute('''
      CREATE INDEX idx_description ON ${AppConstants.itemsTable}(description)
    ''');

    await db.execute('''
      CREATE INDEX idx_location ON ${AppConstants.itemsTable}(location)
    ''');
  }

  // 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE ${AppConstants.itemsTable}
        ADD COLUMN is_hidden INTEGER NOT NULL DEFAULT 0
      ''');
    }
  }

  // 插入单个物品
  Future<int> insertItem(ItemModel item) async {
    final db = await database;
    return await db.insert(
      AppConstants.itemsTable,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 批量插入物品
  Future<void> insertItems(List<ItemModel> items) async {
    final db = await database;
    final batch = db.batch();

    for (final item in items) {
      batch.insert(
        AppConstants.itemsTable,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // 获取所有物品
  Future<List<ItemModel>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.itemsTable,
      where: 'is_hidden = 0',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => ItemModel.fromMap(map)).toList();
  }

  // 根据ID获取物品
  Future<ItemModel?> getItemById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.itemsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ItemModel.fromMap(maps.first);
  }

  // 搜索物品（全文搜索）
  Future<List<ItemModel>> searchItems(String query) async {
    final db = await database;
    final searchPattern = '%$query%';

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.itemsTable,
      where: 'item_name LIKE ? OR description LIKE ? OR location LIKE ?',
      whereArgs: [searchPattern, searchPattern, searchPattern],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => ItemModel.fromMap(map)).toList();
  }

  // 获取物品种类统计
  Future<Map<String, int>> getItemStats() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT item_name, COUNT(*) as count
      FROM ${AppConstants.itemsTable}
      WHERE is_hidden = 0
      GROUP BY item_name
      ORDER BY count DESC
    ''');

    return {
      for (var row in results) row['item_name'] as String: row['count'] as int,
    };
  }

  // 获取按首字母分组的物品
  Future<Map<String, List<ItemModel>>> getGroupedItems() async {
    final items = await getAllItems();
    final Map<String, List<ItemModel>> grouped = {};

    for (final item in items) {
      if (item.itemName.isNotEmpty) {
        final firstChar = item.itemName[0].toUpperCase();
        grouped.putIfAbsent(firstChar, () => []).add(item);
      }
    }

    return grouped;
  }

  // 更新物品
  Future<int> updateItem(ItemModel item) async {
    final db = await database;
    return await db.update(
      AppConstants.itemsTable,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // 删除物品
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.update(
      AppConstants.itemsTable,
      {'is_hidden': 1},
      where: 'id = ? AND is_hidden = 0',
      whereArgs: [id],
    );
  }

  // 恢复物品到清单
  Future<int> restoreItem(int id) async {
    final db = await database;
    return await db.update(
      AppConstants.itemsTable,
      {'is_hidden': 0},
      where: 'id = ? AND is_hidden = 1',
      whereArgs: [id],
    );
  }

  // 删除所有物品
  Future<int> deleteAllItems() async {
    final db = await database;
    return await db.delete(AppConstants.itemsTable);
  }

  // 获取物品总数
  Future<int> getItemCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.itemsTable} WHERE is_hidden = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 获取物品种类数
  Future<int> getItemTypeCount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(DISTINCT item_name) as count
      FROM ${AppConstants.itemsTable}
      WHERE is_hidden = 0
    ''');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
