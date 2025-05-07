// netlify/functions/search.js
const fs = require('fs');
const path = require('path');

exports.handler = async (event) => {
  // Get query parameter
  const query = event.queryStringParameters.q ? event.queryStringParameters.q.toLowerCase() : '';
  
  try {
    // Try different paths to find the codes directory
    let codesDir;
    let files;
    
    // Array of possible paths where 'codes' might be located
    const possiblePaths = [
      path.join(process.cwd(), 'codes'),
      path.join(__dirname, '../..', 'codes'),      // From netlify/functions up two levels
      path.join(__dirname, '../../..', 'codes'),    // Alternative path
      '/opt/build/repo/codes'                       // Netlify-specific path
    ];
    
    // Try each path until we find one that exists
    for (const testPath of possiblePaths) {
      if (fs.existsSync(testPath)) {
        codesDir = testPath;
        files = fs.readdirSync(testPath);
        console.log(`Found codes directory at: ${codesDir}`);
        break;
      }
    }
    
    // If no valid path was found
    if (!codesDir) {
      return {
        statusCode: 500,
        body: JSON.stringify({ 
          error: 'Codes directory not found',
          attempted_paths: possiblePaths
        }),
        headers: { 'Content-Type': 'application/json' }
      };
    }
    
    // Filter files based on search query
    const results = files
      .filter(file => file.toLowerCase().includes(query))
      .map(file => {
        return {
          name: file,
          extension: path.extname(file).replace('.', ''),
          path: `/api/download?file=${encodeURIComponent(file)}`
        };
      });
    
    return {
      statusCode: 200,
      body: JSON.stringify({ 
        results,
        directory: codesDir,
        query: query,
        file_count: files.length
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    };
  } catch (error) {
    console.error('Error searching files:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ 
        error: 'An error occurred while searching files',
        message: error.message,
        stack: error.stack
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    };
  }
};