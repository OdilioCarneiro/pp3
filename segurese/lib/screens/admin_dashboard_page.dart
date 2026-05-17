import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDashboardPage extends StatefulWidget {
  final String categoria;

  const AdminDashboardPage({super.key, required this.categoria});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<dynamic> _denuncias = [];
  bool _isLoading = true;

  // As opções de status que o admin pode escolher
  final List<String> _opcoesStatus = [
    'pendente',
    'visualizado',
    'em análise',
    'protocolado',
    'concluído'
  ];

  @override
  void initState() {
    super.initState();
    _carregarDenuncias();
  }

  Future<void> _carregarDenuncias() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://pp3-8dg0.onrender.com/admin/denuncias/${widget.categoria}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _denuncias = json.decode(response.body);
        });
      } else {
        _mostrarAviso('Erro ao carregar as denúncias.');
      }
    } catch (e) {
      _mostrarAviso('Erro de conexão: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _atualizarStatus(String id, String novoStatus) async {
    // Exibe um loading enquanto atualiza
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.patch(
        Uri.parse('https://pp3-8dg0.onrender.com/admin/denuncias/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': novoStatus}),
      );

      // Fecha o loading
      Navigator.pop(context);

      if (response.statusCode == 200) {
        _mostrarAviso('Status atualizado com sucesso!', sucesso: true);
        _carregarDenuncias(); // Recarrega a lista para mostrar a mudança
      } else {
        _mostrarAviso('Erro ao atualizar status.');
      }
    } catch (e) {
      Navigator.pop(context); // Fecha o loading
      _mostrarAviso('Erro de conexão ao atualizar.');
    }
  }

  void _mostrarAviso(String mensagem, {bool sucesso = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: sucesso ? Colors.green : Colors.red,
      ),
    );
  }

  void _abrirMenuStatus(String id, String statusAtual) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Atualizar Status',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF133626)),
              ),
              const SizedBox(height: 16),
              ..._opcoesStatus.map((status) {
                bool isAtual = status == statusAtual;
                return ListTile(
                  title: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: isAtual ? FontWeight.bold : FontWeight.normal,
                      color: isAtual ? const Color(0xFF2B5C45) : Colors.black87,
                    ),
                  ),
                  trailing: isAtual ? const Icon(Icons.check, color: Color(0xFF2B5C45)) : null,
                  onTap: () {
                    Navigator.pop(context); // Fecha o menu
                    if (!isAtual) {
                      _atualizarStatus(id, status);
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Color _pegarCorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pendente': return Colors.orange;
      case 'visualizado': return Colors.blue;
      case 'em análise': return Colors.purple;
      case 'protocolado': return Colors.teal;
      case 'concluído': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color verdeEscuro = Color(0xFF133626);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4E8),
      appBar: AppBar(
        title: Text('Painel - ${widget.categoria}'),
        backgroundColor: verdeEscuro,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDenuncias,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: verdeEscuro))
          : _denuncias.isEmpty
              ? const Center(child: Text('Nenhuma denúncia encontrada para esta categoria.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _denuncias.length,
                  itemBuilder: (context, index) {
                    final denuncia = _denuncias[index];
                    final String id = denuncia['_id'] ?? '';
                    final String descricao = denuncia['descricao'] ?? 'Sem descrição';
                    final String local = denuncia['local'] ?? 'Local não informado';
                    // Se não tiver status, assume 'pendente'
                    final String status = denuncia['status'] ?? 'pendente';
                    final String data = denuncia['data'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    data,
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _pegarCorStatus(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _pegarCorStatus(status)),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: _pegarCorStatus(status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              descricao,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(local, style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _abrirMenuStatus(id, status),
                                icon: const Icon(Icons.edit_note, color: Colors.white),
                                label: const Text('Atualizar Status', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2B5C45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}