require('dotenv').config();
const { MongoClient } = require('mongodb');

const MONGO = process.env.MONGODB_URI;
if (!MONGO) {
  console.error('MONGODB_URI is not set');
  process.exit(1);
}

async function main() {
  const client = new MongoClient(MONGO);
  const DB_NAME = 'segurese_db';
  try {
    await client.connect();
    const db = client.db(DB_NAME);
    const collection = db.collection('denuncias');

    const cursor = collection.find({ fotos: { $exists: true, $ne: [] } });
    let total = 0;
    while (await cursor.hasNext()) {
      const doc = await cursor.next();
      const fotos = Array.isArray(doc.fotos) ? doc.fotos : [];
      const nonHttp = fotos.filter(f => typeof f === 'string' && !f.startsWith('http'));
      if (nonHttp.length > 0) {
        total++;
        console.log('DOC_ID:', doc._id.toString());
        console.log('  non-http fotos:', nonHttp);
      }
    }
    console.log('Total documents with non-http fotos:', total);
  } catch (err) {
    console.error('Error:', err.message);
  } finally {
    await client.close();
  }
}

main();
