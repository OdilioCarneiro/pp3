import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; 
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentTabIndex = 0;


  final List<Map<String, dynamic>> _instituicoes = [
    {'title': 'Ouvidoria', 'icon': Icons.gavel_rounded}, 
    {'title': 'NEABI', 'icon': Icons.diversity_3_rounded}, 
    {'title': 'NAPNE', 'icon': Icons.accessible_forward_rounded}, 
    {'title': 'Assistência', 'icon': Icons.psychology_rounded}, 
    {'title': 'Saúde', 'icon': Icons.health_and_safety_rounded}, 
  ];


  final List<String> _tiposDenuncia = [
    'Perigos',
    'Acidentes',
    'Assédio',
    'Racismo',
    'Homofobia'
  ];

  @override
  Widget build(BuildContext context) {
    const Color begeColor = Color(0xFFF6F4E8); 
    const Color brancoColor = Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              begeColor,
              brancoColor,
            ],
          ),
        ),
        child: Stack(
          children: [
          
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // lugar da logo
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: SvgPicture.asset(
                      'assets/logo_green.svg',
                      height: 40,
                    ),
                  ),

                  // lista hotizontal com os botoes
                  SizedBox(
                    height: 55,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _instituicoes.length,
                      itemBuilder: (context, index) {
                        return _buildInstitutionChip(_instituicoes[index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  //carrossel
                  Expanded(
                    child: CarouselSlider.builder(
                      carouselController: _carouselController,
                      itemCount: _tiposDenuncia.length,
                      itemBuilder: (context, index, realIndex) {
                        return _buildCarouselCard(_tiposDenuncia[index], index);
                      },
                      options: CarouselOptions(
                        height: 500, 
                        viewportFraction: 0.8, 
                        enlargeCenterPage: true, 
                        enlargeStrategy: CenterPageEnlargeStrategy.scale, 
                        enableInfiniteScroll: true, 
                        scrollPhysics: const BouncingScrollPhysics(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),

            // navigation bar inferior
            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: _buildAppleGlassTabBar(),
            ),
          ],
        ),
      ),
    );
  }



 // design do botão das instituições (chips) parte superior
  Widget _buildInstitutionChip(Map<String, dynamic> inst) {
    return Container(
      margin: const EdgeInsets.only(right: 12, bottom: 8), 
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65), 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(
          color: Colors.white, 
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF133626).withValues(alpha: 0.05), 
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent, 
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            //proximo passo abrir caminho para a página
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Icon(
                  inst['icon'],
                  size: 20, 
                  color: const Color(0xFF2B5C45), 
                ),
                const SizedBox(width: 8), 
                Text(
                  inst['title'],
                  style: const TextStyle(
                    color: Color(0xFF133626), 
                    fontWeight: FontWeight.w600, 
                    fontSize: 14,
                    letterSpacing: 0.3, 
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // card do Carrossel
  Widget _buildCarouselCard(String title, int index) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2B5C45), 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          
          Positioned(
            bottom: 24,
            left: 32,
            right: 32,
            child: _buildAppleGlassButton(),
          ),
        ],
      ),
    );
  }

  // botao de denuncia 
  Widget _buildAppleGlassButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12), 
            blurRadius: 10,
            offset: const Offset(0, 4), 
          ),
        ],
      ),
      child: ClipRRect( 
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter( 
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), 
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08), 
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3), 
                width: 0.8, 
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  // Futuro: Navegar para a tela de denúncia
                },
                child: const Center(
                  child: Text(
                    'Denuncie já',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // tabBar 
  Widget _buildAppleGlassTabBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), 
          child: Container(
            height: 75,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEBE6D2).withValues(alpha: 0.55), 
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5), 
                width: 1.0, 
              ),
            ),
            child: Row(
              children: [
                _buildTabItem(
                  icon: Icons.admin_panel_settings_rounded, 
                  label: 'Home',
                  index: 0,
                ),
                _buildTabItem(
                  icon: Icons.person_rounded, 
                  label: 'Minhas denúncias',
                  index: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // botoes da TabBar
  Widget _buildTabItem({required IconData icon, required String label, required int index}) {
    bool isActive = _currentTabIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isActive ? Colors.black.withValues(alpha: 0.06) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF133626), 
                size: 26,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF133626),
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}