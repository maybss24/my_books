const { body, validationResult } = require('express-validator');

// Validation rules for book creation/update
const validateBook = [
  body('title')
    .trim()
    .notEmpty()
    .withMessage('Book title is required')
    .isLength({ max: 200 })
    .withMessage('Title cannot be more than 200 characters'),
  
  body('author')
    .trim()
    .notEmpty()
    .withMessage('Author name is required')
    .isLength({ max: 100 })
    .withMessage('Author name cannot be more than 100 characters'),
  
  body('year')
    .optional()
    .trim()
    .isInt({ min: 1000, max: new Date().getFullYear() + 1 })
    .withMessage('Year must be a valid year'),
  
  body('genre')
    .trim()
    .notEmpty()
    .withMessage('Genre is required')
    .isIn(['Fiction', 'Non-fiction', 'Biography', 'Fantasy', 'Science', 'Romance', 'Other'])
    .withMessage('Invalid genre selected'),
  
  body('imagePath')
    .optional()
    .isString()
    .withMessage('Image path must be a string'),
  
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description cannot be more than 1000 characters')
];



// Middleware to handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array().map(err => ({
        field: err.path,
        message: err.msg
      }))
    });
  }
  next();
};

module.exports = {
  validateBook,
  handleValidationErrors
}; 