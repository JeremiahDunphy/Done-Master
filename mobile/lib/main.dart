import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/jobs/screens/jobs_screen.dart';
import 'features/jobs/screens/create_job_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_TYooMQauvdEDq54NiTphI7jx'; // Replace with your key
  runApp(const MyApp());
}

class DoneApp extends StatelessWidget {
  const DoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadUser()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Done',
            themeMode: ThemeMode.dark,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFFF4D4D),
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF050505),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFFF4D4D), // Coral
                secondary: Color(0xFFF9CB28), // Gold
                surface: Color(0xFF1E293B), // Dark Blue-Grey
                background: Color(0xFF050505),
                onPrimary: Colors.white,
                onSecondary: Colors.black,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF050505),
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D4D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF4D4D)),
                ),
                labelStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            home: authProvider.isAuthenticated
                ? const JobsScreen()
                : const LoginScreen(),
            routes: {
              '/login': (ctx) => const LoginScreen(),
              '/register': (ctx) => const RegisterScreen(),
              '/home': (ctx) => const JobsScreen(),
              '/create-job': (context) => const CreateJobScreen(),
            },
          );
        },
      ),
    );
  }
}
