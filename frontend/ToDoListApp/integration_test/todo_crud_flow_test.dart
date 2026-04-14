import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

import 'test_app_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login va CRUD todo day du', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final accountField = find.widgetWithText(TextField, 'Email or username');
    final passwordField = find.widgetWithText(TextField, 'Password');
    final loginBtn = find.widgetWithText(FilledButton, 'Login now');

    expect(accountField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginBtn, findsOneWidget);

    await tester.enterText(accountField, seededUserName);
    await tester.enterText(passwordField, seededPassword);
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    expect(find.text('ToDoList'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'New'), findsOneWidget);

    final createdTitle = 'IT Todo Original';
    final updatedTitle = 'IT Todo Updated';

    final newBtn = find.widgetWithText(ElevatedButton, 'New');
    await tester.tap(newBtn);
    await tester.pumpAndSettle();

    expect(find.text('Add Todo'), findsOneWidget);

    final titleField = find.widgetWithText(TextField, 'Title');
    final descField = find.widgetWithText(TextField, 'Description');
    expect(titleField, findsOneWidget);
    expect(descField, findsOneWidget);

    await tester.enterText(titleField, createdTitle);
    await tester.enterText(descField, 'Created from integration test');
    await tester.tap(find.byKey(const Key('add_todo_button')));
    await tester.pumpAndSettle();

    expect(find.text(createdTitle), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Edit').first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Todo'), findsOneWidget);
    final editTitleField = find.widgetWithText(TextField, 'Title');
    await tester.enterText(editTitleField, '');
    await tester.enterText(editTitleField, updatedTitle);
    await tester.tap(find.byKey(const Key('add_todo_button')));
    await tester.pumpAndSettle();

    expect(find.text(updatedTitle), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete').first);
    await tester.pumpAndSettle();

    expect(find.text(updatedTitle), findsNothing);
  });
}
