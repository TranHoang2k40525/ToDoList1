import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/local/local_cache.dart';
import '../core/network/api_client.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/auth_usecases.dart';
import '../features/todo/data/datasources/todo_local_data_source.dart';
import '../features/todo/data/datasources/todo_remote_data_source.dart';
import '../features/todo/data/repositories/todo_repository_impl.dart';
import '../features/todo/domain/repositories/todo_repository.dart';
import '../features/todo/domain/usecases/todo_usecases.dart';

final localCacheProvider = Provider<LocalCache>((ref) => LocalCache());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(localCacheProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.read(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
    ref.read(localCacheProvider),
  );
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.read(authRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.read(authRepositoryProvider));
});

final todoRemoteDataSourceProvider = Provider<TodoRemoteDataSource>((ref) {
  return TodoRemoteDataSource(ref.read(apiClientProvider));
});

final todoLocalDataSourceProvider = Provider<TodoLocalDataSource>((ref) {
  return TodoLocalDataSource(ref.read(localCacheProvider));
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl(
    ref.read(todoRemoteDataSourceProvider),
    ref.read(todoLocalDataSourceProvider),
  );
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.read(todoRepositoryProvider));
});

final createCategoryUseCaseProvider = Provider<CreateCategoryUseCase>((ref) {
  return CreateCategoryUseCase(ref.read(todoRepositoryProvider));
});

final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  return UpdateCategoryUseCase(ref.read(todoRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  return DeleteCategoryUseCase(ref.read(todoRepositoryProvider));
});

final getTodosUseCaseProvider = Provider<GetTodosUseCase>((ref) {
  return GetTodosUseCase(ref.read(todoRepositoryProvider));
});

final getTodoDetailUseCaseProvider = Provider<GetTodoDetailUseCase>((ref) {
  return GetTodoDetailUseCase(ref.read(todoRepositoryProvider));
});

final createTodoUseCaseProvider = Provider<CreateTodoUseCase>((ref) {
  return CreateTodoUseCase(ref.read(todoRepositoryProvider));
});

final updateTodoUseCaseProvider = Provider<UpdateTodoUseCase>((ref) {
  return UpdateTodoUseCase(ref.read(todoRepositoryProvider));
});

final toggleTodoStatusUseCaseProvider = Provider<ToggleTodoStatusUseCase>((ref) {
  return ToggleTodoStatusUseCase(ref.read(todoRepositoryProvider));
});

final deleteTodoUseCaseProvider = Provider<DeleteTodoUseCase>((ref) {
  return DeleteTodoUseCase(ref.read(todoRepositoryProvider));
});

final getTodoStatsUseCaseProvider = Provider<GetTodoStatsUseCase>((ref) {
  return GetTodoStatsUseCase(ref.read(todoRepositoryProvider));
});
