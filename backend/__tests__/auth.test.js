const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../../src/app');

describe('Auth Routes', () => {
  const testUser = {
    name: 'Test User',
    email: `test_${Date.now()}@countit.test`,
    password: 'haslo123',
  };
  let token;

  afterAll(async () => {
    await mongoose.connection.close();
  });

  describe('POST /auth/register', () => {
    it('powinno zarejestrować nowego użytkownika', async () => {
      const res = await request(app).post('/auth/register').send(testUser);
      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.token).toBeDefined();
      expect(res.body.user.email).toBe(testUser.email);
      expect(res.body.user.passwordHash).toBeUndefined();
      token = res.body.token;
    });

    it('powinno odrzucić duplikat email', async () => {
      const res = await request(app).post('/auth/register').send(testUser);
      expect(res.statusCode).toBe(409);
    });

    it('powinno odrzucić brakujące pola', async () => {
      const res = await request(app).post('/auth/register').send({ email: 'brak@test.com' });
      expect(res.statusCode).toBe(400);
    });

    it('powinno odrzucić krótkie hasło', async () => {
      const res = await request(app).post('/auth/register').send({
        name: 'Test',
        email: 'short@test.com',
        password: '123',
      });
      expect(res.statusCode).toBe(400);
    });
  });

  describe('POST /auth/login', () => {
    it('powinno zalogować z poprawnymi danymi', async () => {
      const res = await request(app).post('/auth/login').send({
        email: testUser.email,
        password: testUser.password,
      });
      expect(res.statusCode).toBe(200);
      expect(res.body.token).toBeDefined();
      token = res.body.token;
    });

    it('powinno odrzucić błędne hasło', async () => {
      const res = await request(app).post('/auth/login').send({
        email: testUser.email,
        password: 'bledne_haslo',
      });
      expect(res.statusCode).toBe(401);
    });
  });

  describe('GET /auth/me', () => {
    it('powinno zwrócić zalogowanego użytkownika', async () => {
      const res = await request(app)
        .get('/auth/me')
        .set('Authorization', `Bearer ${token}`);
      expect(res.statusCode).toBe(200);
      expect(res.body.user.email).toBe(testUser.email);
    });

    it('powinno odrzucić brak tokenu', async () => {
      const res = await request(app).get('/auth/me');
      expect(res.statusCode).toBe(401);
    });
  });
});
