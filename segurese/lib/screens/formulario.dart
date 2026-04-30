import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
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
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  
  final List<String> _caminhosDasFotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _estaEnviando = false;

  // CORES DEFINIDAS AQUI PARA NÃO DAR ERRO NOS MÉTODOS ABAIXO
  final Color _verdeEscuro = const Color(0xFF133626);
  final Color _verdeMedio = const Color(0xFF2B5C45);

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

  // Lógica para enviar para a sua API
  Future<void> _enviarDenuncia() async {
    setState(() => _estaEnviando = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:3000/submit-form'), // Ajuste para o IP do seu servidor
      );

      request.fields['categoria'] = widget.categoria;
      request.fields['local'] = _nomeController.text;
      request.fields['descricao'] = _descricaoController.text;
      request.fields['emailDestino'] = widget.emailDestino;

      for (String p in _caminhosDasFotos) {
        request.files.add(await http.MultipartFile.fromPath('attachments', p, filename: path.basename(p)));
      }

      var response = await request.send();

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enviado com sucesso!')));
          Navigator.pop(context);
        } else {
          throw Exception('Erro no servidor');
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _estaEnviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _verdeEscuro),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Relatar\nOcorrência', 
              style: TextStyle(color: _verdeEscuro, fontSize: 34, fontWeight: FontWeight.bold, height: 1.1)),
            const SizedBox(height: 30),
            
            _buildGlassContainer(
              child: _buildCleanTextField(
                controller: _descricaoController, 
                hint: 'Descreva os detalhes aqui...', 
                maxLines: 5
              ),
            ),
            
            const SizedBox(height: 20),
            if (_caminhosDasFotos.isNotEmpty) _buildPhotoGallery(),
            
            Row(
              children: [
                Expanded(child: _buildPhotoAction(Icons.camera_alt, 'Câmera', _tirarFoto)),
                const SizedBox(width: 12),
                Expanded(child: _buildPhotoAction(Icons.photo_library, 'Galeria', _selecionarDaGaleria)),
              ],
            ),
            
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // MÉTODOS DE AUXÍLIO (Agora com acesso às cores da classe)
  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: child,
    );
  }

  Widget _buildCleanTextField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildPhotoAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _verdeEscuro.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: _verdeMedio),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: _verdeEscuro, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Container(
      height: 100,
      margin: const EdgeInsets.bottom(16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _caminhosDasFotos.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(_caminhosDasFotos[index]), width: 100, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _verdeMedio,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: _estaEnviando ? null : _enviarDenuncia,
        child: _estaEnviando 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('ENVIAR DENÚNCIA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}