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
    required this.emailDestino
  });

  @override
  State<FormularioDenuncia> createState() => _FormularioDenunciaState();
}

class _FormularioDenunciaState extends State<FormularioDenuncia> {
  final TextEditingController _descricaoController = TextEditingController();
  final List<String> _caminhosDasFotos = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _tirarFoto() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      setState(() => _caminhosDasFotos.add(foto.path));
    }
  }

  Future<void> _enviarEmail() async {
    final Email email = Email(
      body: 'Denúncia de ${widget.categoria}\n\nDescrição: ${_descricaoController.text}',
      subject: 'DENÚNCIA: ${widget.categoria} - App IFCE',
      recipients: [widget.emailDestino],
      attachmentPaths: _caminhosDasFotos,
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Relatar ${widget.categoria}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Destinatário: ${widget.emailDestino}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _descricaoController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Descreva os detalhes aqui...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _tirarFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Tirar Foto"),
            ),
            const SizedBox(height: 10),
            // Mostra as fotos tiradas
            Wrap(
              spacing: 10,
              children: _caminhosDasFotos.map((path) => Image.file(File(path), width: 70, height: 70, fit: BoxFit.cover)).toList(),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _enviarEmail,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("ENVIAR DENÚNCIA"),
            ),
          ],
        ),
      ),
    );
  }
}