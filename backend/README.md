# My Books Backend API

A Node.js/Express backend API for the My Books Flutter application with MongoDB database.

## Features

- **Book Management**: CRUD operations for books
- **Image Upload**: File upload for book covers with validation
- **Search & Filter**: Search books by title/author and filter by genre
- **Security**: Rate limiting, input validation

## Prerequisites

- Node.js (v14 or higher)
- MongoDB (local installation or MongoDB Atlas)
- npm or yarn

## Installation

1. **Clone the repository and navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   - Copy `config.env` and modify as needed
   - Update `MONGODB_URI` to point to your MongoDB instance
   - Change `JWT_SECRET` to a secure random string

4. **Start MongoDB:**
   - Local installation: `mongod`
   - Or use MongoDB Atlas cloud service

5. **Run the server:**
   ```bash
   # Development mode with auto-restart
   npm run dev
   
   # Production mode
   npm start
   ```

The server will start on `http://localhost:3000`

## API Endpoints

### Books
- `GET /api/books` - Get all books (with optional query/genre filters)
- `GET /api/books/:id` - Get single book
- `POST /api/books` - Create new book
- `PUT /api/books/:id` - Update book
- `DELETE /api/books/:id` - Delete book
- `GET /api/books/stats/summary` - Get book statistics

### File Upload
- `POST /api/upload/image` - Upload book cover image
- `DELETE /api/upload/image/:filename` - Delete uploaded image
- `GET /api/upload/image/:filename` - Get image info

### Health Check
- `GET /api/health` - Server health status

## Database Schema

### Book Model
```javascript
{
  title: String (required),
  author: String (required),
  year: String (optional),
  genre: String (enum, required),
  imagePath: String (optional),
  userId: String (default: 'default-user'),
  timestamps: true
}
```

## Security Features

- **Input Validation**: Express-validator for request validation
- **Rate Limiting**: Prevents abuse with request limits
- **CORS**: Configured for Flutter app origins
- **Helmet**: Security headers middleware

## File Upload

- Supports JPEG, PNG, GIF, WebP formats
- Maximum file size: 5MB
- Files stored in `uploads/` directory
- Unique filenames with timestamps
- Automatic directory creation

## Error Handling

- Consistent error response format
- Detailed validation error messages
- Proper HTTP status codes
- Development vs production error details

## Development

### Scripts
- `npm run dev` - Start with nodemon (auto-restart)
- `npm start` - Start production server
- `npm test` - Run tests (when implemented)

### Environment Variables
```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/my_books_db
MAX_FILE_SIZE=5242880
UPLOAD_PATH=./uploads
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

## Production Deployment

1. Set `NODE_ENV=production`
2. Configure MongoDB Atlas or production MongoDB
3. Set up proper CORS origins
4. Use environment variables for sensitive data
5. Consider using PM2 or similar process manager

## Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   - Ensure MongoDB is running
   - Check connection string in config.env
   - Verify network access for cloud MongoDB

2. **CORS Errors**
   - Update CORS origins in server.js for your Flutter app
   - For Android emulator: `http://10.0.2.2:3000`
   - For physical device: Your computer's IP address

3. **File Upload Issues**
   - Check uploads directory permissions
   - Verify file size limits
   - Ensure supported file formats



## API Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response
```json
{
  "error": "Error message",
  "details": [
    {
      "field": "fieldName",
      "message": "Validation message"
    }
  ]
}
``` 