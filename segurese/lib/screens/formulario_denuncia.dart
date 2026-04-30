import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; 
import 'package:path/path.dart' as path;

class FormularioDenuncia extends StatefulWidget {
  final String categoria;
  final String emailDestino;

  const FormularioDenuncia({
    super.key,
    required this.categoria,
    required this.emailDestino,
  });

  @override
  State<FormularioDenuncia> createState() => _FormularioDenunciaState();
}

class _FormularioDenunciaState extends State<FormularioDenuncia> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  late TextEditingController _nomeController; // Usado para Local
  late TextEditingController _dataController;
  late TextEditingController _horaController;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  final List<String> _caminhosDasFotos = [];
  final ImagePicker _picker = ImagePicker();

  // Cores da Identidade Visual
  final Color _verdeEscuro = const Color(0xFF133626);
  final Color _verdeMedio = const Color(0xFF2B5C45);

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
    if (foto != null) setState(() => _caminhosDasFotos.add(foto.path));
  }

  Future<void> _selecionarDaGaleria() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.gallery);
    if (foto != null) setState(() => _caminhosDasFotos.add(foto.path));
  }

  Future<void> _selecionarData() async {
    final DateTime now = DateTime.now();
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _verdeMedio, onPrimary: Colors.white, onSurface: _verdeEscuro),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _verdeMedio, onPrimary: Colors.white, onSurface: _verdeEscuro),
          ),
          child: child!,
        );
      },
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
    const Color begeColor = Color(0xFFF6F4E8);
    const Color brancoColor = Colors.white;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [begeColor, brancoColor],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: _verdeEscuro),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0, bottom: 40.0),
            children: [
              // Cabeçalho Premium
              Text(
                'Relatar\nOcorrência',
                style: TextStyle(
                  color: _verdeEscuro,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              
          
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _verdeMedio,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: _verdeMedio.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Text(
                    widget.categoria.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 36),

              // local e data
              _buildSectionTitle('Detalhes do Ocorrido'),
              const SizedBox(height: 12),
              _buildGlassContainer(
                child: Column(
                  children: [
                    _buildCleanTextField(
                      controller: _nomeController,
                      hint: 'Onde aconteceu? (Ex: Bloco A)',
                      icon: Icons.location_on_rounded,
                      validator: (val) => val!.isEmpty ? 'Necessário' : null,
                    ),
                    _buildDivider(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCleanTextField(
                            controller: _dataController,
                            hint: 'Data',
                            icon: Icons.calendar_today_rounded,
                            readOnly: true,
                            onTap: _selecionarData,
                            validator: (val) => val!.isEmpty ? 'Necessário' : null,
                          ),
                        ),
                        Container(width: 1, height: 30, color: _verdeEscuro.withValues(alpha: 0.1)),
                        Expanded(
                          child: _buildCleanTextField(
                            controller: _horaController,
                            hint: 'Hora',
                            icon: Icons.access_time_rounded,
                            readOnly: true,
                            onTap: _selecionarHora,
                            validator: (val) => val!.isEmpty ? 'Necessário' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // descrição
              _buildSectionTitle('O que aconteceu?'),
              const SizedBox(height: 12),
              _buildGlassContainer(
                child: _buildCleanTextField(
                  controller: _descricaoController,
                  hint: 'Descreva os detalhes da situação de forma clara e objetiva...',
                  maxLines: 5,
                  validator: (val) => val!.isEmpty ? 'A descrição é fundamental' : null,
                ),
              ),

              const SizedBox(height: 28),

              // evidências... chega de mentiras de negar os meus desejos
              _buildSectionTitle('Evidências (Opcional)'),
              const SizedBox(height: 12),
              _buildGlassContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_caminhosDasFotos.isNotEmpty) ...[
                        _buildPhotoGallery(),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(child: _buildPhotoAction(Icons.camera_alt_rounded, 'Câmera', _tirarFoto)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildPhotoAction(Icons.photo_library_rounded, 'Galeria', _selecionarDaGaleria)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // botão de envio
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _verdeMedio.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _verdeMedio,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) _enviarDenuncia();
                  },
                  child: const Text(
                    'Enviar Denúncia Anonimamente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: _verdeEscuro.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );
  }


  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4), 
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5), 
            ),
            child: child,
          ),
        ),
      ),
    );
  }


  Widget _buildCleanTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(color: _verdeEscuro, fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _verdeEscuro.withValues(alpha: 0.4), fontSize: 15),
          prefixIcon: icon != null ? Icon(icon, color: _verdeMedio.withValues(alpha: 0.7), size: 22) : null,
          border: InputBorder.none, // O segredo da limpeza visual
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          errorStyle: const TextStyle(height: 0.5),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: _verdeEscuro.withValues(alpha: 0.1),
    );
  }


  Widget _buildPhotoGallery() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _caminhosDasFotos.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: FileImage(File(_caminhosDasFotos[index])),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => setState(() => _caminhosDasFotos.removeAt(index)),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildPhotoAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _verdeEscuro.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: _verdeMedio, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: _verdeEscuro, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }


  void _enviarDenuncia() async {

    // Validar se o nome está preenchido
    if (_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha o local do ocorrido'),
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

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enviando denúncia...'),
        backgroundColor: Color(0xFF2B5C45),
      ),
    );

    try {
      // Prepare multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/submit-form'), // Change to your server URL
      );

      // Add form fields
      request.fields['categoria'] = widget.categoria;
      request.fields['local'] = _nomeController.text;
      request.fields['data'] = _dataController.text;
      request.fields['hora'] = _horaController.text;
      request.fields['descricao'] = _descricaoController.text;
      request.fields['emailDestino'] = widget.emailDestino;

      // Add attachments
      for (String photoPath in _caminhosDasFotos) {
        var file = await http.MultipartFile.fromPath(
          'attachments',
          photoPath,
          filename: path.basename(photoPath),
        );
        request.files.add(file);
      }

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Denúncia enviada com sucesso!'),
              backgroundColor: Color(0xFF2B5C45),
            ),
          );
          // Optionally, navigate back or clear form
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao enviar: $responseBody'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $error'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }
}