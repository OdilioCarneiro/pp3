import 'package:flutter/material.dart';
import 'package:segurese/models/onboarding_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingModel model;

  const OnboardingPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    const Color textColor = Colors.black;
    const Color subtitleColor = Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Espaço dinâmico para a ilustração
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SvgPicture.asset(model.imagePath, fit: BoxFit.contain)
                  .animate()
                  .fade(duration: 500.ms)
                  .slideY(begin: 0.1, end: 0), // Desliza levemente de baixo para cima
            ),
          ),
          
          // Título com animação de entrada (sutil)
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double opacity, child) {
              return Opacity(
                opacity: opacity,
                child: Text(
                  model.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                )
                .animate(delay: 200.ms) // Espera a imagem começar a aparecer
                .fade(duration: 500.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
              );
            },
          ),
          const SizedBox(height: 16),
          // Descrição com animação de entrada
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double opacity, child) {
              return Opacity(
                opacity: opacity,
                child: Text(
                  model.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                )
                .animate(delay: 400.ms) // Espera o título aparecer
                .fade(duration: 500.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
              );
            },
          ),
          // Espaço para os pontos do indicador
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}