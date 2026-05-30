require('dotenv').config();
const express = require('express');
const { MongoClient, ObjectId } = require('mongodb');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const sgMail = require('@sendgrid/mail');
const cloudinary = require('cloudinary').v2;

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));


const client = new MongoClient(process.env.MONGODB_URI);
let db;

async function conectarBanco() {
  try {
    await client.connect();
    db = client.db('segurese_db'); 
    console.log('✅ Conectado ao MongoDB (Driver Nativo) com sucesso!');
  } catch (error) {
    console.error('❌ Erro ao conectar no MongoDB:', error);
  }
}
conectarBanco(); 


const storage = multer.diskStorage({
  destination: (req, file, cb) => { cb(null, 'uploads/'); },
  filename: (req, file, cb) => { cb(null, Date.now() + path.extname(file.originalname)); }
});
const upload = multer({ storage: storage });

if (!fs.existsSync('uploads')) { fs.mkdirSync('uploads'); }


sgMail.setApiKey(process.env.SENDGRID_API_KEY);

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

const fromEmail = 'ppprojeto3@gmail.com'; 

const departmentEmails = {
  'Perigos': 'yslenlaragb@gmail.com',
  'Acidentes': 'yslenlaragb@gmail.com',
  'Assédio': 'yslenlaragb@gmail.com',
  'Racismo': 'yslenlaragb@gmail.com',
  'Homofobia': 'odiliocarneiro@gmail.com',
};

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Segurese Backend rodando com SendGrid e MongoDB Nativo' });
});


app.post('/submit-form', upload.array('attachments'), async (req, res) => {
  const { dispositivoId, categoria, local, data, hora, descricao, emailDestino } = req.body;
  const attachments = req.files;

  const recipientEmail = emailDestino || departmentEmails[categoria] || 'default@departamento.com';

  let emailBody = `Formulário de Denúncia\n\nCATEGORIA: ${categoria}\n`;
  if (local) emailBody += `LOCAL: ${local}\n`;
  if (data) emailBody += `DATA: ${data}\n`;
  if (hora) emailBody += `HORA: ${hora}\n`;
  emailBody += `\nDESCRIÇÃO:\n${descricao}\n\n---\nEnviado via Segurese App`;

  const emailAttachments = attachments ? attachments.map(file => ({
    content: fs.readFileSync(file.path).toString('base64'),
    filename: file.originalname,
    type: file.mimetype,
    disposition: 'attachment'
  })) : [];

  
  let fotosUrls = [];

  if (attachments && attachments.length > 0) {
    if (process.env.CLOUDINARY_CLOUD_NAME && process.env.CLOUDINARY_API_KEY && process.env.CLOUDINARY_API_SECRET) {
      const uploadResults = await Promise.all(
        attachments.map(file =>
          cloudinary.uploader.upload(file.path, {
            folder: 'segurese_denuncias',
            resource_type: 'image',
          }),
        ),
      );

      fotosUrls = uploadResults.map(result => result.secure_url);

      attachments.forEach(file => {
        fs.unlink(file.path, err => {
          if (err) console.warn('Falha ao remover arquivo temporário:', err);
        });
      });
    } else {
      const baseUrl = `${req.protocol}://${req.get('host')}`;
      fotosUrls = attachments.map(file => `${baseUrl}/uploads/${file.filename}`);
    }
  }

  const msg = {
    to: recipientEmail,
    from: fromEmail,
    subject: `Denúncia - ${categoria}`,
    text: emailBody,
    attachments: emailAttachments,
  };

  try {

    await sgMail.send(msg);
    console.log('E-mail enviado com sucesso via API!');

    if (db) {
      const novaDenuncia = {
        dispositivoId: dispositivoId || 'ID_NAO_FORNECIDO',
        categoria,
        local,
        data,
        hora,
        descricao,
        status: 'Pendente',
        fotos: fotosUrls, 
        dataCriacao: new Date() 
      };
      
      await db.collection('denuncias').insertOne(novaDenuncia);
      console.log('Denúncia salva no MongoDB com os links das fotos!');
    } else {
      console.warn('Aviso: Banco de dados não conectado. E-mail enviado, mas denúncia não foi salva.');
    }

    res.json({ success: true, message: 'Denúncia enviada e salva com sucesso' });
  } catch (error) {
    console.error('Erro no processo:', error);
    res.status(500).json({ success: false, message: 'Erro ao processar denúncia', detail: error.message });
  }
});

app.get('/minhas-denuncias/:dispositivoId', async (req, res) => {
  try {
    const { dispositivoId } = req.params;
    
    if (!db) {
      return res.status(500).json({ success: false, message: 'Banco de dados indisponível no momento.' });
    }

    const denuncias = await db.collection('denuncias')
      .find({ dispositivoId: dispositivoId })
      .sort({ dataCriacao: -1 })
      .toArray();
    
    res.status(200).json(denuncias);
  } catch (error) {
    console.error('Erro ao buscar denúncias:', error);
    res.status(500).json({ success: false, message: 'Erro ao buscar histórico' });
  }
});

app.post('/admin/login', (req, res) => {
    const { categoria, senha } = req.body;

    const senhasPorCategoria = {
        'Assédio': 'assedio123',
        'Preconceito': 'preconceito123',
        'Racismo': 'racismo123',
        'Perigos': 'perigos123',
        'Acidentes': 'acidentes123'
    };

    const senhaCorreta = senhasPorCategoria[categoria];

    if (senhaCorreta && senha === senhaCorreta) {
        res.status(200).json({ mensagem: 'Login aprovado!', categoria });
    } else {
        res.status(401).json({ erro: 'Senha incorreta ou categoria inválida.' });
    }
});

app.get('/admin/denuncias/:categoria', async (req, res) => {
    try {
        const { categoria } = req.params;
        const collection = db.collection('denuncias'); 
        
        const denuncias = await collection.find({ categoria }).sort({ _id: -1 }).toArray();
        
        res.status(200).json(denuncias);
    } catch (erro) {
        console.error('Erro ao buscar denúncias por categoria:', erro);
        res.status(500).json({ erro: 'Erro interno ao buscar denúncias.' });
    }
});

app.patch('/admin/denuncias/:id/status', async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const collection = db.collection('denuncias');
        
        const resultado = await collection.updateOne(
            { _id: new ObjectId(id) }, 
            { $set: { status: status } }
        );

        if (resultado.modifiedCount === 1) {
            res.status(200).json({ mensagem: 'Status updated successfully!' });
        } else {
            res.status(404).json({ erro: 'Denúncia não encontrada ou status não alterado.' });
        }
    } catch (erro) {
        console.error('Erro ao atualizar status:', erro);
        res.status(500).json({ erro: 'Erro interno ao atualizar status.' });
    }
});

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});