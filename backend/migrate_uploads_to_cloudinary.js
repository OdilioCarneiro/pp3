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

async function main() {
  try {
    await client.connect();
    const db = client.db();
    const collection = db.collection('denuncias');

    const cursor = collection.find({ fotos: { $exists: true, $ne: [] } });
    console.log('Scanning documents for non-http fotos...');

    while (await cursor.hasNext()) {
      const doc = await cursor.next();
      const fotos = Array.isArray(doc.fotos) ? doc.fotos : [];
      let updated = false;

      for (let i = 0; i < fotos.length; i++) {
        const foto = fotos[i];
        if (typeof foto === 'string' && !foto.startsWith('http')) {
          // try find file in uploads by basename
          const base = path.basename(foto);
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
            console.log(`Local file not found for foto '${foto}', skipping.`);
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
