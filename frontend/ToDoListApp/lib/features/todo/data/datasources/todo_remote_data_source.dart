import '../../../../core/network/api_client.dart';
import '../../domain/entities/todo_query_entity.dart';
import '../models/category_model.dart';
import '../models/todo_model.dart';
import '../models/todo_stats_model.dart';

class TodoRemoteDataSource {
  TodoRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.dio.get('/api/category/category');
    final list = response.data as List<dynamic>;
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CategoryModel> createCategory({
    required String name,
    String? icon,
    String? colorHex,
  }) async {
    final response = await _client.dio.post(
      '/api/category/category',
      data: {'name': name, 'icon': icon, 'colorHex': colorHex},
    );
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CategoryModel> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? colorHex,
  }) async {
    final response = await _client.dio.put(
      '/api/category/category/$id',
      data: {'name': name, 'icon': icon, 'colorHex': colorHex},
    );
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCategory(String id) async {
    await _client.dio.delete('/api/category/category/$id');
  }

  Future<dynamic> getTodos(TodoQueryEntity query) async {
    final response = await _client.dio.get(
      '/api/todo/usertodo',
      queryParameters: {
        'isCompleted': query.isCompleted,
        'priority': query.priority,
        'categoryId': query.categoryId,
        'keyword': query.keyword,
        'dueFrom': query.dueFrom?.toIso8601String(),
        'dueTo': query.dueTo?.toIso8601String(),
        'sortBy': query.sortBy,
        'sortOrder': query.sortOrder,
        'page': query.page,
        'pageSize': query.pageSize,
      },
    );

    return response.data;
  }

  Future<TodoModel> getTodoDetail(String id) async {
    final response = await _client.dio.get('/api/todo/detail/$id');
    return TodoModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TodoModel> createTodo({
    required String title,
    required String description,
    required int priority,
    DateTime? dueDate,
    String? categoryId,
  }) async {
    final response = await _client.dio.post(
      '/api/todo/addtodo',
      data: {
        'title': title,
        'description': description,
        'priority': priority,
        'dueDate': dueDate?.toIso8601String(),
        'categoryId': categoryId,
      },
    );
    return TodoModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TodoModel> updateTodo({
    required String id,
    required String title,
    required String description,
    required int priority,
    DateTime? dueDate,
    String? categoryId,
    bool? isCompleted,
  }) async {
    final response = await _client.dio.put(
      '/api/todo/updatetodo/$id',
      data: {
        'title': title,
        'description': description,
        'priority': priority,
        'dueDate': dueDate?.toIso8601String(),
        'categoryId': categoryId,
        'isCompleted': isCompleted,
      },
    );
    return TodoModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> toggleTodoStatus(String id) async {
    await _client.dio.put('/api/todo/updatestatus/$id');
  }

  Future<void> deleteTodo(String id) async {
    await _client.dio.delete('/api/todo/deletetodo/$id');
  }

  Future<TodoStatsModel> getStats() async {
    final response = await _client.dio.get('/api/todo/stats');
    return TodoStatsModel.fromJson(response.data as Map<String, dynamic>);
  }
}
