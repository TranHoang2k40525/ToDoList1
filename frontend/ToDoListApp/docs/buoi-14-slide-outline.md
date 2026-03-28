# Buoi 14 - Slide Outline (10-15 phut)

## Slide 1 - Title
- Testing trong Flutter: Unit, Widget, Integration
- Nhom 13
- Case study: ToDoList Clean Architecture

## Slide 2 - Why Testing
- Bug prevention > bug fixing
- Tu tin refactor
- CI/CD quality gate

## Slide 3 - 3 loai test trong Flutter
- Unit Test: test class/function rieng le
- Widget Test: test UI + interaction
- Integration Test: test luong end-to-end

## Slide 4 - Mapping voi Clean Architecture
- Domain -> Unit Test (UseCase)
- Data -> Unit Test (Repository/DataSource)
- Presentation -> Widget Test
- App flow -> Integration Test

## Slide 5 - Demo Unit Test
- File: test/features/todo/domain/usecases/get_todos_usecase_test.dart
- Mock repository bang mocktail
- Happy path + error path
- Verify interaction called(1)

## Slide 6 - Demo Data-layer Test
- File: test/features/todo/data/repositories/todo_repository_impl_test.dart
- Tinh huong remote fail -> fallback local cache
- Value cua clean architecture trong kha nang test

## Slide 7 - Demo Widget Test
- File: test/features/todo/presentation/widgets/add_todo_button_test.dart
- Script: pumpWidget -> tap -> pumpAndSettle -> expect state
- Ket qua: label Add -> Added

## Slide 8 - Demo Integration Smoke Test
- File: integration_test/app_smoke_test.dart
- Khoi dong app that, assert login screen
- Vai tro trong regression check

## Slide 9 - Mocking va Faking
- Mock: dieu khien behavior + verify call
- Fake: fallback object cho mocktail
- Khi nao dung moi loai

## Slide 10 - Best Practices
- Dat ten test theo hanh vi
- 1 test = 1 behavior
- Co happy path va failure path
- Tranh phu thuoc network/time/random

## Slide 11 - Coverage va CI
- Lenh: flutter test --coverage
- Muc tieu practical theo module
- Dua vao pipeline de chan regression

## Slide 12 - Q&A + Next step
- Mo rong test cho auth/category/todo filtering matrix
- Add golden test cho giao dien
- Tich hop test report vao PR review
