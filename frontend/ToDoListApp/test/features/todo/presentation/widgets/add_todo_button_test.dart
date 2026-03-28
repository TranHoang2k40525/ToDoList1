import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list_app/features/todo/presentation/widgets/add_todo_button.dart';

void main() {
  testWidgets('changes label after tap to reflect state update', (tester) async {
    var callCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddTodoButton(
            onAdd: () async {
              callCount += 1;
            },
          ),
        ),
      ),
    );

    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Added'), findsNothing);

    await tester.tap(find.byKey(const Key('add_todo_button')));
    await tester.pumpAndSettle();

    expect(callCount, 1);
    expect(find.text('Added'), findsOneWidget);
  });
}
