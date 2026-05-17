require('dotenv').config();
const express = require('express');
const { MongoClient, ObjectId } = require('mongodb');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const sgMail = require('@sendgrid/mail');

// 1. Importando o MongoClient nativo
const { MongoClient } = require('mongodb');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// --- CONEXÃO DIRETA COM O MONGODB ---
const client = new MongoClient(process.env.MONGODB_URI);
let db;

async function conectarBanco() {
  try {
    await client.connect();
    // Você pode escolher o nome do seu banco de dados aqui (ex: segurese_db)
    db = client.db('segurese_db'); 
    console.log('✅ Conectado ao MongoDB (Driver Nativo) com sucesso!');
  } catch (error) {
    console.error('❌ Erro ao conectar no MongoDB:', error);
  }
}
conectarBanco(); // Inicia a conexão quando o servidor liga

// Configuração do Multer (Upload de arquivos)
const storage = multer.diskStorage({
  destination: (req, file, cb) => { cb(null, 'uploads/'); },
  filename: (req, file, cb) => { cb(null, Date.now() + path.extname(file.originalname)); }
});
const upload = multer({ storage: storage });

if (!fs.existsSync('uploads')) { fs.mkdirSync('uploads'); }

// CONFIGURAÇÃO DO SENDGRID
sgMail.setApiKey(process.env.SENDGRID_API_KEY);
const fromEmail = 'ppprojeto3@gmail.com'; 

const departmentEmails = {
  'Perigos': 'yslenlaragb@gmail.com',
  'Acidentes': 'saude@ifce.com',
  'Assédio': 'recursos_humanos@ifce.com',
  'Racismo': 'diversidade@ifce.com',
  'Homofobia': 'odiliocarneiro@gmail.com',
};

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Segurese Backend rodando com SendGrid e MongoDB Nativo' });
});

// --- ROTA 1: RECEBER DO APP, ENVIAR E-MAIL E SALVAR NO BANCO ---
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

  const msg = {
    to: recipientEmail,
    from: fromEmail,
    subject: `Denúncia - ${categoria}`,
    text: emailBody,
    attachments: emailAttachments,
  };

  try {
    // 1. Envia o e-mail via SendGrid
    await sgMail.send(msg);
    console.log('E-mail enviado com sucesso via API!');

    // 2. Salva no MongoDB direto na coleção 'denuncias' usando insertOne
    if (db) {
      const novaDenuncia = {
        dispositivoId: dispositivoId || 'ID_NAO_FORNECIDO',
        categoria,
        local,
        data,
        hora,
        descricao,
        status: 'Pendente',
        dataCriacao: new Date() // Adiciona a data atual automaticamente
      };
      
      await db.collection('denuncias').insertOne(novaDenuncia);
      console.log('Denúncia salva no MongoDB com sucesso!');
    } else {
      console.warn('Aviso: Banco de dados não conectado. E-mail enviado, mas denúncia não foi salva.');
    }

    res.json({ success: true, message: 'Denúncia enviada e salva com sucesso' });
  } catch (error) {
    console.error('Erro no processo:', error);
    res.status(500).json({ success: false, message: 'Erro ao processar denúncia', detail: error.message });
  }
});

// --- ROTA 2: BUSCAR HISTÓRICO PARA O APP FLUTTER ---
app.get('/minhas-denuncias/:dispositivoId', async (req, res) => {
  try {
    const { dispositivoId } = req.params;
    
    if (!db) {
      return res.status(500).json({ success: false, message: 'Banco de dados indisponível no momento.' });
    }

    // Busca na coleção 'denuncias', filtra pelo ID do celular, ordena pela data (-1 = mais recente) e transforma em Array
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
// ==========================================
// ROTAS DE ADMINISTRADOR
// ==========================================

// 1. Rota de Login Admin
// O Flutter vai enviar a categoria e a senha digitada. O servidor confere se bate.
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

    // Se a categoria existe no dicionário e a senha digitada for igual à senha correta
    if (senhaCorreta && senha === senhaCorreta) {
        res.status(200).json({ mensagem: 'Login aprovado!', categoria });
    } else {
        res.status(401).json({ erro: 'Senha incorreta ou categoria inválida.' });
    }
});

// 2. Rota para listar todas as denúncias de UMA categoria
app.get('/admin/denuncias/:categoria', async (req, res) => {
    try {
        const { categoria } = req.params;
        const collection = db.collection('denuncias'); // Substitua pelo nome da sua coleção se for diferente
        
        // Busca todas daquela categoria e ordena das mais novas para as mais antigas
        const denuncias = await collection.find({ categoria }).sort({ _id: -1 }).toArray();
        
        res.status(200).json(denuncias);
    } catch (erro) {
        console.error('Erro ao buscar denúncias por categoria:', erro);
        res.status(500).json({ erro: 'Erro interno ao buscar denúncias.' });
    }
});

// 3. Rota para ATUALIZAR o status de uma denúncia
app.patch('/admin/denuncias/:id/status', async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const collection = db.collection('denuncias');
        
        // O $set diz ao MongoDB para alterar APENAS o campo status e manter o resto intacto
        const resultado = await collection.updateOne(
            { _id: new ObjectId(id) }, 
            { $set: { status: status } }
        );

        if (resultado.modifiedCount === 1) {
            res.status(200).json({ mensagem: 'Status atualizado com sucesso!' });
        } else {
            // Se modifiedCount for 0, significa que não achou o ID ou o status já era o mesmo
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