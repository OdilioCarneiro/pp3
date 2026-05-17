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

  // Lista com a primeira letra maiúscula para combinar com o banco por padrão
  final List<String> _opcoesStatus = [
    'Pendente',
    'Visualizado',
    'Em análise',
    'Protocolado',
    'Concluído'
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF133626)),
      ),
    );

    try {
      final response = await http.patch(
        Uri.parse('https://pp3-8dg0.onrender.com/admin/denuncias/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': novoStatus}),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        _mostrarAviso('Status atualizado com sucesso!', sucesso: true);
        _carregarDenuncias();
      } else {
        _mostrarAviso('Erro ao atualizar status.');
      }
    } catch (e) {
      Navigator.pop(context);
      _mostrarAviso('Erro de conexão ao atualizar.');
    }
  }

  void _mostrarAviso(String mensaje, {bool sucesso = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: sucesso ? const Color(0xFF133626) : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _abrirMenuStatus(String id, String statusAtual) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Alterar Estado',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF133626),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                ..._opcoesStatus.map((status) {
                  // Compara ignorando maiúsculas/minúsculas para evitar bugs de digitação
                  bool isAtual = status.toLowerCase() == statusAtual.toLowerCase();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isAtual ? const Color(0xFF133626).withOpacity(0.04) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      title: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          letterSpacing: 0.8,
                          fontWeight: isAtual ? FontWeight.w800 : FontWeight.w600,
                          color: isAtual ? const Color(0xFF133626) : Colors.black45,
                        ),
                      ),
                      trailing: isAtual 
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF133626), size: 22) 
                          : const Icon(Icons.circle_outlined, color: Colors.black12, size: 22),
                      onTap: () {
                        Navigator.pop(context);
                        if (!isAtual) _atualizarStatus(id, status);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _pegarCorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pendente': return const Color(0xFFE11D48); // Vermelho vibrante Apple
      case 'visualizado': return const Color(0xFF0284C7); // Azul iOS
      case 'em análise': return const Color(0xFF4F46E5); // Indigo profundo
      case 'protocolado': return const Color(0xFF0F766E); // Teal fechado
      case 'concluído': return const Color(0xFF16A34A); // Verde Esmeralda
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color verdeEscuro = Color(0xFF133626);
    const Color fundo = Color(0xFFF6F4E8);

    // MUDANÇA AQUI: Filtra buscando por 'pendente' ignorando diferenças de maiúsculas/minúsculas
    int pendentes = _denuncias.where((d) => (d['status'] ?? 'Pendente').toString().toLowerCase() == 'pendente').length;

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: fundo,
        elevation: 0,
        foregroundColor: verdeEscuro,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoria,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1.0, color: verdeEscuro),
            ),
            Text(
              'Painel de Controle Institucional',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: verdeEscuro.withOpacity(0.5)),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: verdeEscuro, size: 22),
                    onPressed: _carregarDenuncias,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: verdeEscuro, strokeWidth: 3))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Minitabs (Resumo estilo Apple Widgets)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildBentoStatCard(
                            label: 'Total de Relatos',
                            value: _denuncias.length.toString(),
                            icon: Icons.folder_open_rounded,
                            bgColor: Colors.white,
                            textColor: verdeEscuro,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBentoStatCard(
                            label: 'Pendentes',
                            value: pendentes.toString(),
                            icon: Icons.error_outline_rounded,
                            bgColor: pendentes > 0 ? const Color(0xFFE11D48) : Colors.white,
                            textColor: pendentes > 0 ? Colors.white : verdeEscuro,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista principal de denúncias
                _denuncias.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.space_dashboard_outlined, size: 64, color: verdeEscuro.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma ocorrência registrada.',
                                style: TextStyle(color: verdeEscuro.withOpacity(0.4), fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final denuncia = _denuncias[index];
                              final String id = denuncia['_id'] ?? '';
                              final String descricao = denuncia['descricao'] ?? 'Sem descrição';
                              final String local = denuncia['local'] ?? 'Não informado';
                              // MUDANÇA AQUI: Se o campo status vier nulo do banco, assume 'Pendente' automaticamente
                              final String status = denuncia['status'] ?? 'Pendente';
                              final String data = denuncia['data'] ?? '';

                              final Color corStatus = _pegarCorStatus(status);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.black.withOpacity(0.02), width: 1),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () => _abrirMenuStatus(id, status),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Badge Estilo Pill do iOS 17
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: corStatus.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                status.toUpperCase(),
                                                style: TextStyle(
                                                  color: corStatus,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              data,
                                              style: TextStyle(
                                                color: Colors.black.withOpacity(0.3),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        Text(
                                          descricao,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E1E1E),
                                            height: 1.5,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Icon(Icons.location_on_rounded, size: 16, color: verdeEscuro.withOpacity(0.3)),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      local,
                                                      style: TextStyle(
                                                        color: Colors.black.withOpacity(0.4),
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              color: Colors.black.withOpacity(0.2),
                                              size: 20,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: _denuncias.length,
                          ),
                        ),
                      ),
              ],
            ),
    );
  }

  Widget _buildBentoStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: bgColor == Colors.white ? Border.all(color: Colors.black.withOpacity(0.02)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -1.0),
              ),
              Icon(icon, size: 20, color: textColor.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}