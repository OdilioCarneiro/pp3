import 'package:flutter/material.dart';
import 'package:segurese/preferences.dart';
import 'package:segurese/screens/onboarding/onboarding_screen.dart';
import 'package:segurese/screens/quick_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o SharedPreferences antes de rodar o app
  await UserPreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lê se o onboarding já foi visto
    bool onboardingViewed = UserPreferences.isOnboardingViewed;

    return MaterialApp(
      title: 'Segurese',
      theme: ThemeData(
        fontFamily: 'Montserrat', // Você pode adicionar sua própria fonte
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // Define a tela inicial condicionalmente
      home: onboardingViewed ? const QuickSplashScreen() : const OnboardingScreen(),
    );
  }
}