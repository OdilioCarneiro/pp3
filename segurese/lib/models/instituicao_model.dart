import 'package:flutter/material.dart';

class InstituicaoModel {
  final String chipTitle;
  final IconData chipIcon;
  final String cardTitle;
  final String bioTitle;
  final String bioDesc;
  final String bioContact;
  final List<String> atuacao; // Lista extra para mais informações

  InstituicaoModel({
    required this.chipTitle,
    required this.chipIcon,
    required this.cardTitle,
    required this.bioTitle,
    required this.bioDesc,
    required this.bioContact,
    required this.atuacao,
  });

  // Lista estática com os dados REAIS do IFCE Campus Fortaleza
  static List<InstituicaoModel> getDadosIfceFortaleza() {
    return [
      InstituicaoModel(
        chipTitle: 'Ouvidoria',
        chipIcon: Icons.gavel_rounded,
        cardTitle: 'Perigos',
        bioTitle: 'Ouvidoria do IFCE',
        bioDesc: 'Canal oficial e imparcial para apresentar denúncias, reclamações e sugestões. O sigilo é garantido e as demandas são encaminhadas diretamente às áreas competentes da instituição.',
        bioContact: 'Ouvidor: Antonio José Pessoa\nE-mail: ouvidoria@ifce.edu.br\nTel: (85) 3401-2333',
        atuacao: ['Sigilo de identidade', 'Encaminhamento oficial', 'Acompanhamento de processos'],
      ),
      InstituicaoModel(
        chipTitle: 'Saúde',
        chipIcon: Icons.health_and_safety_rounded,
        cardTitle: 'Acidentes',
        bioTitle: 'Coord. de Serviço de Saúde (CSSAUDE)',
        bioDesc: 'Atua nos primeiros socorros em acidentes no campus e promove campanhas de educação em saúde. O espaço Mais Saúde Socorro Gentil é focado no bem-estar físico e mental da comunidade acadêmica.',
        bioContact: 'E-mail: saude.fortaleza@ifce.edu.br\nPsicologia: psicologia.fortaleza@ifce.edu.br\nTel/WhatsApp: (85) 3307-3649\nHorário: 7h às 22h',
        atuacao: ['Primeiros socorros', 'Consultas (Psicologia, Psiquiatria, Odontologia)', 'Testagem rápida (ISTs)'],
      ),
      InstituicaoModel(
        chipTitle: 'Assistência',
        chipIcon: Icons.psychology_rounded,
        cardTitle: 'Assédio',
        bioTitle: 'Coord. de Serviço Social (CSSOCIAL)',
        bioDesc: 'Responsável pelas políticas de assistência estudantil, garantindo a permanência e o êxito dos alunos. Atua fortemente no acolhimento de vítimas de assédio ou em situação de vulnerabilidade.',
        bioContact: 'E-mail: ssocial.fortaleza@ifce.edu.br\nTel: (85) 3307-3604 / 3455-3093',
        atuacao: ['Acolhimento humanizado', 'Auxílios estudantis (SisAE)', 'Orientação socioeconômica'],
      ),
      InstituicaoModel(
        chipTitle: 'NEABI',
        chipIcon: Icons.diversity_3_rounded,
        cardTitle: 'Racismo',
        bioTitle: 'Núcleo de Estudos Afro-brasileiros e Indígenas',
        bioDesc: 'Missão de sistematizar, produzir e difundir conhecimentos que contribuam para a equidade racial, promoção dos Direitos Humanos e combate frontal ao racismo e discriminação.',
        bioContact: 'Local: Sala do NEABI - Campus Fortaleza\nE-mail: proext@ifce.edu.br\nTel: (85) 3401-2346',
        atuacao: ['Combate ao racismo', 'Apoio a estudantes cotistas', 'Debate étnico-racial e cultural'],
      ),
      InstituicaoModel(
        chipTitle: 'NAPNE',
        chipIcon: Icons.accessible_forward_rounded,
        cardTitle: 'Homofobia', // Adaptável conforme sua lógica de denúncia
        bioTitle: 'Núcleo de Acessibilidade (NAPNE)',
        bioDesc: 'Objetiva criar uma cultura de educação para a convivência, quebrando barreiras arquitetônicas, comunicacionais e atitudinais (preconceitos) para estudantes com necessidades específicas.',
        bioContact: 'Coord.: João César Abreu\nE-mail: napne.fortaleza@ifce.edu.br\nTel: (85) 3455-3070',
        atuacao: ['Apoio psicopedagógico', 'Tutoria de pares (alunos apoiando alunos)', 'Adaptação de materiais'],
      ),
    ];
  }
}