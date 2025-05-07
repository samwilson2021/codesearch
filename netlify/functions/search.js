const fs = require('fs');
const path = require('path');

exports.handler = async (event) => {
  // Get query parameter
  const query = event.queryStringParameters.q ? event.queryStringParameters.q.toLowerCase() : '';
  
  try {
    // In Netlify Functions, you need to use path.join with process.env.LAMBDA_TASK_ROOT
    // to access files in the deployed package
    const codesDir = path.join(process.cwd(), 'codes');
    
    // Read all files from the 'codes' directory
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
    
    return {
      statusCode: 200,
      body: JSON.stringify({ results }),
      headers: {
        'Content-Type': 'application/json'
      }
    };
  } catch (error) {
    console.error('Error searching files:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'An error occurred while searching files' }),
      headers: {
        'Content-Type': 'application/json'
      }
    };
  }
};