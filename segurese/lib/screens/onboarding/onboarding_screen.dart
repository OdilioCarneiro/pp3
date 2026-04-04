import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Importando animações
import 'package:segurese/models/onboarding_model.dart';
import 'package:segurese/preferences.dart';
import 'package:segurese/screens/home_page.dart';
import 'package:segurese/screens/onboarding/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  // Dados baseados nos seus SVGs exportados do Figma
  final List<OnboardingModel> _pages = [
    OnboardingModel(
      imagePath: 'assets/onboarding_1.svg',
      title: 'Track your work and get the result',
      description: 'Remember to keep track of your professional accomplishments.',
    ),
    OnboardingModel(
      imagePath: 'assets/onboarding_2.svg',
      title: 'Denuncie assédio e preconceito no campus',
      description: 'Proteja-se e ajude a construir um IFCE mais seguro e inclusivo.',
    ),
    OnboardingModel(
      imagePath: 'assets/onboarding_3.svg', // Imagem da última página
      title: 'Seja parte da mudança',
      description: 'Vamos juntos construir um ambiente acadêmico melhor.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF9F6E7); // Cor de fundo bege claro
    const Color buttonBgColor = Colors.black;
    const Color buttonTextColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // O Carrossel de Páginas (Imagens, Títulos, Descrições)
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(model: _pages[index]);
            },
          ),

          // Elementos Fixos Inferiores (Indicador e Botões)
          Positioned(
            bottom: 30, // Um pouco mais de espaço embaixo
            left: 24,
            right: 24,
            child: Column(
              children: [
                // 1. Indicador de Página (Pontos)
                DotsIndicator(
                  dotsCount: _pages.length,
                  position: _currentPageIndex,
                  decorator: DotsDecorator(
                    size: const Size.square(8.0),
                    activeSize: const Size(20.0, 8.0),
                    activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0)),
                    activeColor: Colors.black,
                    color: Colors.black26,
                  ),
                ),
                const SizedBox(height: 32), // Espaço entre pontos e botões

                
                AnimatedSwitcher( 
                  duration: const Duration(milliseconds: 100),
                  child: (_currentPageIndex < _pages.length - 1)
                     
                      ? Row(
                          key: const ValueKey('row_buttons'),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Botão SKIP
                            TextButton(
                              onPressed: _completeOnboarding,
                              child: const Text(
                                'SKIP',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1),
                              ),
                            ),

                            // Botão NEXT
                            ElevatedButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonBgColor,
                                foregroundColor: buttonTextColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                              ),
                              child: const Text(
                                'NEXT',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ),
                          ],
                        )
                      
                      
                      : SizedBox(
                          key: const ValueKey('start_button'),
                          width: double.infinity, // Ocupa toda a largura disponível
                          height: 55, 
                          child: ElevatedButton(
                            onPressed: _completeOnboarding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonBgColor,
                              foregroundColor: buttonTextColor,
                              elevation: 2, // Um leve sombreado no Start
                              shape: const StadiumBorder(), // Bordas totalmente arredondadas (igual ao protótipo)
                            ),
                            child: const Text(
                              'START',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold, 
                                  letterSpacing: 2), // Letras mais espalhadas profissionalmente
                            ),
                          ),
                        )
                        .animate() 
                        .fade(duration: 400.ms, delay: 200.ms)
                        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutCubic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Função para salvar que o onboarding foi visto e ir para a home
  void _completeOnboarding() async {
    // Tenta salvar, mas não impede a navegação se falhar (bom para testes)
    try {
      await UserPreferences.setOnboardingViewed(true);
    } catch (e) {
      debugPrint('Erro ao salvar preferências: $e');
    }
    
    if (!mounted) return; // Segurança do Flutter

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
}