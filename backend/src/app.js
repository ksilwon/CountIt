require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

// Połącz z bazą danych
connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routery
app.use('/auth', require('./routes/auth'));
app.use('/users', require('./routes/users'));
app.use('/friends', require('./routes/friends'));
app.use('/events', require('./routes/events'));
app.use('/settlements', require('./routes/settlements'));
app.use('/dashboard', require('./routes/dashboard'));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

const path = require('path');

// Serwowanie plików statycznych dla zintegrowanego frontendu (Flutter Web)
app.use(express.static(path.join(__dirname, '../public')));

// 404 - Dla ścieżek API zwracamy błąd, dla reszty zwracamy index.html (obsługa routingu we Flutterze)
app.use((req, res, next) => {
  if (req.originalUrl.startsWith('/auth') || 
      req.originalUrl.startsWith('/users') || 
      req.originalUrl.startsWith('/friends') || 
      req.originalUrl.startsWith('/events') || 
      req.originalUrl.startsWith('/settlements') || 
      req.originalUrl.startsWith('/dashboard')) {
    return res.status(404).json({ success: false, message: 'Endpoint nie istnieje' });
  }
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: 'Błąd serwera' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 CountIt API działa na porcie ${PORT}`);
});

module.exports = app;
