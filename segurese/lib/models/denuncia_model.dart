import 'package:flutter/material.dart';

class DenunciaModel {
  final String id;
  final String dispositivoId;
  final String categoria;
  final String descricao;
  final DateTime dataCriacao;
  final String status;
  final List<String> fotos;
  final String dataEnvioManual; 
  final String horaEnvioManual;

  DenunciaModel({
    required this.id,
    required this.dispositivoId,
    required this.categoria,
    required this.descricao,
    required this.dataCriacao,
    required this.status,
    required this.fotos,
    required this.dataEnvioManual, 
    required this.horaEnvioManual, 
  });

  factory DenunciaModel.fromJson(Map<String, dynamic> json) {
    var fotosVindasDoBanco = json['fotos'] ?? json['imagens'] ?? [];
    List<String> listaFotosFormatada = List<String>.from(fotosVindasDoBanco);

    return DenunciaModel(
      id: json['_id'] ?? '',
      dispositivoId: json['dispositivoId'] ?? '',
      categoria: json['categoria'] ?? 'Geral',
      descricao: json['descricao'] ?? '',
      dataCriacao: json['dataCriacao'] != null 
          ? DateTime.parse(json['dataCriacao']) 
          : DateTime.now(),
      status: json['status'] ?? 'Pendente',
      fotos: listaFotosFormatada,
      dataEnvioManual: json['data'] ?? '', 
      horaEnvioManual: json['hora'] ?? '',
    );
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pendente': return const Color(0xFFE11D48); 
      case 'visualizado': return const Color.fromARGB(255, 255, 162, 0); 
      case 'em análise': return const Color.fromARGB(255, 212, 232, 0); 
      case 'protocolado': return const Color(0xFF16A34A); 
      case 'concluído': return const Color(0xFF0F766E); 
      default:
        return const Color(0xFF909399); 
    }
  }
}