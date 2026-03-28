import '../../domain/entities/paged_todo_entity.dart';
import '../../domain/entities/todo_entity.dart';

class TodoModel {
  const TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.priority,
    this.categoryName,
    this.categoryId,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String priority;
  final String? categoryName;
  final String? categoryId;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      isCompleted: (json['isCompleted'] ?? false) as bool,
      priority: (json['priority'] ?? '').toString(),
      categoryName: json['categoryName']?.toString(),
      categoryId: json['categoryId']?.toString(),
      dueDate: DateTime.tryParse((json['dueDate'] ?? '').toString()),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority,
      'categoryName': categoryName,
      'categoryId': categoryId,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      priority: priority,
      categoryName: categoryName,
      categoryId: categoryId,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static PagedTodoEntity parsePaged(dynamic raw) {
    final map = raw as Map<String, dynamic>;
    final itemsRaw = (map['items'] as List<dynamic>? ?? []);
    final items = itemsRaw
        .map((e) => TodoModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();

    return PagedTodoEntity(
      page: (map['page'] ?? 1) as int,
      pageSize: (map['pageSize'] ?? 10) as int,
      totalItems: (map['totalItems'] ?? 0) as int,
      totalPages: (map['totalPages'] ?? 0) as int,
      items: items,
    );
  }
}
