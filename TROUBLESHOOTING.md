# Troubleshooting Connection Timeout Issues

## Problem
You're experiencing "Connection timed out" errors when uploading images in your Flutter app.

## Solutions Implemented

### 1. Flutter App Improvements
- **Timeout Configuration**: Added 30-second timeout for regular requests and 60-second timeout for uploads
- **Better Error Handling**: Improved error messages and user feedback
- **Image Compression**: Added image compression to reduce file size and upload time
- **Loading Indicators**: Added visual feedback during uploads
- **Retry Functionality**: Added retry button for failed uploads

### 2. Backend Server Improvements
- **Request Timeouts**: Set 2-minute timeout for all requests
- **Better Logging**: Enhanced logging for debugging
- **Error Handling**: Improved error handling for timeout and file upload errors
- **File Validation**: Added file size and type validation

### 3. Network Configuration
- **CORS Settings**: Updated CORS to allow your network IP
- **Body Size Limits**: Increased body size limits for file uploads
- **Rate Limiting**: Configured rate limiting to prevent server overload

## Testing Steps

### 1. Test Backend Server
```bash
cd backend
npm install
npm start
```

### 2. Test Upload Functionality
```bash
cd backend
npm run test-upload
```

### 3. Test Health Check
```bash
curl http://localhost:3001/api/health
```

## Common Issues and Solutions

### Issue 1: "Connection timed out"
**Causes:**
- Slow network connection
- Large image files
- Server not running
- Wrong IP address

**Solutions:**
1. Check if server is running: `npm start` in backend directory
2. Verify IP address in `lib/services/api_service.dart`
3. Use smaller images (max 5MB)
4. Check network connectivity

### Issue 2: "File too large"
**Solution:**
- Images are automatically compressed to max 1024x1024 pixels
- Maximum file size is 5MB
- Select smaller images or use camera instead of gallery

### Issue 3: "Network error"
**Causes:**
- Wrong server IP address
- Firewall blocking connection
- Server not accessible

**Solutions:**
1. Update IP address in `lib/services/api_service.dart`
2. Check if server is accessible from your device
3. Verify firewall settings

### Issue 4: "Upload failed"
**Causes:**
- Server error
- File format not supported
- Disk space issues

**Solutions:**
1. Check server logs for errors
2. Use supported formats: JPEG, PNG, GIF, WebP
3. Ensure server has enough disk space

## Configuration Files

### Flutter App (`lib/services/api_service.dart`)
```dart
static const String baseUrl = 'http://192.168.193.200:8080/api'; // Update this IP
static const Duration _defaultTimeout = Duration(seconds: 30);
static const Duration _uploadTimeout = Duration(seconds: 60);
```

### Backend Server (`backend/server.js`)
```javascript
const PORT = process.env.PORT || 3001;
// CORS configuration for your network
app.use(cors({
  origin: ['http://192.168.193.200:8080', 'http://192.168.193.200:8081'],
  credentials: true
}));
```

## Debugging Steps

1. **Check Server Status**
   ```bash
   cd backend
   npm start
   ```

2. **Test Network Connectivity**
   ```bash
   ping 192.168.193.200
   ```

3. **Check Flutter Logs**
   - Run app in debug mode
   - Check console for error messages

4. **Test Upload Manually**
   ```bash
   cd backend
   npm run test-upload
   ```

## Performance Tips

1. **Image Optimization**
   - Use images under 1MB for faster uploads
   - Enable image compression in the app
   - Use JPEG format for photos

2. **Network Optimization**
   - Use stable Wi-Fi connection
   - Avoid uploading during peak hours
   - Close other apps using network

3. **Server Optimization**
   - Ensure adequate server resources
   - Monitor server logs for errors
   - Restart server if needed

## Emergency Fixes

### If uploads still fail:
1. **Restart Backend Server**
   ```bash
   cd backend
   npm start
   ```

2. **Clear Flutter Cache**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Check IP Address**
   - Update IP in `lib/services/api_service.dart`
   - Use `ipconfig` (Windows) or `ifconfig` (Mac/Linux) to find correct IP

4. **Test with Different Image**
   - Try a smaller image file
   - Use a different image format

## Support

If issues persist:
1. Check server logs in backend console
2. Check Flutter debug console
3. Verify network connectivity
4. Test with the provided test script 