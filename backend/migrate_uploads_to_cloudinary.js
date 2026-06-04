require('dotenv').config();
const { MongoClient } = require('mongodb');
const cloudinary = require('cloudinary').v2;
const fs = require('fs');
const path = require('path');

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

const MONGO = process.env.MONGODB_URI;
if (!MONGO) {
  console.error('MONGODB_URI is not set in environment');
  process.exit(1);
}

const client = new MongoClient(MONGO);
const DB_NAME = 'segurese_db';

async function main() {
  try {
    await client.connect();
    const db = client.db(DB_NAME);
    const collection = db.collection('denuncias');

    const cursor = collection.find({ fotos: { $exists: true, $ne: [] } });
    console.log('Scanning documents for fotos to migrate (non-http or local server URLs)...');

    while (await cursor.hasNext()) {
      const doc = await cursor.next();
      const fotos = Array.isArray(doc.fotos) ? doc.fotos : [];
      let updated = false;

      for (let i = 0; i < fotos.length; i++) {
        const foto = fotos[i];
        // Cases to migrate:
        // 1) relative/local path (doesn't start with http)
        // 2) local server URL containing '/uploads/' (e.g. http://localhost:3000/uploads/filename.png)
        let base = null;
        if (typeof foto === 'string') {
          if (!foto.startsWith('http')) {
            base = path.basename(foto);
          } else if (foto.includes('/uploads/')) {
            base = path.basename(foto);
          }
        }

        if (base) {
          const localPath = path.join(__dirname, 'uploads', base);
          if (fs.existsSync(localPath)) {
            console.log(`Uploading ${localPath} to Cloudinary...`);
            try {
              const res = await cloudinary.uploader.upload(localPath, { folder: 'segurese_denuncias' });
              fotos[i] = res.secure_url;
              updated = true;
              // optionally remove local file
              // fs.unlinkSync(localPath);
            } catch (err) {
              console.warn('Cloudinary upload failed for', localPath, err.message);
            }
          } else {
            console.log(`Local file not found for foto '${foto}', looked for ${localPath}, skipping.`);
          }
        }
      }

      if (updated) {
        await collection.updateOne({ _id: doc._id }, { $set: { fotos } });
        console.log(`Updated document ${doc._id} with Cloudinary URLs.`);
      }
    }

    console.log('Migration completed.');
  } catch (err) {
    console.error('Migration error:', err);
  } finally {
    await client.close();
    process.exit(0);
  }
}

main();
