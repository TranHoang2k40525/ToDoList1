# Hướng Dẫn Trình Bày Buổi 14 - Testing trong Flutter
**Thực hiện bởi: Nhóm 13**

Tài liệu này cung cấp kịch bản chi tiết và hướng dẫn trình bày trên lớp cho Buổi 14 về Testing trong Flutter, sử dụng dự án To-Do List có kiến trúc Clean Architecture.

---

## I. Xây dựng tài liệu Pre-reading (Nộp trước buổi học 48h)

*Lưu ý: Các thành viên trong nhóm cần gửi trước danh sách các khái niệm sau kèm link tham khảo.*

1. **Tổng quan 3 loại Test chính trong Flutter**:
   - **Unit Test**: Test các logic nghiệp vụ hoặc hàm độc lập (đặc biệt trong Domain Layer - Use Cases và Data Layer - Models/Mappers). Chạy nhanh, không yêu cầu giao diện (UI) hoặc thiết bị thật.
   - **Widget Test (Component Test)**: Test một Widget cụ thể trên Presentation Layer xem nó có render chính xác và phản hồi đúng với tương tác (tap, scroll) hay không. Sử dụng `WidgetTester`.
   - **Integration Test**: Kiểm tra toàn trình (E2E) các flow của ứng dụng giống như người dùng thật đang dùng trên máy ảo (Emulator) hoặc máy thật.

2. **Mocking & Faking với Mocktail**:
   - **Mock**: Tạo một đối tượng giả lập định nghĩa sẵn các hành vi, giúp test không phụ thuộc vào Database hay API.
   - **Fake**: Một bản cài đặt đơn giản hơn của một interface để phục vụ cho các trường hợp phụ thuộc tham số.

3. **Link tham khảo (Gửi kèm cho sinh viên tự học)**:
   - [Testing Flutter apps](https://docs.flutter.dev/testing)
   - [Introduction to Unit Testing](https://docs.flutter.dev/cookbook/testing/unit/introduction)
   - [Mocktail Documentation](https://pub.dev/packages/mocktail)

---

## II. Kịch Bản Thuyết Trình Trên Lớp (Demo Trực Tiếp)

### 1. Mở Đầu (5 phút)
- **Giới thiệu**: Chào mừng các bạn đến với buổi học số 14 về Testing trong lập trình Flutter.
- **Tầm quan trọng**: Trình bày tại sao cần viết Test ("Nếu không có test, mỗi lần thêm tính năng mới là một lần đánh cược chức năng cũ sẽ lỗi").
- **Nhắc lại Clean Architecture**: Phân tách rõ ràng giữa UI và Logic. Nhờ đó The Domain Layer không phụ thuộc UI, giúp Unit Test dễ dàng và chạy cực kỳ nhanh.

### 2. Demo 1: Unit Test cho Use Case với Mocktail (15 phút)
- **Tình huống**: Cần test `GetTodosUseCase` để lấy danh sách công việc mà không cần gọi API thực tế.
- **Cách thực hiện trên lớp**:
  - Mở file `get_todos_usecase_test.dart`.
  - Khởi tạo Mock: Giới thiệu `class _MockTodoRepository extends Mock implements TodoRepository {}`. Giải thích `Mock` đến từ package `mocktail`.
  - Giải thích hàm `setUpAll` và `registerFallbackValue`: Cần thiết khi mock các class tự định nghĩa.
  - Chạy hàm Test:
    - `"arrange"`: Dùng `when(() => repository.getTodos(query)).thenAnswer(...)` để giả lập kết quả trả về.
    - `"act"`: Gọi trực tiếp use case `await useCase(query)`.
    - `"assert"`: Dùng `expect()` để so sánh kết quả trả về với cấu trúc dữ liệu mong đợi, giải thích `verify().called(1)` dùng để đảm bảo Repository thực sự đã được gọi đến.
- **Key Takeaway**: Unit test Use Case chứng minh rằng Tầng Domain đang hoạt động đúng rule nghiệp vụ độc lập hoàn toàn với việc lấy API từ back-end.

### 3. Demo 2: Widget Test cho Nút "Add Todo" (15 phút)
- **Tình huống**: Khi người dùng nhấn vào nút `AddTodoButton`, nút phải đổi trạng thái UI (đổi chữ `Add` thành `Added`).
- **Cách thực hiện trên lớp**:
  - Mở file `add_todo_button_test.dart`.
  - Định nghĩa khái niệm `WidgetTester`: Môi trường giả lập UI của framework test.
  - Sử dụng `tester.pumpWidget(...)`: Khởi tạo widget cần test ảo trên vùng nhớ. Giải thích lý do phải bọc Widget trong `MaterialApp`.
  - Sử dụng Finder: `find.text('Add')` hoặc `find.byKey(const Key('add_todo_button'))` để xác định vị trí của Widget trên màn hình.
  - Kích hoạt sự kiện: `await tester.tap(...)` - Hành động giả lập người dùng thao tác.
  - Trạng thái chờ: Giới thiệu hàm quan trọng `await tester.pumpAndSettle();` (buộc widget vẽ lại sau khi State bị thay đổi và đợi cho mọi animation kết thúc).
  - `"assert"`: Dùng `expect(find.text('Added'), findsOneWidget)` để khẳng định màn hình đã thấy sự thay đổi.

### 4. Tổng kết và Chia sẻ kinh nghiệm (10 phút)
- **Chia sẻ cách đạt Code Coverage cao**:
  - Đừng đợi code xong cả dự án mới viết (Hãy áp dụng TDD hoặc viết ngay khi xong 1 Use case).
  - Tách nhỏ hàm. Hàm càng nhỏ, làm đúng 1 việc (Single Responsibility) thì càng dễ Test.
- **So sánh nhanh**:
  - Dùng **Unit Test** để lo về quy tắc nghiệp vụ/tính toán.
  - Dùng **Widget Test** để lo về tương tác thao tác chạm, cuộn.
  - Dùng **Integration Test** để đo luồng toàn bộ khi release.
- **Hỏi & Đáp (Q&A)**.