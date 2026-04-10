# Tài Liệu Giải Thích Chương Trình To-Do List App (Testing)

Dự án Flutter To-Do List có cấu trúc chia tách mã độc lập (Clean Architecture) kết hợp với công cụ test tiên tiến `mocktail`, `flutter_test`. Hệ thống gồm 3 tầng Test: Unit Test (Logic), Widget Test (Giao diện) và Integration Test (Toàn hệ thống).

Bài viết này đi sâu giải thích chi tiết cấu trúc, và từng file source code quan trọng liên quan đến Module Testing, lần lượt theo tiến trình hoạt động chuẩn xác từ dễ đến khó của Hệ thống phần mềm. 

---

## I. Mở Đầu Và Hệ Sinh Thái Của Phần Mềm
Mọi thành phần kiểm thử (Test) đều được cấu hình ban đầu tại thư viện `pubspec.yaml` định hướng cho dự án tải về các gói Package test quan trọng.

1. `pubspec.yaml`
- **Mô tả:** Tệp cấu hình thư viện package của ứng dụng, phiên bản ứng dụng và version của bộ ngôn ngữ Dart.
- **Thành phần quan trọng:** 
  - `flutter_test`: Cốt lõi của Flutter Testing. Tích hợp Widget Tester và Dart Unit tests (expect, group).
  - `integration_test`: Module tích hợp E2E test cho việc auto giả lập trên Emulator thật.
  - `mocktail`: Thư viện thay thế API và Database. Cung cấp API `Mock` class hoặc `Fake` interface không cần reflection. 

---

## II. Clean Architecture Và Các Lớp Được Test (Thứ Tự Chuẩn)

Quy trình phát triển một tính năng thường đi từ trong ra ngoài (Domain -> Data -> Presentation).

### 1. Tầng Domain (Logic)
Lớp trái tim của dự án, Domain chứa quy chuẩn nghiệp vụ, không có thư viện bên ngoài. Chúng ta Test nó bằng Unit Test.

**File Source Code được test:** `TodoRepository` & `GetTodosUseCase`
- Đoạn code `GetTodosUseCase`:
  ```dart
  class GetTodosUseCase {
    final TodoRepository repository;
    GetTodosUseCase(this.repository);

    Future<PagedTodoEntity> call(TodoQueryEntity query) async {
       return await repository.getTodos(query);
    }
  }
  ```
  **Giải thích File:** `GetTodosUseCase` là một Class có nhiệm vụ duy nhất: "Nhận yêu cầu Lấy Danh Sách Công Việc". Nó mong đợi một `TodoQueryEntity` làm điều kiện tìm kiếm. Vì nó khai báo Interface `TodoRepository`, nó không tự gọi Web Server mà gửi nó qua Repository (một lớp chung cho Tầng Data). Lớp này nhận vào Repository thông qua cơ chế tiêm phụ thuộc Dependency Injection (Constructor Injection). 

#### Tại Sao Tầng Này Chạy Unit Test Lại Nhanh Và Rẻ Hơn?
Lớp này hoàn toàn không có `import 'package:flutter/...';`. Không cần chạy GUI hay render UI, test chỉ tốn thời gian 0.05ms cho một luồng tính toán.

**=> Kết Luận Của Tầng Này:** Đạt chuẩn nguyên tắc Dependency Inversion. Test (ở file `get_todos_usecase_test.dart`) chỉ cần gọi nó, truyền tham số Fake và nhét Mock của Interface `TodoRepository` vào là test được "Hàm này có gọi hàm kìa không?" hoặc "Hàm này chèn tham số lỗi thì văng Runtime Exception không?".

---

### 2. Tầng Presentation (Widget/UI)
Là giao diện màn hình gồm các Button, Layout mà người dùng tương tác, test bằng Widget Test.

**File Source Code được test:** `AddTodoButton`
- Đoạn code `AddTodoButton` Widget Component:
  ```dart
  class AddTodoButton extends StatefulWidget {
    final Future<void> Function() onAdd;
    const AddTodoButton({super.key, required this.onAdd});
  ...
  ```
  **Giải thích File:** Nhanh chóng đưa một hành động ra màn hình, đây là Component Stateful. Widget này nhận vào tham số là một Callback Function `onAdd` (Sẽ được cha nó truyền cho).
  ```dart
    bool isAdded = false;

    void _handleTap() async {
      await widget.onAdd();
      setState(() {
        isAdded = true;
      });
    }
  ```
  - Quản lý trạng thái `isAdded`. Khi người dùng gõ vào, hệ thống trỏ đến hàm `_handleTap()`. Nó làm hai việc: chạy callback bất đồng bộ, sau đó báo cho Widget biết "tao bị thay đổi" thông qua hàm `setState()`, khiến UI thay bóng biến hóa ngay lập tức.
  - Phía màn hình UI, logic là hàm `Text(isAdded ? 'Added' : 'Add')`. Tức màn hình biến chữ từ trạng thái "Add" -> "Added"

#### Ý Nghĩa Của File Add Todo Button Test (Widget Test)
Tầng UI có 2 câu hỏi lớn cần kiểm thử: "UI này có render Text đúng không?" và "Khi chọt tay lên màn hình, Widget Update UI như thay đổi chữ có thành công không?". Widget Test (File `add_todo_button_test.dart`) cho người dùng ảo truy quét Element Button, nhấn Tap vào `WidgetTester`, và verify bằng `Finder` là UI có xuất hiện chữ "Added" hay không.

---

### 3. Tầng End-to-End (Integration)
Nơi duy nhất gắn kết 3 thứ: Frontend/Backend/Database lại qua Emulator.

**File Source Code:** `integration_test/app_smoke_test.dart`
- Đoạn code `app_smoke_test.dart`:
  ```dart
  void main() {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  ```
  **Giải thích File:** Integration Test luôn bắt buộc gọi biến `ensureInitialized()`. Hàm này sẽ khởi chạy một engine Driver điều khiển cho phép App cài đặt vào thiết bị thật.

  ```dart
    testWidgets('app opens login page', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: ToDoListApp()));
      await tester.pumpAndSettle();
  ```
  **Giải thích File:** Mọi App chạy Integration test phải nhúng ngay Class khởi điểm `main()` của App ra màn hình, ở đây là app toàn cục `ToDoListApp` (cần ProviderScope nếu kết hợp State Management của Riverpod). Tới lúc tải xong toàn phần của Root Widget (`pumpAndSettle()`).

  ```dart
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  ```
  **Giải thích File:** Smoke test rất cơ bản để test xe luồng "Mở app lên có crash không?". Nếu nhìn thấy dòng chữ "Welcome Back" ở màn hình Login trang đầu tiên là thành công, Ứng dụng sống sót qua vòng khởi tạo.

---

## Tổng Kết Luồng Hoạt Động Của Code Và Test Lifecycle
1. Các thành viên dev tính năng, quy ước viết Interface (Domain).
2. Viết Mock Test xác minh Business rules (Unit Test UseCase).
3. Đan Widget lên thiết bị giả qua WidgetTester (Widget Test).
4. Ghép nối API Backend + Widget Build thành Project cài lên Máy Điện Thoại thông qua Smoke Test xác định toàn trình luồng cơ bản. (Integration Test).