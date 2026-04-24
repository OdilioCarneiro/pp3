import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

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
  final List<String> _caminhosDasFotos = [];
  final ImagePicker _picker = ImagePicker();

  // Cores da Identidade Visual
  final Color _verdeEscuro = const Color(0xFF133626);
  final Color _verdeMedio = const Color(0xFF2B5C45);

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _tirarFoto() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      setState(() => _caminhosDasFotos.add(foto.path));
    }
  }


  Future<void> _selecionarDaGaleria() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.gallery);
    if (foto != null) {
      setState(() => _caminhosDasFotos.add(foto.path));
    }
  }

  Future<void> _enviarEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final Email email = Email(
      body: 'Denúncia de ${widget.categoria}\n\nDescrição do Ocorrido:\n${_descricaoController.text}\n\n---\nEnviado via App IFCE',
      subject: 'DENÚNCIA: ${widget.categoria} - App IFCE',
      recipients: [widget.emailDestino],
      attachmentPaths: _caminhosDasFotos,
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Preparando email para envio...'),
            backgroundColor: _verdeMedio,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao abrir o email.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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

              Text(
                'Relatar\n${widget.categoria}',
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
                    color: _verdeMedio.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _verdeMedio.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mail_outline_rounded, color: _verdeMedio, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Destino: ${widget.emailDestino}',
                        style: TextStyle(
                          color: _verdeMedio,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 36),


              _buildSectionTitle('O que aconteceu?'),
              const SizedBox(height: 12),
              _buildGlassContainer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: TextFormField(
                    controller: _descricaoController,
                    maxLines: 6,
                    style: TextStyle(color: _verdeEscuro, fontSize: 16, fontWeight: FontWeight.w500),
                    validator: (val) => val == null || val.isEmpty ? 'A descrição é fundamental' : null,
                    decoration: InputDecoration(
                      hintText: 'Descreva os detalhes da situação de forma clara e objetiva...',
                      hintStyle: TextStyle(color: _verdeEscuro.withValues(alpha: 0.4), fontSize: 15),
                      border: InputBorder.none, // Retiramos as bordas antigas
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

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
                          Expanded(
                            child: _buildPhotoAction(
                              icon: Icons.camera_alt_rounded,
                              label: 'Câmera',
                              onTap: _tirarFoto,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPhotoAction(
                              icon: Icons.photo_library_rounded,
                              label: 'Galeria',
                              onTap: _selecionarDaGaleria,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),


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
                  onPressed: _enviarEmail,
                  child: const Text(
                    'ENVIAR DENÚNCIA',
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


  Widget _buildPhotoAction({required IconData icon, required String label, required VoidCallback onTap}) {
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
}