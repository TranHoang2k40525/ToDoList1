# ToDoListApp - Clean Architecture, DI va Testing

Tai lieu nay duoc cap nhat de dap ung yeu cau cua Buoi 13 (DI/Service Locator) va Buoi 14 (Testing). Trong do, phan Buoi 14 duoc mo rong chi tiet nhat de phuc vu thuyet trinh va tu hoc.

## 1) Tong quan du an

ToDoListApp duoc to chuc theo Clean Architecture:
- Domain: entity, repository contract, usecase.
- Data: model, data source, repository implementation.
- Presentation: page, notifier/provider.

Kien truc thu muc chinh:
- [lib/features](lib/features)
- [lib/di/providers.dart](lib/di/providers.dart)
- [lib/di/service_locator.dart](lib/di/service_locator.dart)

## 2) Buoi 13 - Dependency Injection (DI) va Service Locator

### 2.1 Muc tieu
- Hieu DI va vai tro trong Clean Architecture.
- Biet dung `get_it` de register/resolve dependency.
- Hieu Riverpod cung la 1 co che DI theo huong constructor injection.

### 2.2 Trang thai trong project
- Riverpod DI da su dung o [lib/di/providers.dart](lib/di/providers.dart).
- get_it da duoc bo sung o [lib/di/service_locator.dart](lib/di/service_locator.dart).
- Cau noi get_it -> Riverpod o [lib/di/get_it_providers.dart](lib/di/get_it_providers.dart).

### 2.3 Demo thay doi dependency bang registration
`configureServiceLocator` ho tro:
- `TodoDataMode.remoteFirst`: API + local cache.
- `TodoDataMode.localOnly`: local cache only (phuc vu demo thay the data source).

Vi du:
```dart
await configureServiceLocator(todoDataMode: TodoDataMode.localOnly);
```

### 2.4 Doc chi tiet Buoi 13
- [docs/buoi-13-di.md](docs/buoi-13-di.md)

## 3) Buoi 14 - Testing trong Flutter (TRONG TAM)

### 3.1 Muc tieu dat duoc
Sau khi hoc va lam theo bo source hien tai, sinh vien co the:
1. Phan biet Unit/Widget/Integration test.
2. Viet Unit Test cho UseCase (business logic).
3. Viet Widget Test cho tuong tac UI va thay doi state.
4. Dung Mocktail de mocking/faking.

### 3.2 Da bo sung gi trong source code

#### Unit Test cho Domain Layer
- [test/features/todo/domain/usecases/get_todos_usecase_test.dart](test/features/todo/domain/usecases/get_todos_usecase_test.dart)

Noi dung:
- Mock `TodoRepository` bang `mocktail`.
- Verify `GetTodosUseCase` goi dung repository.
- Co test happy path va exception path.

#### Widget Test cho Presentation Layer
- Widget: [lib/features/todo/presentation/widgets/add_todo_button.dart](lib/features/todo/presentation/widgets/add_todo_button.dart)
- Da duoc gan vao page: [lib/features/todo/presentation/pages/todo_page.dart](lib/features/todo/presentation/pages/todo_page.dart)
- Test: [test/features/todo/presentation/widgets/add_todo_button_test.dart](test/features/todo/presentation/widgets/add_todo_button_test.dart)

Noi dung:
- Trang thai ban dau: `Add`.
- Sau khi bam: callback duoc goi va label doi thanh `Added`.
- Day la minh hoa truc tiep cho yeu cau "bam nut, state thay doi".

#### Integration Smoke Test
- [integration_test/app_smoke_test.dart](integration_test/app_smoke_test.dart)

Noi dung:
- Khoi tao app that.
- Xac minh login screen hien thi.

### 3.3 Huong dan chay test (chi tiet)

#### B1 - Cai dependency
```bash
flutter pub get
```

#### B2 - Chay toan bo Unit + Widget test
```bash
flutter test
```

#### B3 - Chay rieng Unit test GetTodosUseCase
```bash
flutter test test/features/todo/domain/usecases/get_todos_usecase_test.dart
```

#### B4 - Chay rieng Widget test AddTodoButton
```bash
flutter test test/features/todo/presentation/widgets/add_todo_button_test.dart
```

#### B5 - Chay Integration test
```bash
flutter test integration_test/app_smoke_test.dart -d chrome
```

### 3.4 Giai thich ky thuat Buoi 14 (quan trong nhat)

#### A. Vi sao Clean Architecture de test
- Domain layer phu thuoc contract (`TodoRepository`) nen co the mock de test logic rieng.
- Presentation layer co the test interaction UI ma khong can API that.

#### B. Mocking/Faking trong bo test hien tai
- Mock (`_MockTodoRepository`) dung de dieu khien behavior va verify interaction.
- Fake (`_FakeTodoQueryEntity`) dung lam fallback value cho mocktail.

#### C. WidgetTester van hanh ra sao
- `pumpWidget`: render UI.
- `find`: tim widget theo text/key/type.
- `tap`: gia lap thao tac user.
- `pumpAndSettle`: doi async/animation hoan tat.

