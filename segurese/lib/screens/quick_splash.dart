import 'package:flutter/material.dart';
import 'package:segurese/screens/home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuickSplashScreen extends StatefulWidget {
  const QuickSplashScreen({super.key});

  @override
  State<QuickSplashScreen> createState() => _QuickSplashScreenState();
}

class _QuickSplashScreenState extends State<QuickSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navega para a HomePage após 2.5 segundos
    Future.delayed(const Duration(milliseconds: 2500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color logoBgColor = Color(0xFF133626); // Verde escuro IFCE

    return Scaffold(
      backgroundColor: logoBgColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: SvgPicture.asset(
            'assets/app_logo.svg', 
            width: 170,
            height: 223,
            fit: BoxFit.contain,
          )
              .animate() // <-- Começa a mágica aqui
              .fade(duration: 800.ms) // Aparece suavemente em quase 1 segundo
              .scale(
                begin: const Offset(0.8, 0.8), // Começa com 80% do tamanho
                end: const Offset(1.0, 1.0),   // Termina no tamanho normal
                curve: Curves.easeOutCubic,    // Faz o final do movimento ser bem suave
              ),
        ),
      ),
    );
  }
}