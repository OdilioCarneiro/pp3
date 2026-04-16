import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FormularioDenuncia extends StatefulWidget {
  final String categoria;
  final String emailDestino;

  const FormularioDenuncia({
    Key? key,
    required this.categoria,
    required this.emailDestino,
  }) : super(key: key);

  @override
  State<FormularioDenuncia> createState() => _FormularioDenunciaState();
}

class _FormularioDenunciaState extends State<FormularioDenuncia> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  late TextEditingController _nomeController;
  late TextEditingController _dataController;
  late TextEditingController _horaController;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  final List<String> _caminhosDasFotos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController();
    _nomeController = TextEditingController();
    _dataController = TextEditingController();
    _horaController = TextEditingController();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _nomeController.dispose();
    _dataController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  Future<void> _tirarFoto() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      setState(() {
        _caminhosDasFotos.add(foto.path);
      });
    }
  }

  Future<void> _selecionarDaGaleria() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.gallery);
    if (foto != null) {
      setState(() {
        _caminhosDasFotos.add(foto.path);
      });
    }
  }

  Future<void> _selecionarData() async {
    final DateTime now = DateTime.now();
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
        _dataController.text = '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
      });
    }
  }

  Future<void> _selecionarHora() async {
    final TimeOfDay initialTime = _horaSelecionada ?? TimeOfDay.now();
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (hora != null) {
      setState(() {
        _horaSelecionada = hora;
        _horaController.text = hora.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Denúncia - ${widget.categoria}'),
        backgroundColor: const Color(0xFF2B5C45),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              
              // Categoria (apenas leitura)
              TextFormField(
                initialValue: widget.categoria,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Seção de Foto com Carrosel
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_caminhosDasFotos.isNotEmpty)
                      Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _caminhosDasFotos.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(_caminhosDasFotos[index]),
                                          height: 200,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _caminhosDasFotos.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_caminhosDasFotos.length} foto(s) selecionada(s)',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Nenhuma foto selecionada',
                        style: TextStyle(color: Colors.grey),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B5C45),
                          ),
                          onPressed: _tirarFoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Câmera'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B5C45),
                          ),
                          onPressed: _selecionarDaGaleria,
                          icon: const Icon(Icons.image),
                          label: const Text('Galeria'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Local do ocorrido
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Local do ocorrido',
                  hintText: 'Digite o local do ocorrido',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o local do ocorrido';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),

              // Data do ocorrido
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Data do ocorrido',
                  hintText: 'Selecione a data',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onTap: _selecionarData,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a data';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),

              // Hora do ocorrido
              TextFormField(
                controller: _horaController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Hora do ocorrido',
                  hintText: 'Selecione a hora',
                  suffixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onTap: _selecionarHora,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a hora';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Descrição da denúncia
              TextFormField(
                controller: _descricaoController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Descrição da denúncia',
                  hintText: 'Descreva o ocorrido com detalhes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Botão de enviar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B5C45),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Aqui você pode enviar a denúncia
                    _enviarDenuncia();
                  }
                },
                child: const Text(
                  'Enviar Denúncia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _enviarDenuncia() async {
    // Validar se o nome está preenchido
    if (_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha seu nome'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar se a descrição está preenchida
    if (_descricaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha a descrição'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Email email = Email(
      body: 'Formulário de Denúncia\n\nCATEGORIA: ${widget.categoria}\nLOCAL: ${_nomeController.text}\nDATA: ${_dataController.text}\nHORA: ${_horaController.text}\n\nDESCRIÇÃO:\n${_descricaoController.text}\n\n---\nEnviado via Segurese App',
      subject: 'Denúncia - ${widget.categoria}',
      recipients: ['larayslengb@gmail.com'],
      attachmentPaths: _caminhosDasFotos,
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email aberto para envio!'),
            backgroundColor: Color(0xFF2B5C45),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