#### D. Checklist de viet test case hieu qua
1. Dat ten test theo hanh vi, khong theo implementation.
2. Moi test chi giu 1 assertion behavior chinh.
3. Luon co it nhat 1 error case voi business logic.
4. Khong de test phu thuoc network, gio he thong, random.

#### E. Coverage
```bash
flutter test --coverage
```

Muc tieu khuyen nghi cho mon hoc:
- Domain usecase: >= 80%
- Presentation quan trong (widget interaction): >= 60%
- Tong project: tang dan theo tung sprint, khong chay theo so lieu coverage ao.

### 3.5 Tai lieu chi tiet Buoi 14
- [docs/buoi-14-testing.md](docs/buoi-14-testing.md)

Tai lieu nay bao gom:
- Ly thuyet pre-reading.
- Mapping vao source code thuc te.
- Cach run test tung loai.
- Kinh nghiem de dat coverage tot va tranh flakey test.

## 4) Noi dung pre-reading de nop truoc buoi hoc

### Cho Buoi 13
- On lai Clean Architecture (Domain/Data/Presentation + dependency rule).
- OOP interface/abstract class.
- DI, Service Locator (`get_it`), Constructor Injection (Riverpod).

### Cho Buoi 14
- 3 loai test trong Flutter.
- Mocking/Faking voi `mocktail`.
- Unit test cho usecase.
- Widget test voi `WidgetTester` va cac `find` matcher.

## 5) Lenh chay app
```bash
flutter run
```

## 6) Tai lieu tham khao
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Testing Flutter apps](https://docs.flutter.dev/testing)
- [Introduction to Unit Testing](https://docs.flutter.dev/cookbook/testing/unit/introduction)
- [Mocktail Documentation](https://pub.dev/packages/mocktail)
- [Dependency Inversion Principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle)

## 7) Backend API coverage matrix (khong bo sot endpoint)

Backend duoc doi chieu tu cac file C# trong thu muc `ToDoList` va frontend da su dung day du tat ca endpoint API:

### Auth/User
- `POST /api/user/register`
	- Frontend: man Login/Register, nut `Create account`
	- Code: `AuthRemoteDataSource.register` -> `AuthNotifier.register`
- `POST /api/user/login`
	- Frontend: man Login, nut `Login now`
	- Code: `AuthRemoteDataSource.login` -> `AuthNotifier.login`
- `GET /api/user/profile`
	- Frontend: tab `Profile` (refresh)
	- Code: `AuthRemoteDataSource.getProfile`
- `PUT /api/user/profile`
	- Frontend: tab `Profile` (save profile)
	- Code: `AuthRemoteDataSource.updateProfile`

### Category
- `GET /api/category/category`
	- Frontend: tab `Categories` + dropdown filter/category trong form Todo
- `POST /api/category/category`
	- Frontend: tab `Categories` -> Add category
- `PUT /api/category/category/{id}`
	- Frontend: tab `Categories` -> Edit category
- `DELETE /api/category/category/{id}`
	- Frontend: tab `Categories` -> Delete category

### Todo
- `GET /api/todo/usertodo`
	- Frontend: tab `Todos` + filter day du (status/priority/category/keyword/dueFrom/dueTo/sort/page/pageSize)
- `GET /api/todo/detail/{id}`
	- Frontend: tap vao card todo -> detail bottom sheet
- `POST /api/todo/addtodo`
	- Frontend: tab `Todos` -> New/Add todo
- `PUT /api/todo/updatetodo/{id}`
	- Frontend: tab `Todos` -> Edit todo
- `PUT /api/todo/updatestatus/{id}`
	- Frontend: toggle status ngay tren card/detail
- `DELETE /api/todo/deletetodo/{id}`
	- Frontend: nut delete tren card
- `GET /api/todo/stats`
	- Frontend: tab `Dashboard` (total/completed/overdue/byCategory)

## 8) Mau ho so nop hoc phan (template)

### 8.1 Thong tin nhom
- Nhom:
- Thanh vien:
- Link repo:
- Commit minh chung truoc deadline:

### 8.2 Deliverables Buoi 13
- [ ] Tai lieu pre-reading (PDF/Markdown)
- [ ] Demo DI voi get_it + Riverpod
- [ ] Demo thay data source bang registration
- [ ] Video/anh minh hoa

### 8.3 Deliverables Buoi 14
- [ ] Tai lieu pre-reading (PDF/Markdown)
- [ ] Unit test cho usecase
- [ ] Widget test cho interaction UI
- [ ] Integration smoke test
- [ ] Bao cao coverage

### 8.4 Lenh validate truoc khi nop
```bash
flutter pub get
flutter test
flutter test integration_test/app_smoke_test.dart -d chrome
```

### 8.5 Admonitions quan trong
> IMPORTANT: Luon chay test sau moi thay doi lon de tranh regression.

> WARNING: Khong demo bang environment stale token, hay dang nhap lai truoc khi quay video demo.

> TIP: Khi backend doi contract DTO, cap nhat model parse truoc khi cap nhat UI.
