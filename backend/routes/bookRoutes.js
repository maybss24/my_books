const express = require('express');
const Book = require('../models/Book');
const { validateBook, handleValidationErrors } = require('../middleware/validation');

const router = express.Router();

// Get all books
router.get('/', async (req, res) => {
  try {
    const { query, genre } = req.query;
    let books;

    if (query || genre) {
      books = await Book.search('default-user', query, genre);
    } else {
      books = await Book.findByUser('default-user');
    }

    res.json({
      success: true,
      data: books.map(book => book.toPublicJSON()),
      count: books.length
    });
  } catch (error) {
    console.error('Error fetching books:', error);
    res.status(500).json({ error: 'Failed to fetch books' });
  }
});

// Get a single book by ID
router.get('/:id', async (req, res) => {
  try {
    const book = await Book.findOne({ 
      _id: req.params.id
    });

    if (!book) {
      return res.status(404).json({ error: 'Book not found' });
    }

    res.json({
      success: true,
      data: book.toPublicJSON()
    });
  } catch (error) {
    console.error('Error fetching book:', error);
    if (error.kind === 'ObjectId') {
      return res.status(400).json({ error: 'Invalid book ID' });
    }
    res.status(500).json({ error: 'Failed to fetch book' });
  }
});

// Create a new book
router.post('/', validateBook, handleValidationErrors, async (req, res) => {
  try {
    const bookData = {
      ...req.body,
      userId: 'default-user'
    };

    const book = new Book(bookData);
    await book.save();

    res.status(201).json({
      success: true,
      message: 'Book created successfully',
      data: book.toPublicJSON()
    });
  } catch (error) {
    console.error('Error creating book:', error);
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        error: 'Validation failed',
        details: Object.values(error.errors).map(err => ({
          field: err.path,
          message: err.message
        }))
      });
    }
    res.status(500).json({ error: 'Failed to create book' });
  }
});

// Update a book
router.put('/:id', validateBook, handleValidationErrors, async (req, res) => {
  try {
    const book = await Book.findOne({ 
      _id: req.params.id
    });

    if (!book) {
      return res.status(404).json({ error: 'Book not found' });
    }

    // Update book fields
    Object.keys(req.body).forEach(key => {
      if (key !== 'userId' && key !== '_id') {
        book[key] = req.body[key];
      }
    });

    await book.save();

    res.json({
      success: true,
      message: 'Book updated successfully',
      data: book.toPublicJSON()
    });
  } catch (error) {
    console.error('Error updating book:', error);
    if (error.kind === 'ObjectId') {
      return res.status(400).json({ error: 'Invalid book ID' });
    }
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        error: 'Validation failed',
        details: Object.values(error.errors).map(err => ({
          field: err.path,
          message: err.message
        }))
      });
    }
    res.status(500).json({ error: 'Failed to update book' });
  }
});

// Delete a book
router.delete('/:id', async (req, res) => {
  try {
    const book = await Book.findOneAndDelete({ 
      _id: req.params.id
    });

    if (!book) {
      return res.status(404).json({ error: 'Book not found' });
    }

    res.json({
      success: true,
      message: 'Book deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting book:', error);
    if (error.kind === 'ObjectId') {
      return res.status(400).json({ error: 'Invalid book ID' });
    }
    res.status(500).json({ error: 'Failed to delete book' });
  }
});

// Get book statistics
router.get('/stats/summary', async (req, res) => {
  try {
    const totalBooks = await Book.countDocuments({ userId: 'default-user' });
    
    const genreStats = await Book.aggregate([
      { $match: { userId: 'default-user' } },
      { $group: { _id: '$genre', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    const yearStats = await Book.aggregate([
      { $match: { userId: 'default-user', year: { $ne: '' } } },
      { $group: { _id: '$year', count: { $sum: 1 } } },
      { $sort: { _id: -1 } },
      { $limit: 10 }
    ]);

    res.json({
      success: true,
      data: {
        totalBooks,
        genreStats,
        yearStats
      }
    });
  } catch (error) {
    console.error('Error fetching book stats:', error);
    res.status(500).json({ error: 'Failed to fetch book statistics' });
  }
});

module.exports = router; 