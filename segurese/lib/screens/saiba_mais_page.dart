import 'package:flutter/material.dart';
import 'admin_login_page.dart'; // Vamos criar este arquivo a seguir

class SaibaMaisPage extends StatelessWidget {
  const SaibaMaisPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color verdeEscuro = Color(0xFF133626);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4E8),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.volunteer_activism_rounded, size: 80, color: verdeEscuro),
            const SizedBox(height: 24),
            const Text(
              'Sobre o Projeto',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: verdeEscuro),
            ),
            const SizedBox(height: 16),
            const Text(
              'Este aplicativo foi desenvolvido com o intuito de oferecer um canal seguro, anônimo e eficiente para denúncias dentro da nossa comunidade. Nosso foco é a transparência e a segurança de todos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 40),
            const Text('DESENVOLVEDORES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const Divider(),
            _buildDevInfo('Seu Nome', 'github.com/seu-user'),
            _buildDevInfo('Nome do Colega', 'github.com/colega-user'),
            
            const SizedBox(height: 80),
            
            // Botão Discreto de Admin
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminLoginPage()),
                );
              },
              child: Text(
                'Acesso Administrativo',
                style: TextStyle(color: verdeEscuro.withOpacity(0.4), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevInfo(String nome, String github) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text(github, style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }
}