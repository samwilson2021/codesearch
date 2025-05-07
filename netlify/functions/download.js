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
    const filePath = path.join(process.cwd(), 'codes', fileName);
    
    // Check if the file exists
    if (!fs.existsSync(filePath)) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: 'File not found' }),
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
      body: JSON.stringify({ error: 'An error occurred while downloading the file' }),
      headers: {
        'Content-Type': 'application/json'
      }
    };
  }
};