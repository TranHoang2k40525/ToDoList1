class TodoQueryEntity {
  const TodoQueryEntity({
    this.isCompleted,
    this.priority,
    this.categoryId,
    this.keyword,
    this.dueFrom,
    this.dueTo,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
    this.page = 1,
    this.pageSize = 10,
  });

  final bool? isCompleted;
  final int? priority;
  final String? categoryId;
  final String? keyword;
  final DateTime? dueFrom;
  final DateTime? dueTo;
  final String sortBy;
  final String sortOrder;
  final int page;
  final int pageSize;
}
