import '../../../../core/local/local_cache.dart';
import '../models/todo_model.dart';

class TodoLocalDataSource {
  TodoLocalDataSource(this._cache);

  final LocalCache _cache;

  Future<void> saveTodos(List<TodoModel> todos) async {
    await _cache.saveTodoCache(todos.map((e) => e.toJson()).toList());
  }

  Future<List<TodoModel>> getTodos() async {
    final cached = await _cache.getTodoCache();
    return cached.map(TodoModel.fromJson).toList();
  }
}
