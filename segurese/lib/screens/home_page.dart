import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'formulario_denuncia.dart';
import 'package:segurese/models/instituicao_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentTabIndex = 0;
  
  int _selectedIndex = 0;
  late final List<InstituicaoModel> _instituicoes;

  // 🔥 MAPA DE EMAILS POR CATEGORIA
  final Map<String, String> _emailMapping = {
    'Perigos': 'yslennlaragb@gmail.com',
    'Acidentes': 'saude@ifce.com',
    'Assédio': 'recursos_humanos@ifce.com',
    'Racismo': 'diversidade@ifce.com',
    'Homofobia': 'odilio.carneiro63@aluno.ifce.edu.br',
  };

  @override
  void initState() {
    super.initState();
    _instituicoes = InstituicaoModel.getDadosIfceFortaleza();
  }

  void _onChipTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    _carouselController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    _showBioFullScreen(context, _instituicoes[index]);
  }

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
            colors: [begeColor, brancoColor],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // 1. Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: SvgPicture.asset(
                      'assets/logo_green.svg',
                      height: 40,
                    ),
                  ),

                  SizedBox(
                    height: 55,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _instituicoes.length,
                      itemBuilder: (context, index) {
                        return _buildInstitutionChip(_instituicoes[index], index);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  //  Carrossel 
                  CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: _instituicoes.length,
                    itemBuilder: (context, index, realIndex) {
                      return _buildTipoDenunciaCard(_instituicoes[index]);
                    },
                    options: CarouselOptions(
                      height: 440,
                      viewportFraction: 0.68,
                      enlargeCenterPage: true,
                      enlargeStrategy: CenterPageEnlargeStrategy.scale,
                      enableInfiniteScroll: true,
                      scrollPhysics: const BouncingScrollPhysics(),
                    ),
                  ),
                ],
              ),
            ),

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

  Widget _buildInstitutionChip(InstituicaoModel data, int index) {
    bool isActive = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2B5C45) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? const Color(0xFF2B5C45) : Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF133626).withValues(alpha: isActive ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _onChipTapped(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  data.chipIcon,
                  size: 20,
                  color: isActive ? Colors.white : const Color(0xFF2B5C45),
                ),
                const SizedBox(width: 8),
                Text(
                  data.chipTitle,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF133626),
                    fontWeight: FontWeight.w700,
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

  Widget _buildTipoDenunciaCard(InstituicaoModel data) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2B5C45),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF133626).withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              data.cardTitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: _buildGlassButton('Denuncie já', data.cardTitle),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton(String label, String categoria) {
    // 🔥 PEGA EMAIL CORRETO DA CATEGORIA
    final String emailDestino = _emailMapping[categoria] ?? 'default@ifce.com';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormularioDenuncia(
                        categoria: categoria,
                        emailDestino: emailDestino, // 🔥 EMAIL CORRETO POR CATEGORIA
                      ),
                    ),
                  );
                },
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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

  void _showBioFullScreen(BuildContext context, InstituicaoModel data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 24),
                    height: 5,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B5C45).withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(data.chipIcon, size: 48, color: const Color(0xFF2B5C45)),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          data.bioTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF133626),
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        const Text(
                          'Sobre',
                          style: TextStyle(
                            color: Color(0xFF2B5C45),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.bioDesc,
                          style: TextStyle(
                            color: const Color(0xFF133626).withValues(alpha: 0.75),
                            fontSize: 16,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        const Text(
                          'Áreas de Atuação',
                          style: TextStyle(
                            color: Color(0xFF2B5C45),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 12,
                          children: data.atuacao.map((item) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F4E8),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF2B5C45).withValues(alpha: 0.1)),
                            ),
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2B5C45),
                              ),
                            ),
                          )).toList(),
                        ),

                        const SizedBox(height: 32),

                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF133626),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.support_agent_rounded, color: Colors.white, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    'CONTATOS OFICIAIS',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                data.bioContact,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.6,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppleGlassTabBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 12),
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
              color: const Color(0xFFEBE6D2).withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                _buildTabItem(icon: Icons.admin_panel_settings_rounded, label: 'Home', index: 0),
                _buildTabItem(icon: Icons.person_rounded, label: 'Minhas denúncias', index: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({required IconData icon, required String label, required int index}) {
    bool isActive = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isActive ? Colors.black.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF133626), size: 26),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF133626),
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}