
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

  // NOVA LÓGICA: Gera e salva um ID único na memória do celular
  Future<void> _obterIdDispositivo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Tenta buscar o ID que já está salvo no aparelho
      String? deviceId = prefs.getString('meu_device_id_unico');

      // Se for a primeira vez abrindo o app, a variável será nula
      if (deviceId == null) {
        // Gera um código único
        deviceId = const Uuid().v4(); 
        // Salva na memória do celular para as próximas vezes
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
              // Cabeçalho da Tela
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
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Histórico seguro e anônimo deste aparelho.',
                      style: TextStyle(
                        color: verdeEscuro.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Lista de registros vindos do banco
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF2B5C45)),
                      )
                    : _denuncias.isEmpty
                        ? _buildEstadoVazio()
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _denuncias.length,
                            itemBuilder: (context, index) {
                              return _buildCardDenuncia(_denuncias[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Design UI Premium para o Card da Denúncia
  Widget _buildCardDenuncia(DenunciaModel denuncia) {
    const Color verdePrincipal = Color(0xFF2B5C45);
    final String dataFormatada = DateFormat('dd/MM/yyyy • HH:mm').format(denuncia.dataCriacao);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF133626).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.03),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categoria + Badge de Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    denuncia.categoria,
                    style: const TextStyle(
                      color: Color(0xFF133626),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                
                // Badge de Status Elegante
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: denuncia.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    denuncia.status.toUpperCase(),
                    style: TextStyle(
                      color: denuncia.statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Corpo / Descrição resumida da denúncia
            Text(
              denuncia.descricao,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF133626).withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Divisor sutil interno
            Container(height: 1, color: Colors.grey.shade100),
            
            const SizedBox(height: 12),
            
            // Data do Envio
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: verdePrincipal.withValues(alpha: 0.5)),
                const SizedBox(width: 6),
                Text(
                  'Enviado em $dataFormatada',
                  style: TextStyle(
                    color: verdePrincipal.withValues(alpha: 0.6),
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

  // UI para quando o dispositivo não tiver nenhuma denúncia feita ainda
  Widget _buildEstadoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B5C45).withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_turned_in_rounded, size: 64, color: Color(0xFF2B5C45)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma denúncia por aqui',
              style: TextStyle(
                color: Color(0xFF133626),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'As manifestações enviadas por este dispositivo aparecerão listadas nesta área.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF133626).withValues(alpha: 0.5),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}