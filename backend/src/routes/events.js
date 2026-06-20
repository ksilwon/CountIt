const express = require('express');
const Event = require('../models/Event');
const Settlement = require('../models/Settlement');
const { protect } = require('../middleware/auth');

const router = express.Router();

// POST /events — utwórz wydarzenie i auto-split rozliczeń
router.post('/', protect, async (req, res) => {
  try {
    const { title, amount, category, date, participants, locationName, latitude, longitude } = req.body;

    if (!title || !amount) {
      return res.status(400).json({ success: false, message: 'Nazwa i kwota są wymagane' });
    }
    if (!participants || participants.length === 0) {
      return res.status(400).json({ success: false, message: 'Dodaj przynajmniej jednego uczestnika' });
    }

    const event = await Event.create({
      title,
      amount,
      category: category || 'inne',
      date: date || new Date(),
      createdBy: req.user._id,
      participants,
      locationName: locationName || 'Warszawa',
      latitude: latitude ?? 52.2297,
      longitude: longitude ?? 21.0122,
    });

    // Utwórz rozliczenia dla każdego uczestnika
    const settlementDocs = participants.map((participantId) => ({
      event: event._id,
      participant: participantId,
      payer: req.user._id,
      amount: event.splitAmount,
      status: 'PENDING',
    }));
    await Settlement.insertMany(settlementDocs);

    await event.populate('createdBy', 'name email avatarUrl');
    await event.populate('participants', 'name email avatarUrl');

    res.status(201).json({ success: true, event });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /events — historia wydarzeń (jako uczestnik lub płacący)
router.get('/', protect, async (req, res) => {
  try {
    const { category } = req.query;
    const filter = {
      $or: [{ createdBy: req.user._id }, { participants: req.user._id }],
    };
    if (category) filter.category = category;

    const events = await Event.find(filter)
      .populate('createdBy', 'name email avatarUrl')
      .populate('participants', 'name email avatarUrl')
      .sort({ date: -1 })
      .lean();

    const eventIds = events.map((e) => e._id);
    const settlements = await Settlement.find({ event: { $in: eventIds } });

    const enrichedEvents = events.map((event) => {
      const eventSettlements = settlements.filter(s => s.event.toString() === event._id.toString());
      let isSettled = false;
      const isCreator = event.createdBy._id.toString() === req.user._id.toString();
      
      if (isCreator) {
        // Płacący uważa event za rozliczony, gdy WSZYSTKIE rozliczenia są CONFIRMED (lub brak rozliczeń - sam ze sobą)
        isSettled = eventSettlements.length > 0 && eventSettlements.every(s => s.status === 'CONFIRMED');
      } else {
        // Uczestnik uważa event za rozliczony, gdy JEGO rozliczenie jest CONFIRMED
        const mySettlement = eventSettlements.find(s => s.participant.toString() === req.user._id.toString());
        isSettled = mySettlement ? mySettlement.status === 'CONFIRMED' : false;
      }
      
      return { ...event, isSettled };
    });

    res.json({ success: true, events: enrichedEvents });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /events/:id — szczegóły wydarzenia z rozliczeniami
router.get('/:id', protect, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id)
      .populate('createdBy', 'name email avatarUrl')
      .populate('participants', 'name email avatarUrl');

    if (!event) {
      return res.status(404).json({ success: false, message: 'Wydarzenie nie istnieje' });
    }

    const isInvolved =
      event.createdBy._id.toString() === req.user._id.toString() ||
      event.participants.some((p) => p._id.toString() === req.user._id.toString());

    if (!isInvolved) {
      return res.status(403).json({ success: false, message: 'Brak dostępu do tego wydarzenia' });
    }

    const settlements = await Settlement.find({ event: req.params.id })
      .populate('participant', 'name email avatarUrl')
      .populate('payer', 'name email avatarUrl');

    res.json({ success: true, event, settlements });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
