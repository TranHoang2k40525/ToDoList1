import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/domain/usecases/auth_usecases.dart';
import '../features/todo/domain/usecases/todo_usecases.dart';
import 'service_locator.dart';

final loginUseCaseFromGetItProvider = Provider<LoginUseCase>((ref) {
  return sl<LoginUseCase>();
});

final getTodosUseCaseFromGetItProvider = Provider<GetTodosUseCase>((ref) {
  return sl<GetTodosUseCase>();
});
