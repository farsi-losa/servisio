// 1. MODEL CATEGORY
class Category {
  final int? id;
  final String name;

  Category({this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'], name: map['name']);
  }
}

// 2. MODEL ITEM
class Item {
  final int? id;
  final int categoryId;
  final String name;
  final String? brand;
  final String? location;
  final String? photoPath;
  final String? createdAt;
  final String? other;

  Item({
    this.id,
    required this.categoryId,
    required this.name,
    this.brand,
    this.location,
    this.photoPath,
    this.createdAt,
    this.other,
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

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      categoryId: map['category_id'],
      name: map['name'],
      brand: map['brand'],
      location: map['location'],
      photoPath: map['photo_path'],
      createdAt: map['created_at'],
      other: map['other'],
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

  MaintenanceTask({
    this.id,
    required this.itemId,
    required this.taskName,
    required this.intervalMonths,
    required this.nextDueDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'item_id': itemId,
    'task_name': taskName,
    'interval_months': intervalMonths,
    'next_due_date': nextDueDate,
  };

  factory MaintenanceTask.fromMap(Map<String, dynamic> map) {
    return MaintenanceTask(
      id: map['id'],
      itemId: map['item_id'],
      taskName: map['task_name'],
      intervalMonths: map['interval_months'],
      nextDueDate: map['next_due_date'],
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
      id: map['id'],
      taskId: map['task_id'],
      serviceDate: map['service_date'],
      cost: (map['cost'] as num).toDouble(),
      notes: map['notes'],
      createdAt: map['created_at'],
    );
  }
}
