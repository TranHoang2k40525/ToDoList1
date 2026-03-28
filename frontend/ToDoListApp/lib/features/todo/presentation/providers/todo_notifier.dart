import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/providers.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/paged_todo_entity.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/entities/todo_query_entity.dart';
import '../../domain/entities/todo_stats_entity.dart';
import '../../domain/usecases/todo_usecases.dart';

class TodoState {
  const TodoState({
    this.loading = false,
    this.error,
    this.categories = const [],
    this.page,
    this.detail,
    this.stats,
  });

  final bool loading;
  final String? error;
  final List<CategoryEntity> categories;
  final PagedTodoEntity? page;
  final TodoEntity? detail;
  final TodoStatsEntity? stats;

  TodoState copyWith({
    bool? loading,
    String? error,
    List<CategoryEntity>? categories,
    PagedTodoEntity? page,
    TodoEntity? detail,
    TodoStatsEntity? stats,
  }) {
    return TodoState(
      loading: loading ?? this.loading,
      error: error,
      categories: categories ?? this.categories,
      page: page ?? this.page,
      detail: detail ?? this.detail,
      stats: stats ?? this.stats,
    );
  }
}

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier(
    this._getCategories,
    this._createCategory,
    this._updateCategory,
    this._deleteCategory,
    this._getTodos,
    this._getDetail,
    this._createTodo,
    this._updateTodo,
    this._toggle,
    this._deleteTodo,
    this._getStats,
  ) : super(const TodoState());

  final GetCategoriesUseCase _getCategories;
  final CreateCategoryUseCase _createCategory;
  final UpdateCategoryUseCase _updateCategory;
  final DeleteCategoryUseCase _deleteCategory;
  final GetTodosUseCase _getTodos;
  final GetTodoDetailUseCase _getDetail;
  final CreateTodoUseCase _createTodo;
  final UpdateTodoUseCase _updateTodo;
  final ToggleTodoStatusUseCase _toggle;
  final DeleteTodoUseCase _deleteTodo;
  final GetTodoStatsUseCase _getStats;

  Future<void> loadInitial() async {
    await Future.wait([
      loadCategories(),
      search(const TodoQueryEntity()),
      loadStats(),
    ]);
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _getCategories();
      state = state.copyWith(categories: categories);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> search(TodoQueryEntity query) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final page = await _getTodos(query);
      state = state.copyWith(loading: false, page: page);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadStats() async {
    try {
      final stats = await _getStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadDetail(String id) async {
    try {
      final detail = await _getDetail(id);
      state = state.copyWith(detail: detail);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addTodo({
    required String title,
    required String description,
    required int priority,
    DateTime? dueDate,
    String? categoryId,
  }) async {
    await _createTodo(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      categoryId: categoryId,
    );
    await loadInitial();
  }

  Future<void> editTodo({
    required String id,
    required String title,
    required String description,
    required int priority,
    DateTime? dueDate,
    String? categoryId,
    bool? isCompleted,
  }) async {
    await _updateTodo(
      id: id,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      categoryId: categoryId,
      isCompleted: isCompleted,
    );
    await loadInitial();
  }

  Future<void> toggle(String id) async {
    await _toggle(id);
    await loadInitial();
  }

  Future<void> remove(String id) async {
    await _deleteTodo(id);
    await loadInitial();
  }

  Future<void> addCategory({required String name, String? icon, String? colorHex}) async {
    await _createCategory(name: name, icon: icon, colorHex: colorHex);
    await loadCategories();
  }

  Future<void> editCategory({required String id, String? name, String? icon, String? colorHex}) async {
    await _updateCategory(id: id, name: name, icon: icon, colorHex: colorHex);
    await loadCategories();
  }

  Future<void> removeCategory(String id) async {
    await _deleteCategory(id);
    await loadCategories();
  }
}

final todoNotifierProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier(
    ref.read(getCategoriesUseCaseProvider),
    ref.read(createCategoryUseCaseProvider),
    ref.read(updateCategoryUseCaseProvider),
    ref.read(deleteCategoryUseCaseProvider),
    ref.read(getTodosUseCaseProvider),
    ref.read(getTodoDetailUseCaseProvider),
    ref.read(createTodoUseCaseProvider),
    ref.read(updateTodoUseCaseProvider),
    ref.read(toggleTodoStatusUseCaseProvider),
    ref.read(deleteTodoUseCaseProvider),
    ref.read(getTodoStatsUseCaseProvider),
  );
});
