const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

const connectDB = async () => {
  try {
    let uri = process.env.MONGODB_URI;
    try {
      // Spróbuj połączyć z bazą z pliku .env (np. lokalnie lub chmura)
      const conn = await mongoose.connect(uri);
      console.log(`✅ MongoDB connected: ${conn.connection.host}`);
    } catch (e) {
      // W razie błędu odpalamy bazę w pamięci
      console.log(`⚠️ Brak lokalnej bazy na porcie 27017, pobieram bazę w pamięci RAM...`);
      const mongoServer = await MongoMemoryServer.create();
      uri = mongoServer.getUri();
      const conn = await mongoose.connect(uri);
      console.log(`✅ MongoDB Memory Server connected: ${uri}`);
    }
  } catch (error) {
    console.error('❌ MongoDB connection error:', error.message);
    process.exit(1);
  }
};

module.exports = connectDB;
