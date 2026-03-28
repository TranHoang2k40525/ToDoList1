import '../entities/category_entity.dart';
import '../entities/paged_todo_entity.dart';
import '../entities/todo_entity.dart';
import '../entities/todo_query_entity.dart';
import '../entities/todo_stats_entity.dart';
import '../repositories/todo_repository.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase(this._repo);
  final TodoRepository _repo;
  Future<List<CategoryEntity>> call() => _repo.getCategories();
}

class CreateCategoryUseCase {
  CreateCategoryUseCase(this._repo);
  final TodoRepository _repo;
  Future<CategoryEntity> call({required String name, String? icon, String? colorHex}) {
    return _repo.createCategory(name: name, icon: icon, colorHex: colorHex);
  }
}

class UpdateCategoryUseCase {
  UpdateCategoryUseCase(this._repo);
  final TodoRepository _repo;
  Future<CategoryEntity> call({required String id, String? name, String? icon, String? colorHex}) {
    return _repo.updateCategory(id: id, name: name, icon: icon, colorHex: colorHex);
  }
}

class DeleteCategoryUseCase {
  DeleteCategoryUseCase(this._repo);
  final TodoRepository _repo;
  Future<void> call(String id) => _repo.deleteCategory(id);
}

class GetTodosUseCase {
  GetTodosUseCase(this._repo);
  final TodoRepository _repo;
  Future<PagedTodoEntity> call(TodoQueryEntity query) => _repo.getTodos(query);
}

class GetTodoDetailUseCase {
  GetTodoDetailUseCase(this._repo);
  final TodoRepository _repo;
  Future<TodoEntity> call(String id) => _repo.getTodoDetail(id);
}

class CreateTodoUseCase {
  CreateTodoUseCase(this._repo);
  final TodoRepository _repo;
  Future<TodoEntity> call({
    required String title,
    required String description,
    required int priority,
    DateTime? dueDate,
    String? categoryId,
  }) {
    return _repo.createTodo(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      categoryId: categoryId,
    );
  }
}

class UpdateTodoUseCase {
  UpdateTodoUseCase(this._repo);
  final TodoRepository _repo;
  Future<TodoEntity> call({
    required String id,
    required String title,
    required String description,
    required int priority,
    DateTime? dueDate,
    String? categoryId,
    bool? isCompleted,
  }) {
    return _repo.updateTodo(
      id: id,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      categoryId: categoryId,
      isCompleted: isCompleted,
    );
  }
}

class ToggleTodoStatusUseCase {
  ToggleTodoStatusUseCase(this._repo);
  final TodoRepository _repo;
  Future<void> call(String id) => _repo.toggleTodoStatus(id);
}

class DeleteTodoUseCase {
  DeleteTodoUseCase(this._repo);
  final TodoRepository _repo;
  Future<void> call(String id) => _repo.deleteTodo(id);
}

class GetTodoStatsUseCase {
  GetTodoStatsUseCase(this._repo);
  final TodoRepository _repo;
  Future<TodoStatsEntity> call() => _repo.getStats();
}
