# My Books App

A cross-platform Flutter app for managing your personal book collection, with a Node.js/Express + MongoDB backend. Supports adding, editing, deleting, searching, and uploading book cover images.

---

## Features

-  Add, edit, delete, and view books
-  Search and filter by title and genre
-  Upload and display book cover images
-  Data stored in MongoDB
-  Works on Android, iOS, web, Windows, Mac, Linux

---

## Project Structure

```
my_books/
  backend/         # Node.js/Express/MongoDB backend API
  lib/             # Flutter app source code
  assets/          # App images
  ...
```

---

## Backend Setup (Node.js/Express)

### Prerequisites
- Node.js (v14+)
- MongoDB (local or Atlas)

### 1. Install dependencies
```bash
cd backend
npm install
```

### 2. Configure environment
Edit `backend/config.env` as needed:
```
PORT=8080
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/my_books_db
MAX_FILE_SIZE=5242880
UPLOAD_PATH=./uploads
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### 3. Start MongoDB
- Local: `mongod`
- Atlas: Update `MONGODB_URI` accordingly

### 4. Start the backend server
```bash
npm run dev
```
- The server will run at `http://localhost:8080`
- Health check: `http://localhost:8080/api/health`

### 5. Test API
```bash
curl http://localhost:8080/api/health
```

---

## Flutter App Setup

### Prerequisites
- Flutter SDK (3.x recommended)
- Android Studio/Xcode/VSCode

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Configure API URL
Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:8080/api';
```
- For Android emulator: `10.0.2.2`
- For iOS simulator: `localhost` or your IP
- For physical device: your computer's IP (e.g. `192.168.x.x`)

### 3. Run the app
```bash
flutter run
```

---

## API Endpoints

### Books
- `GET    /api/books`           - List all books
- `POST   /api/books`           - Add a new book
- `GET    /api/books/:id`       - Get book details
- `PUT    /api/books/:id`       - Update a book
- `DELETE /api/books/:id`       - Delete a book
- `GET    /api/books?query=...` - Search books

### Image Upload
- `POST   /api/upload/image`    - Upload a book cover (form-data, key: `image`)
- `GET    /uploads/filename`    - Access uploaded image

### Health
- `GET    /api/health`          - Server status

---

## Image Upload Notes
- Only image files (jpg, jpeg, png, gif, webp) are allowed
- Max file size: 5MB (configurable)
- Images are stored in `backend/uploads/`
- Image URLs are returned as `/uploads/filename.jpg` and must be prefixed with your backend host in the Flutter app

---

## Emulator/Device Networking Tips
- **Android emulator:** Use `10.0.2.2` to access your computer's localhost
- **iOS simulator:** Use `localhost` or your IP
- **Physical device:** Use your computer's IP (e.g. `192.168.x.x`)
- Make sure your phone and computer are on the same WiFi network
- Allow firewall access to port 8080

---

## Troubleshooting

### Backend
- **Port in use:** Change `PORT` in `config.env` and update Flutter API URL
- **MongoDB connection error:** Check if `mongod` is running and `MONGODB_URI` is correct
- **CORS error:** Add your frontend's URL to the CORS `origin` array in `backend/server.js`

### Flutter
- **Connection refused:** Check backend is running and API URL is correct
- **Image not displaying:** Make sure image URL is prefixed with backend host (e.g. `http://192.168.x.x:8080/uploads/filename.jpg`)
- **File too large:** Check backend `MAX_FILE_SIZE` setting

---

## Example Usage

### Add a Book (with image)
1. Tap "Add Book"
2. Fill in details and pick a cover image
3. Save - book will appear in the list with cover

### API Example (with curl)
```bash
curl -X POST http://localhost:8080/api/books \
  -H "Content-Type: application/json" \
  -d '{"title":"Sample Book","author":"Author","year":"2024","genre":"Fiction"}'
```

---

## License
MIT
