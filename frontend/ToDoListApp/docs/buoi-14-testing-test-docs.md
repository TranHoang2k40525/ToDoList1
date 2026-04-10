# Tài Liệu Giải Thích: Thư Mục Test

Đây là tài liệu chi tiết về cách cấu trúc, vận hành và giải thích vai trò của từng đoạn code trong thư mục `test/` của dự án ứng dụng To-Do List Flutter. 

## 1. Cấu Trúc Tổng Quan Của Thư Mục Test

Theo chuẩn Clean Architecture, thư mục `test` được cấu trúc phản chiếu đúng cây thư mục nằm trong `lib/`:
```text
test/
├── features/
│   └── todo/
│       ├── data/
│       │   └── repositories/
│       │       └── todo_repository_impl_test.dart
│       ├── domain/
│       │   └── usecases/
│       │       └── get_todos_usecase_test.dart
│       └── presentation/
│           └── widgets/
│               └── add_todo_button_test.dart
└── widget_test.dart
```

---

## 2. Chi Tiết File Unit Test: `get_todos_usecase_test.dart`

**File Path:** `test/features/todo/domain/usecases/get_todos_usecase_test.dart`
**Mục Đích:** Kiểm tra hàm thực thi chính (logic nghiệp vụ) của tính năng lấy danh sách Todo, đảm bảo UseCase lấy đúng dữ liệu từ Repository hoặc xử lý việc báo lỗi chuẩn xác.

**Giải thích từng đoạn code:**
1. Khai báo Mock Object:
   ```dart
   class _MockTodoRepository extends Mock implements TodoRepository {}
   class _FakeTodoQueryEntity extends Fake implements TodoQueryEntity {}
   ```
   > Sử dụng `mocktail`, chúng ta tạo một class ảo `_MockTodoRepository`. Nó mang vỏ bọc của `TodoRepository` nhưng không chứa code logic. Việc chỉ định `Fake` cho `TodoQueryEntity` giúp chúng ta vượt qua lỗi null-safety tham số ẩn.

2. Khởi tạo môi trường Test (`setUpAll`):
   ```dart
   void main() {
     setUpAll(() {
       registerFallbackValue(_FakeTodoQueryEntity());
     });
   ```
   > Chạy 1 lần duy nhất trước toàn bộ các test case. Do hàm `getTodos` nhận vào một đối tượng kiểu `TodoQueryEntity`, mocktail cần biết sẵn một tham số dự phòng. Việc này tránh lỗi `Invalid argument(s): Fallback argument` khi giả lập hành vi API.

3. Test Case 1: Lấy dữ liệu thành công
   ```dart
     test('returns paged todos from repository', () async {
       final repository = _MockTodoRepository();
       final useCase = GetTodosUseCase(repository);
   ```
   > Chuẩn bị hai đối tượng, đưa Mock Repository truyền vào làm dependencies Injection giả cho Use case.

   ```dart
       when(() => repository.getTodos(query)).thenAnswer((_) async => expected);
   ```
   > **Mấu chốt của Mocktail**: Khi bất kỳ ai gọi hàm `repository.getTodos` với tham số `query` cho trước, nó sẽ không kết nối Web API thực, mà sẽ tự trả về một kết quả (`expected`) ngay lập tức ở dạng bất đồng bộ (`thenAnswer`).

   ```dart
       final result = await useCase(query);
       expect(result.totalItems, 1);
       verify(() => repository.getTodos(query)).called(1);
   ```
   > Gọi hành động và `expect()` kiểm tra tính đúng đắn. Cú pháp `verify().called(1)` là xác minh xem trong lúc Use case chạy, nó có thực sự gọi hàm Request đến CSDL không, nhỡ may Dev code sai và không bao giờ request thì Test vẫn sẽ bắt được.

---

## 3. Chi Tiết File Widget Test: `add_todo_button_test.dart`

**File Path:** `test/features/todo/presentation/widgets/add_todo_button_test.dart`
**Mục Đích:** Kiểm tra khả năng xử lý tương tác UI. Một nút nhấn đơn giản, khi ấn vào sẽ đổi Text Label của chính nó.

**Giải thích từng đoạn code:**
1. Cấu hình ban đầu:
   ```dart
   void main() {
     testWidgets('changes label after tap to reflect state update', (tester) async {
       var callCount = 0;
   ```
   > Từ khóa `testWidgets` tiêm vào giá trị `tester` (kiểu WidgetTester), công cụ tối cao của Flutter để tương tác với UI.

2. Vẽ Widget lên màn hình ảo:
   ```dart
       await tester.pumpWidget(
         MaterialApp(
           home: Scaffold(
             body: AddTodoButton(
               onAdd: () async { callCount += 1; },
             ),
           ),
         ),
       );
   ```
   > `pumpWidget` vẽ component vào một môi trường ảo không cần giả lập thiết bị. Phải bọc trong `MaterialApp` và `Scaffold` vì đa số material widget (button, text) phụ thuộc vào hệ thống Theme hoặc Material Localizations cung cấp bởi 2 class này. 

3. Assert trạng thái ban đầu:
   ```dart
       expect(find.text('Add'), findsOneWidget);
       expect(find.text('Added'), findsNothing);
   ```
   > Sử dụng `Finder`. Ban đầu trên Button phải là chữ "Add", và chưa có chữ "Added". Tìm thất bại nếu không thỏa mãn.

4. Gọi hành động và Wait render lại màn hình:
   ```dart
       await tester.tap(find.byKey(const Key('add_todo_button')));
       await tester.pumpAndSettle();
   ```
   > `tester.tap` lấy tọa độ bấm vào đúng button có chứa class Key. `pumpAndSettle()` là yêu cầu Flutter chạy hết mọi frame hình chứa các hiệu ứng Animation/Loading ra cho tới khi Widget đứng yên thì mới chạy tiếp mã lệnh.

5. Kết quả trích xuất:
   ```dart
       expect(callCount, 1);
       expect(find.text('Added'), findsOneWidget);
   ```
   > Đảm bảo Label text đã cập nhật thành công thành "Added".

---

## 4. Cách Hoạt Động Của Hệ Thống Và Cách Chạy Test

### Môi trường thực thi
Các bài Unit / Widget test này chạy trên trực tiếp **Dart VM** hoặc Máy ảo test, không yêu cầu Build tốn vài phút vào điện thoại ảo Android/iOS. Do đó thời gian chạy xong hàng trăm file test chỉ mất < 5 giây.

### Câu Lệnh Chạy (Dành Cho Command Line):
Di chuyển tới thư mục `frontend/ToDoListApp`
1. Chạy tất cả các test:
   ```bash
   flutter test
   ```
2. Chạy test của một file cụ thể:
   ```bash
   flutter test test/features/todo/domain/usecases/get_todos_usecase_test.dart
   ```
3. Chạy Integration test (Yêu cầu phải có phần cứng máy ảo đang mở):
   ```bash
   flutter test integration_test/app_smoke_test.dart
   ```

### Đánh Giá Yêu Cầu Đã Hoàn Thành
- [x] Đã thiết lập Unit Test cho Domain Layer (`GetTodosUseCase`)
- [x] Đã sử dụng Mocktail tạo Faking/Mocking Repository.
- [x] Đã bổ sung UI Widget Test bằng Finder và Tester.
- [x] Sẵn sàng phục vụ cho nhóm 13 trình diễn.