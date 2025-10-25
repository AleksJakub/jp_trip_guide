const fs = require('fs');
const path = require('path');

// Read .env file
const envPath = path.join(__dirname, '.env');
const templatePath = path.join(__dirname, 'web', 'index.html.template');
const outputPath = path.join(__dirname, 'web', 'index.html');

try {
  // Read .env file
  const envContent = fs.readFileSync(envPath, 'utf8');
  const apiKeyMatch = envContent.match(/GOOGLE_MAPS_API_KEY=(.+)/);
  
  if (!apiKeyMatch) {
    console.error('ERROR: GOOGLE_MAPS_API_KEY not found in .env file');
    process.exit(1);
  }
  
  const apiKey = apiKeyMatch[1].trim();
  console.log(`Found API key: ${apiKey}`);
  
  // Read template
  const templateContent = fs.readFileSync(templatePath, 'utf8');
  
  // Replace placeholder
  const outputContent = templateContent.replace('{{GOOGLE_MAPS_API_KEY}}', apiKey);
  
  // Write output
  fs.writeFileSync(outputPath, outputContent);
  
  console.log('Generated index.html with API key');
  console.log('Now run: flutter run -d chrome');
  
} catch (error) {
  console.error('Error:', error.message);
  process.exit(1);
}
