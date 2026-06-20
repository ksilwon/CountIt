import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:countit/config/theme.dart';
import 'package:countit/providers/auth_provider.dart';
import 'package:countit/providers/theme_provider.dart';
import 'package:countit/screens/auth/login_screen.dart';

void main() {
  Widget wrap(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: child,
      ),
    );
  }

  testWidgets('LoginScreen pokazuje tytuł i formularz logowania', (tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('CountIt'), findsOneWidget);
    expect(find.text('Zaloguj się'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
