const express = require('express');
const Friendship = require('../models/Friendship');
const { protect } = require('../middleware/auth');

const router = express.Router();

// POST /friends/request
router.post('/request', protect, async (req, res) => {
  try {
    const { userId } = req.body;
    if (!userId) return res.status(400).json({ success: false, message: 'userId jest wymagany' });
    if (userId === req.user._id.toString()) {
      return res.status(400).json({ success: false, message: 'Nie możesz dodać siebie do znajomych' });
    }

    const existing = await Friendship.findOne({
      $or: [
        { requester: req.user._id, receiver: userId },
        { requester: userId, receiver: req.user._id },
      ],
    });
    if (existing) {
      return res.status(409).json({ success: false, message: 'Zaproszenie już istnieje lub jesteście znajomymi' });
    }

    const friendship = await Friendship.create({ requester: req.user._id, receiver: userId });
    res.status(201).json({ success: true, friendship });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /friends/accept/:id
router.post('/accept/:id', protect, async (req, res) => {
  try {
    const friendship = await Friendship.findOne({
      _id: req.params.id,
      receiver: req.user._id,
      status: 'pending',
    });
    if (!friendship) {
      return res.status(404).json({ success: false, message: 'Zaproszenie nie istnieje' });
    }

    friendship.status = 'accepted';
    await friendship.save();
    res.json({ success: true, friendship });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// DELETE /friends/reject/:id
router.delete('/reject/:id', protect, async (req, res) => {
  try {
    const friendship = await Friendship.findOneAndDelete({
      _id: req.params.id,
      $or: [{ requester: req.user._id }, { receiver: req.user._id }],
    });
    if (!friendship) {
      return res.status(404).json({ success: false, message: 'Zaproszenie nie istnieje' });
    }
    res.json({ success: true, message: 'Zaproszenie odrzucone' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /friends — lista zaakceptowanych znajomych
router.get('/', protect, async (req, res) => {
  try {
    const friendships = await Friendship.find({
      $or: [{ requester: req.user._id }, { receiver: req.user._id }],
      status: 'accepted',
    })
      .populate('requester', 'name email avatarUrl')
      .populate('receiver', 'name email avatarUrl');

    const friends = friendships.map((f) => {
      const isRequester = f.requester._id.toString() === req.user._id.toString();
      return isRequester ? f.receiver : f.requester;
    });

    res.json({ success: true, friends });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /friends/pending — oczekujące zaproszenia (przychodzące)
router.get('/pending', protect, async (req, res) => {
  try {
    const pending = await Friendship.find({
      receiver: req.user._id,
      status: 'pending',
    }).populate('requester', 'name email avatarUrl');

    res.json({ success: true, pending });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
