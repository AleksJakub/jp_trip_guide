# Google Maps API Setup

To enable Google Maps functionality in the app, follow these steps:

## 1. Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps JavaScript API
   - Places API
   - Maps Android API (for Android)
   - Maps iOS API (for iOS)

## 2. Create API Key

1. Go to "Credentials" in the left sidebar
2. Click "Create Credentials" → "API Key"
3. Copy the generated API key

## 3. Configure the App

### Option A: Update web/index.html (Recommended for testing)
Replace `YOUR_GOOGLE_MAPS_API_KEY` in `web/index.html` with your actual API key:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_ACTUAL_API_KEY_HERE&libraries=places"></script>
```

### Option B: Use Environment Variables (For production)
1. Create a `.env` file in the project root
2. Add your API key:
   ```
   GOOGLE_MAPS_API_KEY=your_actual_api_key_here
   ```
3. Update `web/index.html` to use a placeholder that will be replaced during build

## 4. Restrict API Key (Recommended)

1. In Google Cloud Console, go to your API key
2. Click "Edit" (pencil icon)
3. Under "Application restrictions", select "HTTP referrers (web sites)"
4. Add your domain(s) where the app will be hosted
5. Under "API restrictions", restrict to only the APIs you need

## 5. Test the App

1. Run `flutter pub get`
2. Run the app
3. Navigate to the Maps tab
4. The map should now display properly

## Troubleshooting

- If you see "Google Maps API Key Required", the API key is not properly configured
- If you see "Cannot read properties of undefined (reading 'maps')", the Google Maps JavaScript API failed to load
- Make sure your API key has the correct APIs enabled
- Check that the API key is not restricted to specific domains that block your development environment

## Security Note

Never commit your actual API key to version control. Use environment variables or secure configuration management for production deployments.
