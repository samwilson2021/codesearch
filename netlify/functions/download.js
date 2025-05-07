// netlify/functions/download.js
const fs = require('fs');
const path = require('path');

exports.handler = async (event) => {
  const fileName = event.queryStringParameters.file;
  
  if (!fileName) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'File name is required' }),
      headers: {
        'Content-Type': 'application/json'
      }
    };
  }
  
  try {
    // Try different paths to find the codes directory
    let codesDir;
    let filePath;
    
    // Array of possible paths where 'codes' might be located
    const possiblePaths = [
      path.join(process.cwd(), 'codes'),
      path.join(__dirname, '../..', 'codes'),       // From netlify/functions up two levels
      path.join(__dirname, '../../..', 'codes'),    // Alternative path
      '/opt/build/repo/codes'                       // Netlify-specific path
    ];
    
    // Try each path until we find one that exists
    for (const testPath of possiblePaths) {
      if (fs.existsSync(testPath)) {
        codesDir = testPath;
        filePath = path.join(testPath, fileName);
        
        // Check if the specific file exists
        if (fs.existsSync(filePath)) {
          console.log(`Found file at: ${filePath}`);
          break;
        }
      }
    }
    
    // If no valid path was found or file doesn't exist
    if (!codesDir || !filePath || !fs.existsSync(filePath)) {
      return {
        statusCode: 404,
        body: JSON.stringify({ 
          error: 'File not found',
          fileName: fileName,
          attempted_paths: possiblePaths.map(p => path.join(p, fileName))
        }),
        headers: {
          'Content-Type': 'application/json'
        }
      };
    }
    
    // Read the file
    const fileContent = fs.readFileSync(filePath);
    const fileExtension = path.extname(fileName).replace('.', '');
    
    // Determine content type based on file extension
    let contentType = 'application/octet-stream';
    if (fileExtension === 'txt') contentType = 'text/plain';
    if (fileExtension === 'html') contentType = 'text/html';
    if (fileExtension === 'css') contentType = 'text/css';
    if (fileExtension === 'js') contentType = 'application/javascript';
    if (fileExtension === 'json') contentType = 'application/json';
    if (fileExtension === 'png') contentType = 'image/png';
    if (fileExtension === 'jpg' || fileExtension === 'jpeg') contentType = 'image/jpeg';
    if (fileExtension === 'gif') contentType = 'image/gif';
    if (fileExtension === 'pdf') contentType = 'application/pdf';
    
    // Return the file for download
    return {
      statusCode: 200,
      body: fileContent.toString('base64'),
      headers: {
        'Content-Type': contentType,
        'Content-Disposition': `attachment; filename="${fileName}"`,
        'Content-Transfer-Encoding': 'base64'
      },
      isBase64Encoded: true
    };
  } catch (error) {
    console.error('Error downloading file:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ 
        error: 'An error occurred while downloading the file',
        message: error.message
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    };
  }
};