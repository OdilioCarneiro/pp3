import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:segurese/preferences.dart';
import 'package:segurese/screens/onboarding/onboarding_screen.dart';
import 'package:segurese/screens/quick_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UserPreferences.init();
   WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
 
    bool onboardingViewed = UserPreferences.isOnboardingViewed;

    return MaterialApp(
      title: 'Segurese',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      
      home: onboardingViewed ? const QuickSplashScreen() : const OnboardingScreen(),
    );
  }
}