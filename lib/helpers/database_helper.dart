import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/maintenance_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('home_care_maintenance.db');
    return _database!;
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE items ADD COLUMN brand TEXT;");
      await db.execute("ALTER TABLE items ADD COLUMN other TEXT;");
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // Mengaktifkan fitur Foreign Key Cascade di SQLite
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Hapus Barang berdasarkan ID
  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  // MEMBUAT TABEL-TABEL
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        brand TEXT,
        location TEXT,
        photo_path TEXT,
        other TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        task_name TEXT NOT NULL,
        interval_months INTEGER NOT NULL,
        next_due_date TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE service_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        service_date TEXT NOT NULL,
        cost REAL DEFAULT 0,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (task_id) REFERENCES maintenance_tasks (id) ON DELETE CASCADE
      )
    ''');

    // Insert Default Categories
    await db.rawInsert(
      "INSERT INTO categories (name) VALUES ('Elektronik'), ('Kendaraan'), ('Dapur'), ('Plumbing')",
    );
  }

  // ==========================================
  // OPERASI CRUD: CATEGORIES
  // ==========================================
  Future<int> insertCategory(Category category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Cek apakah ada barang yang menggunakan categoryId ini
  Future<int> getItemCountByCategory(int categoryId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM items WHERE category_id = ?',
      [categoryId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // OPERASI CRUD: ITEMS
  // ==========================================
  Future<int> insertItem(Item item) async {
    final db = await instance.database;
    return await db.insert('items', item.toMap());
  }

  Future<List<Item>> getItemsByCategory(int categoryId) async {
    final db = await instance.database;
    final result = await db.query(
      'items',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'id DESC',
    );
    return result.map((map) => Item.fromMap(map)).toList();
  }

  Future<List<Item>> getAllItems() async {
    final db = await instance.database;
    final result = await db.query('items', orderBy: 'id DESC');
    return result.map((map) => Item.fromMap(map)).toList();
  }

  Future<int> updateItem(Item item) async {
    final db = await instance.database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // ==========================================
  // OPERASI CRUD: MAINTENANCE TASKS
  // ==========================================
  Future<int> insertTask(MaintenanceTask task) async {
    final db = await instance.database;
    return await db.insert('maintenance_tasks', task.toMap());
  }

  Future<List<MaintenanceTask>> getTasksByItem(int itemId) async {
    final db = await instance.database;
    final result = await db.query(
      'maintenance_tasks',
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
    return result.map((map) => MaintenanceTask.fromMap(map)).toList();
  }

  // ==========================================
  // OPERASI EXECUTE MAINTENANCE & LOG HISTORI
  // ==========================================
  // Fungsi ini dipanggil saat user menekan "Tandai Selesai Servis"
  Future<void> completeTaskAndLog({
    required MaintenanceTask task,
    required String serviceDate,
    required double cost,
    String? notes,
  }) async {
    final db = await instance.database;

    // 1. Simpan ke Riwayat (service_logs)
    final log = ServiceLog(
      taskId: task.id!,
      serviceDate: serviceDate,
      cost: cost,
      notes: notes,
    );
    await db.insert('service_logs', log.toMap());

    // 2. Hitung tanggal next_due_date berikutnya berdasarkan interval bulan
    DateTime currentDueDate = DateTime.parse(serviceDate);
    DateTime newDueDate = DateTime(
      currentDueDate.year,
      currentDueDate.month + task.intervalMonths,
      currentDueDate.day,
    );
    String formattedNextDueDate = newDueDate.toIso8601String().split('T')[0];

    // 3. Update tanggal servis berikutnya pada tabel maintenance_tasks
    await db.update(
      'maintenance_tasks',
      {'next_due_date': formattedNextDueDate},
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Ambil semua histori servis berdasarkan Task ID
  Future<List<ServiceLog>> getServiceLogsByTask(int taskId) async {
    final db = await instance.database;
    final result = await db.query(
      'service_logs',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'service_date DESC',
    );
    return result.map((map) => ServiceLog.fromMap(map)).toList();
  }
}
