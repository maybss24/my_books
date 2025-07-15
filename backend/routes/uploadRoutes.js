const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const router = express.Router();

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    // Generate unique filename with timestamp
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, 'book-cover-' + uniqueSuffix + ext);
  }
});

// File filter to only allow images
const fileFilter = (req, file, cb) => {
  console.log('File filter check:', {
    originalname: file.originalname,
    mimetype: file.mimetype,
    fieldname: file.fieldname
  });
  
  // More lenient validation - accept if either extension or mimetype is valid
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  console.log('File validation:', {
    extname: path.extname(file.originalname).toLowerCase(),
    extnameValid: extname,
    mimetypeValid: mimetype,
    allowedTypes: allowedTypes.toString()
  });

  // Accept if either extension or mimetype is valid
  if (extname || mimetype) {
    console.log('File accepted');
    return cb(null, true);
  } else {
    console.log('File rejected - not an image');
    cb(new Error('Only image files are allowed!'), false);
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024, // 5MB default
    files: 1, // Only allow 1 file
    fieldSize: 1024 * 1024 // 1MB for field data
  },
  fileFilter: fileFilter
});

// Upload single image
router.post('/image', upload.single('image'), async (req, res) => {
  try {
    console.log('Upload request received');
    console.log('Request headers:', req.headers);
    console.log('Request body:', req.body);
    console.log('Request file:', req.file);
    
    if (!req.file) {
      console.log('No file provided');
      return res.status(400).json({ error: 'No image file provided' });
    }

    console.log('File received:', {
      filename: req.file.filename,
      originalname: req.file.originalname,
      size: req.file.size,
      mimetype: req.file.mimetype,
      path: req.file.path
    });

    // Verify file was actually saved
    if (!fs.existsSync(req.file.path)) {
      console.error('File was not saved to disk');
      return res.status(500).json({ error: 'Failed to save file to disk' });
    }

    // Create the URL for the uploaded file
    const imageUrl = `/uploads/${req.file.filename}`;

    const response = {
      success: true,
      message: 'Image uploaded successfully',
      data: {
        filename: req.file.filename,
        originalName: req.file.originalname,
        size: req.file.size,
        url: imageUrl,
        path: req.file.path
      }
    };

    console.log('Sending response:', response);
    res.json(response);
  } catch (error) {
    console.error('Error uploading image:', error);
    res.status(500).json({ error: 'Failed to upload image' });
  }
});

// Delete uploaded image
router.delete('/image/:filename', async (req, res) => {
  try {
    const filename = req.params.filename;
    const filePath = path.join(uploadsDir, filename);

    console.log('Delete request for file:', filename);

    // Check if file exists
    if (!fs.existsSync(filePath)) {
      console.log('File not found:', filePath);
      return res.status(404).json({ error: 'Image file not found' });
    }

    // Delete the file
    fs.unlinkSync(filePath);
    console.log('File deleted successfully:', filename);

    res.json({
      success: true,
      message: 'Image deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting image:', error);
    res.status(500).json({ error: 'Failed to delete image' });
  }
});

// Get image info
router.get('/image/:filename', async (req, res) => {
  try {
    const filename = req.params.filename;
    const filePath = path.join(uploadsDir, filename);

    console.log('Get info request for file:', filename);

    // Check if file exists
    if (!fs.existsSync(filePath)) {
      console.log('File not found:', filePath);
      return res.status(404).json({ error: 'Image file not found' });
    }

    const stats = fs.statSync(filePath);
    const imageUrl = `/uploads/${filename}`;

    res.json({
      success: true,
      data: {
        filename: filename,
        size: stats.size,
        url: imageUrl,
        createdAt: stats.birthtime
      }
    });
  } catch (error) {
    console.error('Error getting image info:', error);
    res.status(500).json({ error: 'Failed to get image info' });
  }
});

// Error handling middleware for multer
router.use((error, req, res, next) => {
  console.log('Multer error:', error);
  console.log('Error type:', error.constructor.name);
  
  if (error instanceof multer.MulterError) {
    console.log('Multer error code:', error.code);
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: 'File too large. Maximum size is 5MB.' });
    }
    if (error.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({ error: 'Too many files. Only one file is allowed.' });
    }
    if (error.code === 'LIMIT_FIELD_COUNT') {
      return res.status(400).json({ error: 'Too many fields in the form.' });
    }
    return res.status(400).json({ error: error.message });
  }
  
  if (error) {
    console.log('General error:', error.message);
    return res.status(400).json({ error: error.message });
  }
  
  next();
});

module.exports = router; 