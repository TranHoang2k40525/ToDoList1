import '../entities/category_entity.dart';
import '../entities/paged_todo_entity.dart';
import '../entities/todo_entity.dart';
import '../entities/todo_query_entity.dart';
import '../entities/todo_stats_entity.dart';

abstract class TodoRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<CategoryEntity> createCategory({
    required String name,
    String? icon,
    String? colorHex,
  });
  Future<CategoryEntity> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? colorHex,
  });
  Future<void> deleteCategory(String id);

  Future<PagedTodoEntity> getTodos(TodoQueryEntity query);
  Future<TodoEntity> getTodoDetail(String id);
  Future<TodoEntity> createTodo({
    required String title,
    required String description,
    required int priority,
    DateTime? dueDate,
    String? categoryId,
  });
  Future<TodoEntity> updateTodo({
    required String id,
    required String title,
    required String description,
    required int priority,
    DateTime? dueDate,
    String? categoryId,
    bool? isCompleted,
  });
  Future<void> toggleTodoStatus(String id);
  Future<void> deleteTodo(String id);
  Future<TodoStatsEntity> getStats();
}
