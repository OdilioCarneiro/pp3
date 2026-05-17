import 'package:flutter/material.dart';

class DenunciaModel {
  final String id;
  final String dispositivoId;
  final String categoria;
  final String descricao;
  final DateTime dataCriacao;
  final String status; // 'Pendente', 'Em Análise', 'Resolvido'

  DenunciaModel({
    required this.id,
    required this.dispositivoId,
    required this.categoria,
    required this.descricao,
    required this.dataCriacao,
    required this.status,
  });

  // Mapeia o JSON vindo da sua API / MongoDB
  factory DenunciaModel.fromJson(Map<String, dynamic> json) {
    return DenunciaModel(
      id: json['_id'] ?? '',
      dispositivoId: json['dispositivoId'] ?? '',
      categoria: json['categoria'] ?? 'Geral',
      descricao: json['descricao'] ?? '',
      dataCriacao: json['dataCriacao'] != null 
          ? DateTime.parse(json['dataCriacao']) 
          : DateTime.now(),
      status: json['status'] ?? 'Pendente',
    );
  }

  // Cores de status dinâmicas para o design UX
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'em análise':
      case 'analise':
        return const Color(0xFFE6A23C); // Laranja moderado
      case 'resolvido':
      case 'concluído':
        return const Color(0xFF2B5C45); // Seu verde padrão
      default:
        return const Color(0xFF909399); // Cinza para pendente
    }
  }
}