import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_list_app/features/todo/domain/entities/paged_todo_entity.dart';
import 'package:todo_list_app/features/todo/domain/entities/todo_entity.dart';
import 'package:todo_list_app/features/todo/domain/entities/todo_query_entity.dart';
import 'package:todo_list_app/features/todo/domain/repositories/todo_repository.dart';
import 'package:todo_list_app/features/todo/domain/usecases/todo_usecases.dart';

class _MockTodoRepository extends Mock implements TodoRepository {}

class _FakeTodoQueryEntity extends Fake implements TodoQueryEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeTodoQueryEntity());
  });

  group('GetTodosUseCase', () {
    test('returns paged todos from repository', () async {
      final repository = _MockTodoRepository();
      final useCase = GetTodosUseCase(repository);
      const query = TodoQueryEntity(page: 1, pageSize: 10, keyword: 'report');

      const expected = PagedTodoEntity(
        page: 1,
        pageSize: 10,
        totalItems: 1,
        totalPages: 1,
        items: [
          TodoEntity(
            id: 'todo-1',
            title: 'Write testing notes',
            description: 'Prepare Unit Test demo',
            isCompleted: false,
            priority: '1',
          ),
        ],
      );

      when(() => repository.getTodos(query)).thenAnswer((_) async => expected);

      final result = await useCase(query);

      expect(result.totalItems, 1);
      expect(result.items.first.title, 'Write testing notes');
      verify(() => repository.getTodos(query)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('rethrows repository error', () async {
      final repository = _MockTodoRepository();
      final useCase = GetTodosUseCase(repository);
      const query = TodoQueryEntity(page: 2, pageSize: 5);

      when(() => repository.getTodos(query)).thenThrow(Exception('network down'));

      expect(() => useCase(query), throwsA(isA<Exception>()));
      verify(() => repository.getTodos(query)).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
