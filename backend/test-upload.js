const fs = require('fs');
const path = require('path');
const FormData = require('form-data');
const fetch = require('node-fetch');

async function testUpload() {
  try {
    console.log('Testing image upload...');
    
    // Create a test image file (1KB of random data)
    const testImagePath = path.join(__dirname, 'test-image.jpg');
    const testData = Buffer.alloc(1024, 'A'); // 1KB of data
    fs.writeFileSync(testImagePath, testData);
    
    console.log('Created test image:', testImagePath);
    
    // Create form data
    const form = new FormData();
    form.append('image', fs.createReadStream(testImagePath));
    
    // Upload to server
    const response = await fetch('http://localhost:5000/api/upload/image', {
      method: 'POST',
      body: form,
      headers: form.getHeaders(),
    });
    
    const result = await response.json();
    console.log('Upload response:', result);
    
    if (response.ok) {
      console.log('✅ Upload test successful!');
      console.log('File URL:', result.data.url);
    } else {
      console.log('❌ Upload test failed:', result.error);
    }
    
    // Clean up test file
    fs.unlinkSync(testImagePath);
    console.log('Cleaned up test file');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

// Run test if server is running
testUpload(); 