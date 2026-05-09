const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../../src/app');

describe('Events Routes', () => {
  let token;
  let token2;
  let userId;
  let userId2;
  let eventId;

  beforeAll(async () => {
    // Rejestracja dwóch użytkowników
    const res1 = await request(app).post('/auth/register').send({
      name: 'Organizer',
      email: `org_${Date.now()}@countit.test`,
      password: 'haslo123',
    });
    token = res1.body.token;
    userId = res1.body.user._id;

    const res2 = await request(app).post('/auth/register').send({
      name: 'Participant',
      email: `part_${Date.now()}@countit.test`,
      password: 'haslo123',
    });
    token2 = res2.body.token;
    userId2 = res2.body.user._id;
  });

  afterAll(async () => {
    await mongoose.connection.close();
  });

  describe('POST /events', () => {
    it('powinno utworzyć wydarzenie i podzielić kwotę', async () => {
      const res = await request(app)
        .post('/events')
        .set('Authorization', `Bearer ${token}`)
        .send({
          title: 'Kolacja testowa',
          amount: 120,
          category: 'jedzenie',
          participants: [userId2],
        });

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.event.title).toBe('Kolacja testowa');
      // splitAmount = 120 / (1 uczestnik + 1 płacący) = 60
      expect(res.body.event.splitAmount).toBe(60);
      eventId = res.body.event._id;
    });

    it('powinno odrzucić brak uczestników', async () => {
      const res = await request(app)
        .post('/events')
        .set('Authorization', `Bearer ${token}`)
        .send({ title: 'Test', amount: 50, participants: [] });
      expect(res.statusCode).toBe(400);
    });
  });

  describe('GET /events', () => {
    it('powinno zwrócić historię wydarzeń', async () => {
      const res = await request(app)
        .get('/events')
        .set('Authorization', `Bearer ${token}`);
      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body.events)).toBe(true);
      expect(res.body.events.length).toBeGreaterThan(0);
    });
  });

  describe('GET /events/:id', () => {
    it('powinno zwrócić szczegóły z rozliczeniami', async () => {
      const res = await request(app)
        .get(`/events/${eventId}`)
        .set('Authorization', `Bearer ${token}`);
      expect(res.statusCode).toBe(200);
      expect(res.body.settlements).toBeDefined();
      expect(res.body.settlements.length).toBe(1);
      expect(res.body.settlements[0].status).toBe('PENDING');
    });
  });
});
