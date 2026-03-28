import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_list_app/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:todo_list_app/features/todo/data/datasources/todo_remote_data_source.dart';
import 'package:todo_list_app/features/todo/data/models/todo_model.dart';
import 'package:todo_list_app/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:todo_list_app/features/todo/domain/entities/todo_query_entity.dart';

class _MockRemote extends Mock implements TodoRemoteDataSource {}

class _MockLocal extends Mock implements TodoLocalDataSource {}

class _FakeTodoQueryEntity extends Fake implements TodoQueryEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeTodoQueryEntity());
  });

  group('TodoRepositoryImpl', () {
    test('returns cached todos when remote getTodos throws', () async {
      final remote = _MockRemote();
      final local = _MockLocal();
      final repository = TodoRepositoryImpl(remote, local);
      const query = TodoQueryEntity(page: 1, pageSize: 10);

      when(() => remote.getTodos(query)).thenThrow(Exception('network error'));
      when(() => local.getTodos()).thenAnswer(
        (_) async => const [
          TodoModel(
            id: 'local-1',
            title: 'Cached todo',
            description: 'Read from local cache',
            isCompleted: false,
            priority: '1',
          ),
        ],
      );

      final result = await repository.getTodos(query);

      expect(result.totalItems, 1);
      expect(result.items.first.title, 'Cached todo');
      verify(() => remote.getTodos(query)).called(1);
      verify(() => local.getTodos()).called(1);
      verifyNever(() => local.saveTodos(any()));
    });
  });
}
