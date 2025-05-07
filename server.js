const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files from the public directory
app.use(express.static('public'));

// API endpoint to search for files
app.get('/api/search', (req, res) => {
  const query = req.query.q.toLowerCase();
  
  try {
    // Read all files from the 'codes' directory
    const codesDir = path.join(__dirname, 'codes');
    const files = fs.readdirSync(codesDir);
    
    // Filter files based on search query
    const results = files
      .filter(file => file.toLowerCase().includes(query))
      .map(file => {
        return {
          name: file,
          extension: path.extname(file).replace('.', ''),
          path: path.join(codesDir, file)
        };
      });
    
    res.json({ results });
  } catch (error) {
    console.error('Error searching files:', error);
    res.status(500).json({ error: 'An error occurred while searching files' });
  }
});

// API endpoint to download a file
app.get('/api/download', (req, res) => {
  const fileName = req.query.file;
  
  if (!fileName) {
    return res.status(400).json({ error: 'File name is required' });
  }
  
  try {
    const filePath = path.join(__dirname, 'codes', fileName);
    
    // Check if the file exists
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: 'File not found' });
    }
    
    // Send the file for download
    res.download(filePath);
  } catch (error) {
    console.error('Error downloading file:', error);
    res.status(500).json({ error: 'An error occurred while downloading the file' });
  }
});

// Serve the index.html for any other route
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});