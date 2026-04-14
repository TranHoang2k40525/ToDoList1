import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

import 'test_app_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('chuyen qua tab Register hien thi form dang ky', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final registerTab = find.text('Register');
    expect(registerTab, findsOneWidget);

    await tester.tap(registerTab);
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Full name'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Create account'), findsOneWidget);
  });

  testWidgets('dang nhap sai hien thi thong bao loi', (tester) async {
    await tester.pumpWidget(
      buildTestApp(authRepository: FakeAuthRepository.empty()),
    );
    await tester.pumpAndSettle();

    final accountField = find.widgetWithText(TextField, 'Email or username');
    final passwordField = find.widgetWithText(TextField, 'Password');
    final loginButton = find.widgetWithText(FilledButton, 'Login now');

    expect(accountField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);

    await tester.enterText(accountField, 'wrong_user@gmail.com');
    await tester.enterText(passwordField, 'wrong_password_123');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    final errorTextFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.style?.color == Colors.red &&
          (widget.data ?? '').contains('Invalid credentials'),
    );
    expect(errorTextFinder, findsOneWidget);
  });

  testWidgets('dang ky moi va dang nhap thanh cong vao man hinh todo', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(authRepository: FakeAuthRepository.empty()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Username'), seededUserName);
    await tester.enterText(find.widgetWithText(TextField, 'Full name'), 'Integration User');
    await tester.enterText(find.widgetWithText(TextField, 'Email'), seededEmail);
    await tester.enterText(find.widgetWithText(TextField, 'Password'), seededPassword);

    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Register success. Please login.'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Email or username'),
      seededUserName,
    );
    await tester.enterText(find.widgetWithText(TextField, 'Password'), seededPassword);
    await tester.tap(find.widgetWithText(FilledButton, 'Login now'));
    await tester.pumpAndSettle();

    expect(find.text('ToDoList'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'New'), findsOneWidget);
  });
}
