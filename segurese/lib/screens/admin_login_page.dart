import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'admin_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _senhaController = TextEditingController();
  String _categoriaSelecionada = 'Perigos';
  bool _isLoading = false;
  bool _senhaVisivel = false;

  final List<String> _categorias = [
    'Perigos',
    'Acidentes',
    'Assédio',
    'Racismo',
    'Homofobia'
  ];

  Future<void> _fazerLogin() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://pp3-8dg0.onrender.com/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'categoria': _categoriaSelecionada,
          'senha': _senhaController.text.trim(),
        }),
      );

      // Prints para depuração no console
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboardPage(categoria: _categoriaSelecionada),
            ),
          );
        }
      } else {
        _mostrarErro('Senha incorreta ou acesso negado.');
      }
    } catch (e) {
      _mostrarErro('Erro de conexão com o servidor.');
      print('Erro no catch: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color verdeEscuro = Color(0xFF133626);
    // Cor branca translúcida para os inputs estilo "glass"
    final Color inputBackground = Colors.white.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: verdeEscuro,
      // AppBar invisível apenas para dar o botão de voltar elegante
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Fecha o teclado ao clicar fora
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO APP (Substitua pelo seu widget de imagem se tiver arquivo físico)
                // Ex: Image.asset('assets/logo.png', height: 100)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16.0)
                  ),
                  child: SvgPicture.asset(
                    'assets/app_logo.svg',
                    height: 120,
                  ),
                ),
                const SizedBox(height: 24),
                
                // TÍTULO
                const Text(
                  'Segurese Admin',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF6F4E8),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Insira suas credenciais de departamento',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 48),

                // CAMPO 1: SELEÇÃO DE CATEGORIA (Dropdown Customizado)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'DEPARTAMENTO / CATEGORIA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: inputBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _categoriaSelecionada,
                      isExpanded: true,
                      dropdownColor: verdeEscuro, // Fundo do menu aberto também verde
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      items: _categorias.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _categoriaSelecionada = newValue);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // CAMPO 2: SENHA
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SENHA DE ACESSO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _senhaController,
                  obscureText: !_senhaVisivel,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputBackground,
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _senhaVisivel ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                    ),
                    hintText: '••••••••',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFF6F4E8), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // BOTÃO DE ENTRAR PREMIUM
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _fazerLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6F4E8), // Botão claro contrasta com o fundo escuro
                      disabledBackgroundColor: const Color(0xFFF6F4E8).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: verdeEscuro, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Acessar Painel',
                            style: TextStyle(
                              color: verdeEscuro,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}