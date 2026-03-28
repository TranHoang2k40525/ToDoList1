import '../../domain/entities/category_entity.dart';
import '../../domain/entities/paged_todo_entity.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/entities/todo_query_entity.dart';
import '../../domain/entities/todo_stats_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_data_source.dart';
import '../datasources/todo_remote_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this._remote, this._local);

  final TodoRemoteDataSource _remote;
  final TodoLocalDataSource _local;

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final items = await _remote.getCategories();
    return items.map((e) => e.toEntity()).toList();
  }

  @override
  Future<CategoryEntity> createCategory({required String name, String? icon, String? colorHex}) async {
    final model = await _remote.createCategory(name: name, icon: icon, colorHex: colorHex);
    return model.toEntity();
  }

  @override
  Future<CategoryEntity> updateCategory({required String id, String? name, String? icon, String? colorHex}) async {
    final model = await _remote.updateCategory(id: id, name: name, icon: icon, colorHex: colorHex);
    return model.toEntity();
  }

  @override
  Future<void> deleteCategory(String id) {
    return _remote.deleteCategory(id);
  }

  @override
  Future<PagedTodoEntity> getTodos(TodoQueryEntity query) async {
    try {
      final raw = await _remote.getTodos(query);
      final paged = TodoModel.parsePaged(raw);
      await _local.saveTodos(
        paged.items
            .map(
              (e) => TodoModel(
                id: e.id,
                title: e.title,
                description: e.description,
                isCompleted: e.isCompleted,
                priority: e.priority,
                categoryName: e.categoryName,
                categoryId: e.categoryId,
                dueDate: e.dueDate,
                createdAt: e.createdAt,
                updatedAt: e.updatedAt,
              ),
            )
            .toList(),
      );
      return paged;
    } catch (_) {
      final cached = await _local.getTodos();
      return PagedTodoEntity(
        page: 1,
        pageSize: cached.length,
        totalItems: cached.length,
        totalPages: 1,
        items: cached.map((e) => e.toEntity()).toList(),
      );
    }
  }

  @override
  Future<TodoEntity> getTodoDetail(String id) async {
    final model = await _remote.getTodoDetail(id);
    return model.toEntity();
  }

  @override
  Future<TodoEntity> createTodo({
    required String title,
    required String description,
    required int priority,
    DateTime? dueDate,
    String? categoryId,
  }) async {
    final model = await _remote.createTodo(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      categoryId: categoryId,
    );
    return model.toEntity();
  }

  @override
  Future<TodoEntity> updateTodo({
    required String id,
    required String title,
    required String description,
    required int priority,
    DateTime? dueDate,
    String? categoryId,
    bool? isCompleted,
  }) async {
    final model = await _remote.updateTodo(
      id: id,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      categoryId: categoryId,
      isCompleted: isCompleted,
    );
    return model.toEntity();
  }

  @override
  Future<void> toggleTodoStatus(String id) {
    return _remote.toggleTodoStatus(id);
  }

  @override
  Future<void> deleteTodo(String id) {
    return _remote.deleteTodo(id);
  }

  @override
  Future<TodoStatsEntity> getStats() async {
    final model = await _remote.getStats();
    return model.toEntity();
  }
}
