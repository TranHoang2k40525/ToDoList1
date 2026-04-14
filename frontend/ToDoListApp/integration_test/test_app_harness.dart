import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_app/app.dart';
import 'package:todo_list_app/di/providers.dart';
import 'package:todo_list_app/features/auth/domain/entities/user_profile_entity.dart';
import 'package:todo_list_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:todo_list_app/features/todo/domain/entities/category_entity.dart';
import 'package:todo_list_app/features/todo/domain/entities/paged_todo_entity.dart';
import 'package:todo_list_app/features/todo/domain/entities/todo_entity.dart';
import 'package:todo_list_app/features/todo/domain/entities/todo_query_entity.dart';
import 'package:todo_list_app/features/todo/domain/entities/todo_stats_entity.dart';
import 'package:todo_list_app/features/todo/domain/repositories/todo_repository.dart';

const seededUserName = 'integration_user';
const seededEmail = 'integration_user@example.com';
const seededPassword = 'Pass@123456';

Widget buildTestApp({
  FakeAuthRepository? authRepository,
  FakeTodoRepository? todoRepository,
}) {
  final auth = authRepository ?? FakeAuthRepository.withSeedUser();
  final todos = todoRepository ?? FakeTodoRepository();

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      todoRepositoryProvider.overrideWithValue(todos),
    ],
    child: const ToDoListApp(),
  );
}

class _TestUser {
  _TestUser({
    required this.id,
    required this.userName,
    required this.email,
    required this.password,
    required this.fullName,
    this.avatarUrl,
    required this.createdAt,
  });

  final String id;
  String userName;
  String email;
  String password;
  String fullName;
  String? avatarUrl;
  final DateTime createdAt;

