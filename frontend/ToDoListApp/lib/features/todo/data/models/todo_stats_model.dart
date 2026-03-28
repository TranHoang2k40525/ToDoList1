import '../../domain/entities/todo_stats_entity.dart';

class TodoStatsModel {
  const TodoStatsModel({
    required this.total,
    required this.completed,
    required this.overdue,
    required this.byCategory,
  });

  final int total;
  final int completed;
  final int overdue;
  final List<CategoryTodoCountEntity> byCategory;

  factory TodoStatsModel.fromJson(Map<String, dynamic> json) {
    final byCategoryRaw = (json['byCategory'] as List<dynamic>? ?? []);
    final byCategory = byCategoryRaw.map((e) {
      final item = e as Map<String, dynamic>;
      return CategoryTodoCountEntity(
        categoryId: item['categoryId']?.toString(),
        categoryName: (item['categoryName'] ?? 'Uncategorized').toString(),
        count: (item['count'] ?? 0) as int,
      );
    }).toList();

    return TodoStatsModel(
      total: (json['total'] ?? 0) as int,
      completed: (json['completed'] ?? 0) as int,
      overdue: (json['overdue'] ?? 0) as int,
      byCategory: byCategory,
    );
  }

  TodoStatsEntity toEntity() {
    return TodoStatsEntity(
      total: total,
      completed: completed,
      overdue: overdue,
      byCategory: byCategory,
    );
  }
}
