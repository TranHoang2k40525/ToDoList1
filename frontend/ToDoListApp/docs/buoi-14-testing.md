# Buoi 14 - Testing trong Flutter (Unit, Widget, Integration)

Tai lieu nay la ban chi tiet de su dung trong buoi thuyet trinh, tap trung vao 3 lop test trong Flutter va cach ap dung vao du an ToDoList theo Clean Architecture.

## 1) Tong quan buoi hoc

- Ten buoi hoc: Testing trong Flutter (Unit, Widget, Integration)
- Nhom: 13
- Trong tam: Unit Test cho Domain/Data, Widget Test cho UI, Mocking/Faking
- Muc tieu:
  - Phan biet 3 loai test.
  - Viet Unit Test cho business logic (UseCase).
  - Viet Widget Test cho giao dien va tuong tac.

## 2) Ban do test theo kien truc Clean Architecture

- Domain Layer:
  - Uu tien Unit Test (nhanh, on dinh, khong phu thuoc UI/API).
  - Trong du an: `GetTodosUseCase`.
- Data Layer:
  - Unit Test cho repository/data source voi mock/fake.
- Presentation Layer:
  - Widget Test cho interaction va state rendering.
  - Trong du an: nut them cong viec doi trang thai sau khi bam.
- End-to-end:
  - Integration Test kiem tra luong chay chinh cua app.

## 3) Da trien khai gi trong source code

### 3.1 Unit Test
File: [test/features/todo/domain/usecases/get_todos_usecase_test.dart](../test/features/todo/domain/usecases/get_todos_usecase_test.dart)

Noi dung:
- Mock `TodoRepository` bang mocktail.
- Test happy path:
  - repository tra `PagedTodoEntity`
  - usecase tra dung ket qua
  - verify repository duoc goi dung 1 lan
- Test error path:
  - repository throw exception
  - usecase rethrow exception

Y nghia:
- Xac nhan logic usecase khong bi troi hanh vi boi network/database.
- Unit test chay nhanh va on dinh.

### 3.2 Widget Test
File: [test/features/todo/presentation/widgets/add_todo_button_test.dart](../test/features/todo/presentation/widgets/add_todo_button_test.dart)

Widget duoc test:
- [lib/features/todo/presentation/widgets/add_todo_button.dart](../lib/features/todo/presentation/widgets/add_todo_button.dart)

Noi dung:
- Pump widget trong `MaterialApp` + `Scaffold`.
- Kiem tra trang thai ban dau la `Add`.
- Gia lap bam nut bang `tester.tap(...)`.
- `pumpAndSettle()` de cho Future hoan tat.
- Assert nhan nut da doi thanh `Added` va callback duoc goi.

Y nghia:
- Kiem tra thay doi state trong Presentation Layer khi user tuong tac.

### 3.3 Integration Test (Smoke)
File: [integration_test/app_smoke_test.dart](../integration_test/app_smoke_test.dart)

Noi dung:
- Khoi tao app that bang `IntegrationTestWidgetsFlutterBinding`.
- Pump app va assert man hinh login hien thi.

Y nghia:
- Kiem tra ung dung khoi dong dung o muc end-to-end co ban.

## 4) Huong dan run test

### Cai dependency
```bash
flutter pub get
```

### Chay toan bo unit + widget test
```bash
flutter test
```

### Chay rieng unit test cho UseCase
```bash
flutter test test/features/todo/domain/usecases/get_todos_usecase_test.dart
```

### Chay rieng widget test
```bash
flutter test test/features/todo/presentation/widgets/add_todo_button_test.dart
```

### Chay integration smoke test tren web
```bash
flutter test integration_test/app_smoke_test.dart -d chrome
```

## 5) Mocking va Faking (Mocktail)

- Mock:
  - Gia lap hanh vi object phu thuoc.
  - Dung khi can verify interaction (`called(1)`) hoac gia lap throw.
- Fake:
  - Doi tuong gia don gian de lam fallback value cho mocktail.
  - Trong test hien tai: `_FakeTodoQueryEntity`.

Khi nao Mock, khi nao Fake:
- Mock khi can mo phong behavior va assert so lan goi.
- Fake khi chi can object hop le de truyen vao ham.

## 6) Giai thich WidgetTester theo tu duy thuc chien

- `pumpWidget`: render widget tree.
- `find.text`, `find.byKey`, `find.byType`: tim widget can thao tac/assert.
- `tap`: gia lap hanh vi user.
- `pump`: cho 1 frame moi.
- `pumpAndSettle`: cho tat ca animation/future hoan tat.

Mau tu duy viet test:
1. Arrange: dung widget va state ban dau.
2. Act: mo phong user action.
3. Assert: kiem tra UI/state sau action.

## 7) Coverage va chat luong test

Lenh tao coverage:
```bash
flutter test --coverage
```

Tieu chi test case hieu qua:
- Ten test ro y nghia nghiep vu.
- Moi test chi xac minh 1 hanh vi chinh.
- Co ca happy path va error path.
- Tranh test qua nhieu implementation detail.

## 8) Cac loi thuong gap va cach tranh

- Lieu do Future chua hoan tat -> thieu `pump`/`pumpAndSettle`.
- Mock chua fallback value -> mocktail bao loi runtime.
- Widget test phu thuoc network that -> test flakey.
- Assert qua chung chung -> bo sot regression.

## 9) Tai lieu tham khao bat buoc

- [Testing Flutter apps](https://docs.flutter.dev/testing)
- [Introduction to Unit Testing](https://docs.flutter.dev/cookbook/testing/unit/introduction)
- [Mocktail package](https://pub.dev/packages/mocktail)
