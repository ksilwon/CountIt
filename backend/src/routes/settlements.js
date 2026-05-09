const express = require('express');
const Settlement = require('../models/Settlement');
const Event = require('../models/Event');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Helper: sprawdź dostęp do rozliczenia
const getSettlement = async (id) => Settlement.findById(id).populate('event');

// POST /settlements/:id/claim — uczestnik: "Oddałem"
router.post('/:id/claim', protect, async (req, res) => {
  try {
    const settlement = await getSettlement(req.params.id);
    if (!settlement) return res.status(404).json({ success: false, message: 'Rozliczenie nie istnieje' });

    if (settlement.participant.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Tylko uczestnik może oznaczyć wpłatę' });
    }
    if (settlement.status !== 'PENDING') {
      return res.status(400).json({ success: false, message: `Nie można zmienić statusu z ${settlement.status}` });
    }

    settlement.status = 'CLAIMED';
    settlement.claimedAt = new Date();
    await settlement.save();

    res.json({ success: true, settlement });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /settlements/:id/confirm — płacący: potwierdza otrzymanie
router.post('/:id/confirm', protect, async (req, res) => {
  try {
    const settlement = await getSettlement(req.params.id);
    if (!settlement) return res.status(404).json({ success: false, message: 'Rozliczenie nie istnieje' });

    if (settlement.payer.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Tylko płacący może potwierdzić wpłatę' });
    }
    if (settlement.status !== 'CLAIMED') {
      return res.status(400).json({ success: false, message: 'Rozliczenie nie jest w statusie CLAIMED' });
    }

    settlement.status = 'CONFIRMED';
    settlement.confirmedAt = new Date();
    await settlement.save();

    res.json({ success: true, settlement });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /settlements/:id/reject — płacący: odrzuca wpłatę (wraca do PENDING)
router.post('/:id/reject', protect, async (req, res) => {
  try {
    const settlement = await getSettlement(req.params.id);
    if (!settlement) return res.status(404).json({ success: false, message: 'Rozliczenie nie istnieje' });

    if (settlement.payer.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Tylko płacący może odrzucić wpłatę' });
    }
    if (settlement.status !== 'CLAIMED') {
      return res.status(400).json({ success: false, message: 'Rozliczenie nie jest w statusie CLAIMED' });
    }

    settlement.status = 'REJECTED';
    settlement.claimedAt = null;
    await settlement.save();

    // Automatycznie resetuj do PENDING po odrzuceniu
    settlement.status = 'PENDING';
    await settlement.save();

    res.json({ success: true, settlement });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /settlements/my — moje rozliczenia jako uczestnik
router.get('/my', protect, async (req, res) => {
  try {
    const settlements = await Settlement.find({ participant: req.user._id })
      .populate('event', 'title amount category date')
      .populate('payer', 'name email avatarUrl')
      .sort({ createdAt: -1 });

    res.json({ success: true, settlements });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
