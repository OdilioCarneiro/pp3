require('dotenv').config();
const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
// TROCA AQUI: Sai Nodemailer, entra SendGrid Mail
const sgMail = require('@sendgrid/mail');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Configuração do Multer (Upload de arquivos)
const storage = multer.diskStorage({
  destination: (req, file, cb) => { cb(null, 'uploads/'); },
  filename: (req, file, cb) => { cb(null, Date.now() + path.extname(file.originalname)); }
});
const upload = multer({ storage: storage });

if (!fs.existsSync('uploads')) { fs.mkdirSync('uploads'); }

// CONFIGURAÇÃO DO SENDGRID
sgMail.setApiKey(process.env.SENDGRID_API_KEY);
const fromEmail = 'ppprojeto3@gmail.com'; // O e-mail que você verificou agora!

const departmentEmails = {
  'Perigos': 'yslennlaragb@gmail.com',
  'Acidentes': 'saude@ifce.com',
  'Assédio': 'recursos_humanos@ifce.com',
  'Racismo': 'diversidade@ifce.com',
  'Homofobia': 'odilio.carneiro63@aluno.ifce.edu.br',
};

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Segurese Backend rodando via SendGrid API' });
});

app.post('/submit-form', upload.array('attachments'), async (req, res) => {
  const { categoria, local, data, hora, descricao, emailDestino } = req.body;
  const attachments = req.files;

  // Define para qual e-mail vai (baseado no card clicado)
  const recipientEmail = emailDestino || departmentEmails[categoria] || 'default@departamento.com';

  let emailBody = `Formulário de Denúncia\n\nCATEGORIA: ${categoria}\n`;
  if (local) emailBody += `LOCAL: ${local}\n`;
  if (data) emailBody += `DATA: ${data}\n`;
  if (hora) emailBody += `HORA: ${hora}\n`;
  emailBody += `\nDESCRIÇÃO:\n${descricao}\n\n---\nEnviado via Segurese App`;

  // Prepara anexos para a API (Converte para Base64)
  const emailAttachments = attachments ? attachments.map(file => ({
    content: fs.readFileSync(file.path).toString('base64'),
    filename: file.originalname,
    type: file.mimetype,
    disposition: 'attachment'
  })) : [];

  const msg = {
    to: recipientEmail,     // O destino (depende do card)
    from: fromEmail,        // O seu e-mail verificado (ppprojeto3@gmail.com)
    subject: `Denúncia - ${categoria}`,
    text: emailBody,
    attachments: emailAttachments,
  };

  try {
    await sgMail.send(msg);
    console.log('E-mail enviado com sucesso via API!');
    res.json({ success: true, message: 'Denúncia enviada com sucesso' });
  } catch (error) {
    console.error('Erro no SendGrid:', error.response ? error.response.body : error);
    res.status(500).json({ success: false, message: 'Erro ao enviar email', detail: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});