  UserProfileEntity toProfile() {
    return UserProfileEntity(
      id: id,
      userName: userName,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository.withSeedUser()
      : _users = [
          _TestUser(
            id: 'user-1',
            userName: seededUserName,
            email: seededEmail,
            password: seededPassword,
            fullName: 'Integration User',
            avatarUrl: null,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

  FakeAuthRepository.empty() : _users = [];

  final List<_TestUser> _users;
  _TestUser? _currentUser;

  @override
  Future<String> login({required String account, required String password}) async {
    final normalized = account.trim().toLowerCase();
    final user = _users.where((u) {
      return u.userName.toLowerCase() == normalized || u.email.toLowerCase() == normalized;
    }).cast<_TestUser?>().firstWhere(
          (u) => u != null && u.password == password,
          orElse: () => null,
        );

    if (user == null) {
      throw Exception('Invalid credentials');
    }

    _currentUser = user;
    return 'fake-token-${user.id}';
  }

  @override
  Future<void> register({
    required String userName,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final normalizedUser = userName.trim().toLowerCase();
    final normalizedEmail = email.trim().toLowerCase();

    final exists = _users.any((u) {
      return u.userName.toLowerCase() == normalizedUser || u.email.toLowerCase() == normalizedEmail;
    });

    if (exists) {
      throw Exception('User already exists');
    }

    _users.add(
      _TestUser(
        id: 'user-${_users.length + 1}',
        userName: userName.trim(),
        email: email.trim(),
        password: password,
        fullName: fullName.trim(),
        avatarUrl: null,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<UserProfileEntity> getProfile() async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }
    return user.toProfile();
  }

  @override
  Future<UserProfileEntity> updateProfile({
    String? userName,
    String? fullName,
    String? avatarUrl,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    if (userName != null && userName.trim().isNotEmpty) {
      user.userName = userName.trim();
    }
    if (fullName != null && fullName.trim().isNotEmpty) {
      user.fullName = fullName.trim();
    }
    if (avatarUrl != null) {
      user.avatarUrl = avatarUrl;
    }

    return user.toProfile();
  }
}

class FakeTodoRepository implements TodoRepository {
  final List<CategoryEntity> _categories = const [
    CategoryEntity(id: 'cat-1', name: 'General', icon: 'assignment', colorHex: '#2E9BEE'),
  ];

  final List<TodoEntity> _todos = [];
  int _idCounter = 0;

  @override
  Future<CategoryEntity> createCategory({
    required String name,
    String? icon,
    String? colorHex,
  }) async {
    final category = CategoryEntity(
      id: 'cat-${_categories.length + 1}',
      name: name,
      icon: icon,
      colorHex: colorHex,
    );
    _categories.add(category);
    return category;
  }

  @override
  Future<TodoEntity> createTodo({
    required String title,
    required String description,
    required int priority,
    DateTime? dueDate,
    String? categoryId,
  }) async {
    _idCounter += 1;
    final createdAt = DateTime.now();
    final category = _categories.where((c) => c.id == categoryId).cast<CategoryEntity?>().firstWhere(
          (c) => c != null,
          orElse: () => null,
        );
    final todo = TodoEntity(
      id: 'todo-$_idCounter',
      title: title,
      description: description,
      isCompleted: false,
      priority: _priorityLabel(priority),
      categoryId: categoryId,
      categoryName: category?.name,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    _todos.add(todo);
    return todo;
  }

  @override
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return List<CategoryEntity>.from(_categories);
  }

  @override
  Future<TodoEntity> getTodoDetail(String id) async {
    final todo = _todos.where((t) => t.id == id).cast<TodoEntity?>().firstWhere(
          (t) => t != null,
          orElse: () => null,
        );
    if (todo == null) {
      throw Exception('Todo not found');
    }
    return todo;
  }

  @override
  Future<PagedTodoEntity> getTodos(TodoQueryEntity query) async {
    final keyword = query.keyword?.trim().toLowerCase();

    var filtered = _todos.where((todo) {
      final priorityMatches = query.priority == null || _priorityValue(todo.priority) == query.priority;
      final completedMatches = query.isCompleted == null || todo.isCompleted == query.isCompleted;
      final categoryMatches = query.categoryId == null || todo.categoryId == query.categoryId;

      final dueFromMatches = query.dueFrom == null ||
          (todo.dueDate != null && !todo.dueDate!.isBefore(query.dueFrom!));
      final dueToMatches = query.dueTo == null ||
          (todo.dueDate != null && !todo.dueDate!.isAfter(query.dueTo!));

      final keywordMatches = keyword == null ||
          keyword.isEmpty ||
          todo.title.toLowerCase().contains(keyword) ||
          todo.description.toLowerCase().contains(keyword);

      return priorityMatches && completedMatches && categoryMatches && dueFromMatches && dueToMatches && keywordMatches;
    }).toList();

    filtered.sort((a, b) {
      int result;
      switch (query.sortBy) {
        case 'title':
          result = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'priority':
          result = _priorityValue(a.priority).compareTo(_priorityValue(b.priority));
          break;
        case 'dueDate':
          final aDue = a.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDue = b.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          result = aDue.compareTo(bDue);
          break;
        case 'createdAt':
        default:
          final aCreated = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bCreated = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          result = aCreated.compareTo(bCreated);
          break;
      }
      return query.sortOrder == 'asc' ? result : -result;
    });

    final totalItems = filtered.length;
    final page = max(query.page, 1);
    final pageSize = max(query.pageSize, 1);
    final start = (page - 1) * pageSize;
    final end = min(start + pageSize, totalItems);
    final pageItems = start >= totalItems ? <TodoEntity>[] : filtered.sublist(start, end);
    final totalPages = totalItems == 0 ? 1 : (totalItems / pageSize).ceil();

    return PagedTodoEntity(
      page: page,
      pageSize: pageSize,
      totalItems: totalItems,
      totalPages: totalPages,
      items: pageItems,
    );
  }

  @override
  Future<TodoStatsEntity> getStats() async {
    final now = DateTime.now();
    final completed = _todos.where((t) => t.isCompleted).length;
    final overdue = _todos.where((t) => !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(now)).length;

    final byCategory = _categories.map((category) {
      final count = _todos.where((t) => t.categoryId == category.id).length;
      return CategoryTodoCountEntity(
        categoryId: category.id,
        categoryName: category.name,
        count: count,
      );
    }).toList();

    return TodoStatsEntity(
      total: _todos.length,
      completed: completed,
      overdue: overdue,
      byCategory: byCategory,
    );
  }

  @override
  Future<void> toggleTodoStatus(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index < 0) {
      throw Exception('Todo not found');
    }

    final current = _todos[index];
    _todos[index] = TodoEntity(
      id: current.id,
      title: current.title,
      description: current.description,
      isCompleted: !current.isCompleted,
      priority: current.priority,
      categoryName: current.categoryName,
      categoryId: current.categoryId,
      dueDate: current.dueDate,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<CategoryEntity> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? colorHex,
  }) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index < 0) {
      throw Exception('Category not found');
    }
    final current = _categories[index];
    final updated = CategoryEntity(
      id: current.id,
      name: name ?? current.name,
      icon: icon ?? current.icon,
      colorHex: colorHex ?? current.colorHex,
    );
    _categories[index] = updated;
    return updated;
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
    final index = _todos.indexWhere((t) => t.id == id);
    if (index < 0) {
      throw Exception('Todo not found');
    }

    final current = _todos[index];
    final category = _categories.where((c) => c.id == categoryId).cast<CategoryEntity?>().firstWhere(
          (c) => c != null,
          orElse: () => null,
        );

    final updated = TodoEntity(
      id: current.id,
      title: title,
      description: description,
      isCompleted: isCompleted ?? current.isCompleted,
      priority: _priorityLabel(priority),
      categoryName: category?.name,
      categoryId: categoryId,
      dueDate: dueDate,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );

    _todos[index] = updated;
    return updated;
  }

  String _priorityLabel(int priority) {
    switch (priority) {
      case 0:
        return 'Low';
      case 2:
        return 'High';
      case 1:
      default:
        return 'Medium';
    }
  }

  int _priorityValue(String label) {
    switch (label.toLowerCase()) {
      case 'low':
        return 0;
      case 'high':
        return 2;
      case 'medium':
      default:
        return 1;
    }
  }
}