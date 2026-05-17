import 'package:flutter/material.dart';
import 'admin_login_page.dart';

class SaibaMaisPage extends StatelessWidget {
  const SaibaMaisPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color verdeEscuro = Color(0xFF133626);
    const Color fundo = Color(0xFFF6F4E8);

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: fundo,
        elevation: 0,
        iconTheme: const IconThemeData(color: verdeEscuro),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título principal
              const Text(
                'Saiba Mais',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: verdeEscuro,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Entenda como o Segurese protege você e como suas denúncias são tratadas com segurança e total sigilo.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Seção de Cards Informativos (Acolhimento removido)
              _buildInfoCard(
                icon: Icons.shield_outlined,
                title: 'Sigilo Absoluto',
                description: 'Sua identidade é rigorosamente protegida. Nenhuma informação pessoal é compartilhada sem sua permissão.',
                iconColor: verdeEscuro,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.gavel_outlined,
                title: 'Ação Imediata',
                description: 'Cada relato é analisado com seriedade pelos departamentos responsáveis para que as providências sejam tomadas.',
                iconColor: verdeEscuro,
              ),

              const SizedBox(height: 48),

              // Seção de Créditos (Desenvolvedores)
              const Text(
                'EQUIPE DE DESENVOLVIMENTO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black38,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              _buildDeveloperCard(
                nome: 'Odilio Carneiro',
                github: 'OdilioCarneiro',
                verdeEscuro: verdeEscuro,
              ),
              _buildDeveloperCard(
                nome: 'Lara Yslen',
                github: 'LaraYslen-07',
                verdeEscuro: verdeEscuro,
              ),

              const SizedBox(height: 48),

              // Área do Administrador
              Center(
                child: Column(
                  children: [
                    const Divider(color: Colors.black12, thickness: 1),
                    const SizedBox(height: 32),
                    const Text(
                      'ÁREA RESTRITA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black38,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminLoginPage()),
                        );
                      },
                      icon: const Icon(Icons.admin_panel_settings_outlined, size: 20),
                      label: const Text(
                        'Acesso Administrativo',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: verdeEscuro,
                        side: const BorderSide(color: verdeEscuro, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Função para criar o card de informações do app
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF133626),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Nova Função: Cria os cartões de desenvolvedor
  Widget _buildDeveloperCard({
    required String nome,
    required String github,
    required Color verdeEscuro,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)), // Borda super suave
      ),
      child: Row(
        children: [
          // Ícone de avatar
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: verdeEscuro.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, color: verdeEscuro),
          ),
          const SizedBox(width: 16),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF133626),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.code, size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      'github.com/$github',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}