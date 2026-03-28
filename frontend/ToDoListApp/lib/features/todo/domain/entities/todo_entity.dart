class TodoEntity {
  const TodoEntity({
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
}
