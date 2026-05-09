const express = require('express');
const Settlement = require('../models/Settlement');
const Event = require('../models/Event');
const { protect } = require('../middleware/auth');

const router = express.Router();

// GET /dashboard
router.get('/', protect, async (req, res) => {
  try {
    const userId = req.user._id;

    // Ile jestetem winien (moje nierozliczone jako uczestnik)
    const iOwe = await Settlement.aggregate([
      {
        $match: {
          participant: userId,
          status: { $in: ['PENDING', 'CLAIMED'] },
        },
      },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]);

    // Ile mi się należy (nierozliczone gdzie jestem płacącym)
    const owedToMe = await Settlement.aggregate([
      {
        $match: {
          payer: userId,
          status: { $in: ['PENDING', 'CLAIMED'] },
        },
      },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]);

    // Nadchodzące / ostatnie wydarzenia
    const recentEvents = await Event.find({
      $or: [{ createdBy: userId }, { participants: userId }],
    })
      .populate('createdBy', 'name avatarUrl')
      .sort({ createdAt: -1 })
      .limit(5);

    // Ostatnia aktywność (ostatnie rozliczenia)
    const recentActivity = await Settlement.find({
      $or: [{ participant: userId }, { payer: userId }],
    })
      .populate('event', 'title amount category')
      .populate('participant', 'name avatarUrl')
      .populate('payer', 'name avatarUrl')
      .sort({ updatedAt: -1 })
      .limit(10);

    res.json({
      success: true,
      balance: {
        iOwe: iOwe[0]?.total || 0,
        owedToMe: owedToMe[0]?.total || 0,
        net: (owedToMe[0]?.total || 0) - (iOwe[0]?.total || 0),
      },
      recentEvents,
      recentActivity,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
