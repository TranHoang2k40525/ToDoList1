import 'package:get_it/get_it.dart';

import '../core/local/local_cache.dart';
import '../core/network/api_client.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/auth_usecases.dart';
import '../features/todo/data/datasources/todo_local_data_source.dart';
import '../features/todo/data/datasources/todo_remote_data_source.dart';
import '../features/todo/data/models/todo_model.dart';
import '../features/todo/data/repositories/todo_repository_impl.dart';
import '../features/todo/domain/entities/category_entity.dart';
import '../features/todo/domain/entities/paged_todo_entity.dart';
import '../features/todo/domain/entities/todo_entity.dart';
import '../features/todo/domain/entities/todo_query_entity.dart';
import '../features/todo/domain/entities/todo_stats_entity.dart';
import '../features/todo/domain/repositories/todo_repository.dart';
import '../features/todo/domain/usecases/todo_usecases.dart';

enum TodoDataMode {
  remoteFirst,
  localOnly,
}

final sl = GetIt.instance;

Future<void> configureServiceLocator({
  TodoDataMode todoDataMode = TodoDataMode.remoteFirst,
}) async {
  if (sl.isRegistered<LocalCache>()) {
    return;
  }

  sl.registerLazySingleton<LocalCache>(LocalCache.new);
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<LocalCache>()));

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<LocalCache>()),
  );

  sl.registerFactory<RegisterUseCase>(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerFactory<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerFactory<GetProfileUseCase>(() => GetProfileUseCase(sl<AuthRepository>()));
  sl.registerFactory<UpdateProfileUseCase>(() => UpdateProfileUseCase(sl<AuthRepository>()));

  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSource(sl<LocalCache>()),
  );

  if (todoDataMode == TodoDataMode.localOnly) {
    sl.registerLazySingleton<TodoRepository>(
      () => _LocalOnlyTodoRepository(sl<TodoLocalDataSource>()),
    );
  } else {
    sl.registerLazySingleton<TodoRemoteDataSource>(
      () => TodoRemoteDataSource(sl<ApiClient>()),
    );
    sl.registerLazySingleton<TodoRepository>(
      () => TodoRepositoryImpl(sl<TodoRemoteDataSource>(), sl<TodoLocalDataSource>()),
    );
  }

  sl.registerFactory<GetCategoriesUseCase>(() => GetCategoriesUseCase(sl<TodoRepository>()));
  sl.registerFactory<CreateCategoryUseCase>(() => CreateCategoryUseCase(sl<TodoRepository>()));
  sl.registerFactory<UpdateCategoryUseCase>(() => UpdateCategoryUseCase(sl<TodoRepository>()));
  sl.registerFactory<DeleteCategoryUseCase>(() => DeleteCategoryUseCase(sl<TodoRepository>()));
  sl.registerFactory<GetTodosUseCase>(() => GetTodosUseCase(sl<TodoRepository>()));
  sl.registerFactory<GetTodoDetailUseCase>(() => GetTodoDetailUseCase(sl<TodoRepository>()));
  sl.registerFactory<CreateTodoUseCase>(() => CreateTodoUseCase(sl<TodoRepository>()));
  sl.registerFactory<UpdateTodoUseCase>(() => UpdateTodoUseCase(sl<TodoRepository>()));
  sl.registerFactory<ToggleTodoStatusUseCase>(() => ToggleTodoStatusUseCase(sl<TodoRepository>()));
  sl.registerFactory<DeleteTodoUseCase>(() => DeleteTodoUseCase(sl<TodoRepository>()));
  sl.registerFactory<GetTodoStatsUseCase>(() => GetTodoStatsUseCase(sl<TodoRepository>()));
}

class _LocalOnlyTodoRepository implements TodoRepository {
  _LocalOnlyTodoRepository(this._local);

  final TodoLocalDataSource _local;
  final List<CategoryEntity> _categories = const [
    CategoryEntity(id: 'local-default', name: 'General', icon: 'task_alt'),
  ];

  @override
  Future<CategoryEntity> createCategory({required String name, String? icon, String? colorHex}) async {
    return CategoryEntity(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      icon: icon,
      colorHex: colorHex,
    );
  }

