require('dotenv').config();
const express = require('express');
const multer = require('multer');
const nodemailer = require('nodemailer');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

const fs = require('fs');
if (!fs.existsSync('uploads')) {
  fs.mkdirSync('uploads');
}

const emailUser = process.env.EMAIL_USER || 'ppprojeto3@gmail.com';
const emailPass = process.env.EMAIL_PASS || 'khxfsmyesrjbobvr';

if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
  console.warn('WARNING: EMAIL_USER and/or EMAIL_PASS are not set. Set them as environment variables for production.');
}

const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 587,
  secure: false,
  auth: {
    user: emailUser,
    pass: emailPass
  }
});

transporter.verify((error, success) => {
  if (error) {
    console.error('Transporter verification failed:', error);
  } else {
    console.log('Email transporter ready to send messages');
  }
});

// Department email mapping
const departmentEmails = {
  'Perigos': 'yslennlaragb@gmail.com',
  'Acidentes': 'saude@ifce.com',
  'Assédio': 'recursos_humanos@ifce.com',
  'Racismo': 'diversidade@ifce.com',
  'Homofobia': 'odilio.carneiro63@aluno.ifce.edu.br',
  // Add more as needed
};

// Health check endpoint
app.get('/', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Segurese Backend API is running',
    endpoints: ['/submit-form (POST)']
  });
});

// API endpoint to submit form
app.post('/submit-form', upload.array('attachments'), (req, res) => {
  const { categoria, local, data, hora, descricao, emailDestino } = req.body;
  const attachments = req.files;

  // Determine recipient email
  const recipientEmail = emailDestino || departmentEmails[categoria] || 'default@departamento.com';

  // Prepare email content
  let emailBody = `Formulário de Denúncia\n\n`;
  emailBody += `CATEGORIA: ${categoria}\n`;
  if (local) emailBody += `LOCAL: ${local}\n`;
  if (data) emailBody += `DATA: ${data}\n`;
  if (hora) emailBody += `HORA: ${hora}\n`;
  emailBody += `\nDESCRIÇÃO:\n${descricao}\n\n`;
  emailBody += `---\nEnviado via Segurese App`;

  // Prepare attachments
  const emailAttachments = attachments ? attachments.map(file => ({
    filename: file.originalname,
    path: file.path
  })) : [];

  // Send email
  const mailOptions = {
    from: emailUser,
    to: recipientEmail,
    subject: `Denúncia - ${categoria}`,
    text: emailBody,
    attachments: emailAttachments
  };

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.error('Error sending email:', error);
      return res.status(500).json({
        success: false,
        message: 'Erro ao enviar email',
        detail: error.message
      });
    }
    console.log('Email sent:', info.response);
    res.json({ success: true, message: 'Denúncia enviada com sucesso' });
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});