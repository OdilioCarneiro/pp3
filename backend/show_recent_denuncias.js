require('dotenv').config();
const { MongoClient } = require('mongodb');

const MONGO = process.env.MONGODB_URI;
if (!MONGO) {
  console.error('MONGODB_URI not set');
  process.exit(1);
}

async function main() {
  const client = new MongoClient(MONGO);
  try {
    await client.connect();
    const db = client.db('segurese_db');
    const collection = db.collection('denuncias');

    const total = await collection.countDocuments();
    console.log('Total documents in collection:', total);
    const docs = await collection.find().sort({ dataCriacao: -1 }).limit(10).toArray();
    if (docs.length === 0) {
      console.log('No documents found.');
    }
    docs.forEach(d => {
      console.log('ID:', d._id.toString());
      console.log('  dispositivoId:', d.dispositivoId);
      console.log('  categoria:', d.categoria);
      console.log('  fotos:', d.fotos);
      console.log('  ----------');
    });
  } catch (err) {
    console.error('Error:', err.message);
  } finally {
    await client.close();
  }
}

main();
