# Guia de Deploy no Render

## 📋 Pré-requisitos
1. Conta no GitHub com o código (ou criar uma)
2. Conta no [Render.com](https://render.com)
3. Credenciais do Gmail (email e senha de app)

## 🚀 Passo a Passo

### 1. Preparar o GitHub
```bash
git init
git add .
git commit -m "Preparar para deploy no Render"
git branch -M main
git remote add origin https://github.com/seu-usuario/seu-repositorio.git
git push -u origin main
```

### 2. Conectar no Render
1. Acesse https://render.com e faça login
2. Clique em **New +** → **Web Service**
3. Selecione **Connect a repository**
4. Autorize o Render a acessar seu GitHub
5. Escolha o repositório e faça login

### 3. Configurar o Serviço
- **Name**: `segurese-backend` (ou outro nome que quiser)
- **Root Directory**: `backend` ⚠️ IMPORTANTE!
- **Build Command**: `npm install`
- **Start Command**: `npm start`
- **Runtime**: Node
- **Plan**: Free (para começar)

### 4. Variáveis de Ambiente ⚠️ IMPORTANTE
Na seção "Environment", adicione:
- `EMAIL_USER`: seu-email@gmail.com
- `EMAIL_PASS`: sua-senha-de-app-google (NÃO é sua senha normal!)
- `NODE_ENV`: production

> **Como gerar senha de app Google:**
> 1. Acesse: https://myaccount.google.com/security
> 2. Ative "Verificação em duas etapas"
> 3. Vá em "Senhas de app"
> 4. Gere uma senha para "Correio" e "Windows"
> 5. Use essa senha no Render

### 5. Deploy
1. Clique em **Create Web Service**
2. Aguarde o deploy (pode levar 2-5 minutos)
3. Copie a URL gerada (exemplo: `https://segurese-backend.onrender.com`)

## 📱 Atualizar a URL no App Flutter

Depois que o deploy terminar, atualize a URL no seu app Flutter:

**Arquivo**: `lib/screens/formulario_denuncia.dart`

Substitua:
```dart
'http://localhost:3000/...
```

Por:
```dart
'https://segurese-backend.onrender.com/...
```

## ✅ Testar
Faça uma requisição para `https://segurese-backend.onrender.com/health` no Postman ou navegador.

## 📝 Notas Importantes
- O servidor pode dormir após 15 minutos de inatividade (plano free)
- Primeira requisição pode demorar um pouco para acordar
- Considere upgrade para plano pago se tiver muito tráfego
- Logs disponíveis em: Render Dashboard → Seu Serviço → Logs
