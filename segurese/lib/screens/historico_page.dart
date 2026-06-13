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
                   padding: const EdgeInsets.only(top: 20.0, bottom: 24.0),
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
                        letterSpacing: -1.0,
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
                    ? const Center(child: CircularProgressIndicator(color: verdeEscuro))
                    : _denuncias.isEmpty
                        ? _buildEstadoVazio(verdeEscuro)
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _denuncias.length,
                            itemBuilder: (context, index) {
                              return CardDenunciaWidget(
                                denuncia: _denuncias[index],
                                verdeEscuro: verdeEscuro,
                              );
                            },
                          ),
              ),
            ],
          ),
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

class CardDenunciaWidget extends StatefulWidget {
  final DenunciaModel denuncia;
  final Color verdeEscuro;

  const CardDenunciaWidget({
    super.key,
    required this.denuncia,
    required this.verdeEscuro,
  });

  @override
  State<CardDenunciaWidget> createState() => _CardDenunciaWidgetState();
}

class _CardDenunciaWidgetState extends State<CardDenunciaWidget> {
  bool _isExpanded = false;

 
  void _mostrarImagemGrande(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: true, 
      barrierColor: Colors.black.withValues(alpha: 0.9), 
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.7,
                ),
              ),
              
              
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.4),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color corStatusSincronizada = widget.denuncia.statusColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.verdeEscuro.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(
          color: _isExpanded ? widget.verdeEscuro.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.denuncia.categoria,
                      style: TextStyle(
                        color: widget.verdeEscuro,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: corStatusSincronizada.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.denuncia.status.toUpperCase(),
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
              
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: Text(
                  widget.denuncia.descricao,
                  maxLines: _isExpanded ? null : 3, 
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              if (!_isExpanded && widget.denuncia.fotos.isNotEmpty) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => _mostrarImagemGrande(context, widget.denuncia.fotos.first),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    /*child: Image.network(
                      widget.denuncia.fotos.first,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: widget.verdeEscuro,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 110,
                          color: widget.verdeEscuro.withValues(alpha: 0.08),
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: widget.verdeEscuro.withValues(alpha: 0.3),
                            size: 32,
                          ),
                        );
                      },
                    ),*/
                  ),
                ),
              ],

              if (_isExpanded) ...[
                const SizedBox(height: 20),
                Text(
                  'EVIDÊNCIAS ANEXADAS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: widget.verdeEscuro.withValues(alpha: 0.4),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                
                widget.denuncia.fotos.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Nenhuma foto anexada a este registro.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withValues(alpha: 0.35),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.denuncia.fotos.length, 
                          itemBuilder: (context, index) {
                            final fotoUrl = widget.denuncia.fotos[index];
                            
                            
                            return GestureDetector(
                              onTap: () => _mostrarImagemGrande(context, fotoUrl),
                              child: Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: widget.verdeEscuro.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    fotoUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                          color: widget.verdeEscuro,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.broken_image_outlined, 
                                        color: widget.verdeEscuro.withValues(alpha: 0.2),
                                        size: 32,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
              
              const SizedBox(height: 20),
              Container(height: 1, color: Colors.black.withValues(alpha: 0.02)),
              const SizedBox(height: 16),
              
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: widget.verdeEscuro.withValues(alpha: 0.3)),
                      const SizedBox(width: 6),
                      Text(
                        widget.denuncia.dataEnvioManual.isNotEmpty && widget.denuncia.horaEnvioManual.isNotEmpty
                            ? 'Enviado em ${widget.denuncia.dataEnvioManual} • ${widget.denuncia.horaEnvioManual}'
                            : 'Enviado em ${DateFormat('dd/MM/yyyy • HH:mm').format(widget.denuncia.dataCriacao.toLocal())}',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: widget.verdeEscuro.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}