  @override
  Future<TodoEntity> createTodo({
    required String title,
    required String description,
    required int priority,
    DateTime? dueDate,
    String? categoryId,
  }) async {
    final all = await _local.getTodos();
    final model = TodoModel(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      description: description,
      isCompleted: false,
      priority: priority.toString(),
      dueDate: dueDate,
      categoryId: categoryId,
      categoryName: _categoryName(categoryId),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final updated = [model, ...all];
    await _local.saveTodos(updated);
    return model.toEntity();
  }

  @override
  Future<void> deleteCategory(String id) async {
    return;
  }

  @override
  Future<void> deleteTodo(String id) async {
    final all = await _local.getTodos();
    final updated = all.where((item) => item.id != id).toList();
    await _local.saveTodos(updated);
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return _categories;
  }

  @override
  Future<TodoEntity> getTodoDetail(String id) async {
    final all = await _local.getTodos();
    final found = all.where((item) => item.id == id).toList();
    if (found.isEmpty) {
      throw StateError('Todo not found: $id');
    }
    return found.first.toEntity();
  }

  @override
  Future<PagedTodoEntity> getTodos(TodoQueryEntity query) async {
    final all = await _local.getTodos();

    var filtered = all.where((item) {
      final keywordOk = query.keyword == null ||
          query.keyword!.isEmpty ||
          item.title.toLowerCase().contains(query.keyword!.toLowerCase()) ||
          item.description.toLowerCase().contains(query.keyword!.toLowerCase());
      final completedOk = query.isCompleted == null || item.isCompleted == query.isCompleted;
      final priorityOk = query.priority == null || item.priority == query.priority.toString();
      return keywordOk && completedOk && priorityOk;
    }).toList();

    if (query.sortOrder.toLowerCase() == 'asc') {
      filtered.sort((a, b) => (a.createdAt ?? DateTime(1970)).compareTo(b.createdAt ?? DateTime(1970)));
    } else {
      filtered.sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
    }

    final start = (query.page - 1) * query.pageSize;
    final totalItems = filtered.length;
    final pagedItems = start >= totalItems
        ? <TodoModel>[]
        : filtered.skip(start).take(query.pageSize).toList();

    final totalPages = totalItems == 0 ? 0 : (totalItems / query.pageSize).ceil();

    return PagedTodoEntity(
      page: query.page,
      pageSize: query.pageSize,
      totalItems: totalItems,
      totalPages: totalPages,
      items: pagedItems.map((item) => item.toEntity()).toList(),
    );
  }

  @override
  Future<TodoStatsEntity> getStats() async {
    final all = await _local.getTodos();
    final completed = all.where((item) => item.isCompleted).length;
    final overdue = all
        .where((item) => !item.isCompleted && item.dueDate != null && item.dueDate!.isBefore(DateTime.now()))
        .length;

    return const TodoStatsEntity(total: 0, completed: 0, overdue: 0, byCategory: []).copyWith(
      total: all.length,
      completed: completed,
      overdue: overdue,
      byCategory: const [],
    );
  }

  @override
  Future<void> toggleTodoStatus(String id) async {
    final all = await _local.getTodos();
    final updated = all
        .map(
          (item) => item.id == id
              ? TodoModel(
                  id: item.id,
                  title: item.title,
                  description: item.description,
                  isCompleted: !item.isCompleted,
                  priority: item.priority,
                  categoryName: item.categoryName,
                  categoryId: item.categoryId,
                  dueDate: item.dueDate,
                  createdAt: item.createdAt,
                  updatedAt: DateTime.now(),
                )
              : item,
        )
        .toList();
    await _local.saveTodos(updated);
  }

  @override
  Future<CategoryEntity> updateCategory({required String id, String? name, String? icon, String? colorHex}) async {
    return CategoryEntity(
      id: id,
      name: name ?? 'General',
      icon: icon,
      colorHex: colorHex,
    );
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
    final all = await _local.getTodos();
    final index = all.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw StateError('Todo not found: $id');
    }

    final current = all[index];
    final updatedModel = TodoModel(
      id: current.id,
      title: title,
      description: description,
      isCompleted: isCompleted ?? current.isCompleted,
      priority: priority.toString(),
      categoryName: _categoryName(categoryId),
      categoryId: categoryId,
      dueDate: dueDate,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );

    final updated = [...all]..[index] = updatedModel;
    await _local.saveTodos(updated);
    return updatedModel.toEntity();
  }

  String? _categoryName(String? categoryId) {
    if (categoryId == null) {
      return null;
    }

    for (final category in _categories) {
      if (category.id == categoryId) {
        return category.name;
      }
    }

    return null;
  }
}

extension on TodoStatsEntity {
  TodoStatsEntity copyWith({
    int? total,
    int? completed,
    int? overdue,
    List<CategoryTodoCountEntity>? byCategory,
  }) {
    return TodoStatsEntity(
      total: total ?? this.total,
      completed: completed ?? this.completed,
      overdue: overdue ?? this.overdue,
      byCategory: byCategory ?? this.byCategory,
    );
  }
}
