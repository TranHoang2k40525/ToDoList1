import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/auth/presentation/pages/login_page.dart';

class ToDoListApp extends StatelessWidget {
  const ToDoListApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1E95F4);
    final colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);

    return MaterialApp(
      title: 'ToDoListApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        splashFactory: InkRipple.splashFactory,
        splashColor: const Color(0xFF22A8FF).withValues(alpha: 0.42),
        highlightColor: const Color(0xFF8CD8FF).withValues(alpha: 0.34),
        hoverColor: const Color(0xFFB6E8FF).withValues(alpha: 0.36),
        canvasColor: const Color(0xFFEAF8FF),
        fontFamily: 'SF Pro Text',
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white.withValues(alpha: 0.82),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.82),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blueGrey.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blueGrey.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: seed, width: 1.3),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            elevation: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed) ? 1 : 4,
            ),
            shadowColor: WidgetStateProperty.all(
              const Color(0xFF3BAFFF).withValues(alpha: 0.42),
            ),
            overlayColor: WidgetStateProperty.all(
              const Color(0xFF66C5FF).withValues(alpha: 0.42),
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return const Color(0xFFBFDDF0);
              }
              return const Color(0xFF2E9BEE);
            }),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            elevation: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed) ? 1 : 3,
            ),
            shadowColor: WidgetStateProperty.all(
              const Color(0xFF41B8FF).withValues(alpha: 0.38),
            ),
            overlayColor: WidgetStateProperty.all(
              const Color(0xFF7ED3FF).withValues(alpha: 0.42),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            side: WidgetStateProperty.all(
              BorderSide(color: const Color(0xFF6BC4FA).withValues(alpha: 0.7)),
            ),
            overlayColor: WidgetStateProperty.all(
              const Color(0xFF88D7FF).withValues(alpha: 0.4),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            overlayColor: WidgetStateProperty.all(
              const Color(0xFF8FD8FF).withValues(alpha: 0.38),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(const CircleBorder()),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFF71C9FF).withValues(alpha: 0.26);
              }
              if (states.contains(WidgetState.hovered)) {
                return const Color(0xFFBCE8FF).withValues(alpha: 0.26);
              }
              return null;
            }),
            overlayColor: WidgetStateProperty.all(
              const Color(0xFF73CDFF).withValues(alpha: 0.4),
            ),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const LoginPage(),
    );
  }
}
