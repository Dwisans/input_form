import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash/welcome_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

// Buat key global di luar class
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.checkLoginStatus();

  runApp(
    ChangeNotifierProvider(create: (_) => authProvider, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return MaterialApp(
      navigatorKey: navigatorKey, // PASANG KEY DI SINI
      debugShowCheckedModeBanner: false,
      home: auth.isLoggedIn ? const DashboardScreen() : const WelcomeScreen(),
      routes: {
        '/login': (context) => const WelcomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
