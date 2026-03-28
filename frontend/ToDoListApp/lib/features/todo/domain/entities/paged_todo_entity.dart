import 'todo_entity.dart';

class PagedTodoEntity {
  const PagedTodoEntity({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.items,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final List<TodoEntity> items;
}
