import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:todo_list_app/app.dart';

void main() {
  testWidgets('Shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ToDoListApp()));

    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
