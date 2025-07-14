const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Book title is required'],
    trim: true,
    maxlength: [200, 'Title cannot be more than 200 characters']
  },
  author: {
    type: String,
    required: [true, 'Author name is required'],
    trim: true,
    maxlength: [100, 'Author name cannot be more than 100 characters']
  },
  year: {
    type: String,
    trim: true,
    validate: {
      validator: function(v) {
        if (!v) return true; // Allow empty
        const year = parseInt(v);
        return year >= 1000 && year <= new Date().getFullYear() + 1;
      },
      message: 'Year must be between 1000 and next year'
    }
  },
  genre: {
    type: String,
    required: [true, 'Genre is required'],
    enum: ['Fiction', 'Non-fiction', 'Biography', 'Fantasy', 'Science', 'Romance', 'Other'],
    default: 'Other'
  },
  imagePath: {
    type: String,
    default: ''
  },
  description: {
    type: String,
    trim: true,
    maxlength: [1000, 'Description cannot be more than 1000 characters']
  },
  userId: {
    type: String,
    default: 'default-user'
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Index for better search performance
bookSchema.index({ title: 'text', author: 'text', genre: 1 });
bookSchema.index({ userId: 1, createdAt: -1 });

// Virtual for formatted year
bookSchema.virtual('formattedYear').get(function() {
  return this.year || 'N/A';
});

// Instance method to get public data
bookSchema.methods.toPublicJSON = function() {
  const book = this.toObject();
  delete book.__v;
  return book;
};

// Static method to find books by user
bookSchema.statics.findByUser = function(userId) {
  return this.find({ userId }).sort({ createdAt: -1 });
};

// Static method to search books
bookSchema.statics.search = function(userId, query, genre) {
  const searchQuery = { userId };
  
  if (query) {
    searchQuery.$or = [
      { title: { $regex: query, $options: 'i' } },
      { author: { $regex: query, $options: 'i' } }
    ];
  }
  
  if (genre && genre !== 'All') {
    searchQuery.genre = genre;
  }
  
  return this.find(searchQuery).sort({ createdAt: -1 });
};

module.exports = mongoose.model('Book', bookSchema); 