const mongoose = require('mongoose');

const CATEGORIES = ['jedzenie', 'transport', 'mieszkanie', 'rozrywka', 'zakupy', 'podroze', 'inne'];

const eventSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Nazwa wydarzenia jest wymagana'],
      trim: true,
      maxlength: [100, 'Nazwa nie może przekraczać 100 znaków'],
    },
    amount: {
      type: Number,
      required: [true, 'Kwota jest wymagana'],
      min: [0.01, 'Kwota musi być większa od 0'],
    },
    category: {
      type: String,
      enum: CATEGORIES,
      default: 'inne',
    },
    date: {
      type: Date,
      default: Date.now,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    participants: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
    splitAmount: {
      type: Number,
    },
  },
  { timestamps: true }
);

// Oblicz splitAmount przed zapisem
eventSchema.pre('save', function (next) {
  if (this.participants && this.participants.length > 0) {
    const totalPeople = this.participants.length + 1; // +1 za płacącego
    this.splitAmount = Math.round((this.amount / totalPeople) * 100) / 100;
  } else {
    this.splitAmount = this.amount;
  }
  next();
});

module.exports = mongoose.model('Event', eventSchema);
module.exports.CATEGORIES = CATEGORIES;
