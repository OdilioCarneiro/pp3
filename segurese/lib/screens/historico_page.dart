import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:segurese/models/denuncia_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoricoDenunciasPage extends StatefulWidget {
  const HistoricoDenunciasPage({super.key});

  @override
  State<HistoricoDenunciasPage> createState() => _HistoricoDenunciasPageState();
}

class _HistoricoDenunciasPageState extends State<HistoricoDenunciasPage> {
  String _deviceId = "Carregando...";
  bool _isLoading = true;
  List<DenunciaModel> _denuncias = [];

  @override
  void initState() {
    super.initState();
    _inicializarTela();
  }

  Future<void> _inicializarTela() async {
    await _obterIdDispositivo();
    await _buscarDenunciasDoMongo();
  }

  Future<void> _obterIdDispositivo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('meu_device_id_unico');

      if (deviceId == null) {
        deviceId = const Uuid().v4(); 
        await prefs.setString('meu_device_id_unico', deviceId);
      }

      _deviceId = deviceId;
    } catch (e) {
      _deviceId = "Erro ao obter ID";
    }
  }

  Future<void> _buscarDenunciasDoMongo() async {
    setState(() => _isLoading = true);

    try {
      final String apiUrl = 'https://pp3-8dg0.onrender.com/minhas-denuncias/$_deviceId';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> dadosJson = json.decode(response.body);
        
        setState(() {
          _denuncias = dadosJson.map((json) => DenunciaModel.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        print('Erro na API: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Erro de conexão: $e');
      setState(() => _isLoading = false);
    }
  }

  // MÉTODO COMPATÍVEL: Sincroniza as cores dos status perfeitamente com o Painel ADM
  Color _pegarCorStatusOriginal(String status) {
    switch (status.toLowerCase()) {
      case 'pendente': return const Color(0xFFE11D48); 
      case 'visualizado': return const Color.fromARGB(255, 255, 162, 0); 
      case 'em análise': return const Color.fromARGB(255, 212, 232, 0); 
      case 'protocolado': return const Color(0xFF16A34A); 
      case 'concluído': return const Color(0xFF0F766E);  
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color begeColor = Color(0xFFF6F4E8);
    const Color brancoColor = Colors.white;
    const Color verdeEscuro = Color(0xFF133626);

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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Center(
                 child: Padding(
                   padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                   child: SvgPicture.asset(
                     'assets/logo_green.svg',
                     height: 40,
                   ),
                 ),
               ),
              
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suas Denúncias',
                      style: TextStyle(
                        color: verdeEscuro,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0, // Alinhado ao estilo iOS do Admin
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Histórico seguro e anônimo deste aparelho.',
                      style: TextStyle(
                        color: verdeEscuro.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: verdeEscuro),
                      )
                    : _denuncias.isEmpty
                        ? _buildEstadoVazio(verdeEscuro)
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _denuncias.length,
                            itemBuilder: (context, index) {
                              return _buildCardDenuncia(_denuncias[index], verdeEscuro);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardDenuncia(DenunciaModel denuncia, Color verdeEscuro) {
    final String dataFormatada = DateFormat('dd/MM/yyyy • HH:mm').format(denuncia.dataCriacao);
    
    // Mapeia o status de forma idêntica à página de administração
    final Color corStatusSincronizada = _pegarCorStatusOriginal(denuncia.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: verdeEscuro.withValues(alpha: 0.02), // Sombra super suave do Bento Grid
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.02),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24), // Ajustado para 24 para dar mais respiro à leitura
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    denuncia.categoria,
                    style: TextStyle(
                      color: verdeEscuro,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                
                // Badge de Status Alinhado com o Design System do Admin (Pill iOS 17)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: corStatusSincronizada.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8), // Cantos retos sutis estilo Apple
                  ),
                  child: Text(
                    denuncia.status.toUpperCase(),
                    style: TextStyle(
                      color: corStatusSincronizada,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              denuncia.descricao,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 20),
            Container(height: 1, color: Colors.black.withValues(alpha: 0.02)), // Divisor sutil transparente
            const SizedBox(height: 16),
            
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: verdeEscuro.withValues(alpha: 0.3)),
                const SizedBox(width: 6),
                Text(
                  'Enviado em $dataFormatada',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoVazio(Color verdeEscuro) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: verdeEscuro.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.assignment_turned_in_rounded, size: 64, color: verdeEscuro),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma denúncia por aqui',
              style: TextStyle(
                color: verdeEscuro,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'As manifestações enviadas por este dispositivo aparecerão listadas nesta área.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: verdeEscuro.withValues(alpha: 0.4),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}