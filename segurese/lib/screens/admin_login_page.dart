import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_dashboard_page.dart'; // Vamos criar este também

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  String _categoriaSelecionada = 'Assédio';
  final TextEditingController _senhaController = TextEditingController();
  bool _isLoading = false;

  final List<String> _categorias = ['Assédio', 'Preconceito', 'Racismo', 'Perigos', 'Acidentes'];

  Future<void> _fazerLogin() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://pp3-8dg0.onrender.com/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'categoria': _categoriaSelecionada,
          'senha': _senhaController.text,
        }),
      );

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha incorreta!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Erro no catch: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4E8),
      appBar: AppBar(title: const Text('Login Administrativo'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              value: _categoriaSelecionada,
              decoration: const InputDecoration(labelText: 'Sua Categoria'),
              items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _categoriaSelecionada = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: 'Senha de Acesso'),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _fazerLogin,
                  child: const Text('Entrar no Painel'),
                ),
          ],
        ),
      ),
    );
  }
}