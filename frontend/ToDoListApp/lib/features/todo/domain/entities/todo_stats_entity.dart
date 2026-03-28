class CategoryTodoCountEntity {
  const CategoryTodoCountEntity({
    required this.categoryId,
    required this.categoryName,
    required this.count,
  });

  final String? categoryId;
  final String categoryName;
  final int count;
}

class TodoStatsEntity {
  const TodoStatsEntity({
    required this.total,
    required this.completed,
    required this.overdue,
    required this.byCategory,
  });

  final int total;
  final int completed;
  final int overdue;
  final List<CategoryTodoCountEntity> byCategory;
}
