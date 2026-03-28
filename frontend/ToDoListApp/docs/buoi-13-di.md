# Buoi 13 - Dependency Injection (DI) va Service Locator

## 1) Muc tieu hoc tap
- Hieu DI la ky thuat cap phat dependency tu ben ngoai thay vi tu khoi tao trong class.
- Hieu vai tro cua DI trong Clean Architecture: giam coupling, tang testability, tuan thu Dependency Rule.
- Biet 2 huong tiep can:
  - Service Locator voi `get_it`.
  - Constructor Injection qua `Riverpod Provider`.

## 2) Anh xa vao code hien tai

### Riverpod dang dung DI tu nhien
- Tat ca dependency duoc cap phat tai [lib/di/providers.dart](../lib/di/providers.dart).
- Vi du chain DI:
  - `ApiClient` phu thuoc `LocalCache`
  - `TodoRemoteDataSource` phu thuoc `ApiClient`
  - `TodoRepositoryImpl` phu thuoc `TodoRemoteDataSource` + `TodoLocalDataSource`
  - `GetTodosUseCase` phu thuoc `TodoRepository`
  - `TodoNotifier` phu thuoc cac UseCase

### get_it da duoc bo sung cho demo Service Locator
- Cau hinh tong tai [lib/di/service_locator.dart](../lib/di/service_locator.dart).
- Cac dependency duoc register theo nhom:
  - Core: `LocalCache`, `ApiClient`
  - Auth: datasource, repository, usecase
  - Todo: datasource, repository, usecase

## 3) Cac kieu dang ky trong get_it
- `registerLazySingleton`: tao 1 lan khi dung lan dau, dung lai suot vong doi app.
- `registerFactory`: moi lan resolve tao instance moi.

Trong du an:
- Singleton/Lazy singleton cho datasource, repository, client.
- Factory cho usecase.

## 4) Demo thay doi nguon du lieu chi bang registration

`service_locator.dart` ho tro 2 mode:
- `TodoDataMode.remoteFirst`: dung API + cache local (mac dinh).
- `TodoDataMode.localOnly`: bo qua remote, dung local cache de demo thay the data source.

Vi du khoi tao:

```dart
await configureServiceLocator(todoDataMode: TodoDataMode.localOnly);
```

Y nghia giang day:
- Domain va Presentation khong can doi code.
- Chi doi cach "wiring" dependency o composition root.

## 5) Ket hop get_it va Riverpod
- Co provider cau noi tai [lib/di/get_it_providers.dart](../lib/di/get_it_providers.dart).
- Riverpod provider co the doc UseCase tu `sl<T>()`.
- Day la cach ket hop khi muon giu UI/state cua Riverpod nhung DI bang get_it.

## 6) So sanh nhanh get_it va Riverpod cho DI
- get_it:
  - Uu diem: don gian, toc do nhanh, phu hop app nho-vua.
  - Nhuoc diem: dependency an (hidden), can ky luat quan ly vong doi.
- Riverpod:
  - Uu diem: dependency minh bach, override provider de test de dang.
  - Nhuoc diem: can hoc them khung provider.

## 7) Tai lieu tham khao
- [GetIt package](https://pub.dev/packages/get_it)
- [Riverpod concepts](https://riverpod.dev/docs/concepts/providers)
- [Dependency Inversion Principle (SOLID)](https://en.wikipedia.org/wiki/Dependency_inversion_principle)
