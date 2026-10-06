// 1. MODEL CATEGORY
class Category {
  final int? id;
  final String name;

  Category({this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'] as int?, name: map['name'] as String);
  }
}

// 2. MODEL ITEM (Ditingkatkan dengan List<MaintenanceTask>)
class Item {
  final int? id;
  final int categoryId;
  final String name;
  final String? brand;
  final String? location;
  final String? photoPath;
  final String? createdAt;
  final String? other;

  // OPTIONAL: Menampung daftar task langsung di objek Item untuk kemudahan UI
  final List<MaintenanceTask> tasks;

  Item({
    this.id,
    required this.categoryId,
    required this.name,
    this.brand,
    this.location,
    this.photoPath,
    this.createdAt,
    this.other,
    this.tasks = const [], // Default list kosong
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'category_id': categoryId,
    'name': name,
    'brand': brand,
    'location': location,
    'photo_path': photoPath,
    'other': other,
  };

  factory Item.fromMap(
    Map<String, dynamic> map, {
    List<MaintenanceTask> tasks = const [],
  }) {
    return Item(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      brand: map['brand'] as String?,
      location: map['location'] as String?,
      photoPath: map['photo_path'] as String?,
      createdAt: map['created_at'] as String?,
      other: map['other'] as String?,
      tasks: tasks,
    );
  }

  // Metode copyWith untuk mempermudah update state di Flutter
  Item copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? brand,
    String? location,
    String? photoPath,
    String? createdAt,
    String? other,
    List<MaintenanceTask>? tasks,
  }) {
    return Item(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      location: location ?? this.location,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      other: other ?? this.other,
      tasks: tasks ?? this.tasks,
    );
  }
}

// 3. MODEL MAINTENANCE TASK
class MaintenanceTask {
  final int? id;
  final int itemId;
  final String taskName; // Cth: "Cuci AC" atau "Isi Freon"
  final int intervalMonths;
  final String nextDueDate; // Format YYYY-MM-DD
  // final bool isCompleted; // Fitur opsional status penanda

  MaintenanceTask({
    this.id,
    required this.itemId,
    required this.taskName,
    required this.intervalMonths,
    required this.nextDueDate,
    // this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'item_id': itemId,
    'task_name': taskName,
    'interval_months': intervalMonths,
    'next_due_date': nextDueDate,
    // 'is_completed': isCompleted ? 1 : 0,
  };

  factory MaintenanceTask.fromMap(Map<String, dynamic> map) {
    return MaintenanceTask(
      id: map['id'] as int?,
      itemId: map['item_id'] as int,
      taskName: map['task_name'] as String,
      intervalMonths: map['interval_months'] as int,
      nextDueDate: map['next_due_date'] as String,
      // isCompleted: (map['is_completed'] ?? 0) == 1,
    );
  }
}

// 4. MODEL SERVICE LOG (HISTORI)
class ServiceLog {
  final int? id;
  final int taskId;
  final String serviceDate;
  final double cost;
  final String? notes;
  final String? createdAt;

  ServiceLog({
    this.id,
    required this.taskId,
    required this.serviceDate,
    this.cost = 0.0,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'task_id': taskId,
    'service_date': serviceDate,
    'cost': cost,
    'notes': notes,
  };

  factory ServiceLog.fromMap(Map<String, dynamic> map) {
    return ServiceLog(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      serviceDate: map['service_date'] as String,
      cost: (map['cost'] as num).toDouble(),
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}

// Model bantuan sederhana (atau tempatkan di luar class _ItemDetailScreenState)
class LogWithTaskName {
  final ServiceLog log;
  final String taskName;

  LogWithTaskName({required this.log, required this.taskName});
}
