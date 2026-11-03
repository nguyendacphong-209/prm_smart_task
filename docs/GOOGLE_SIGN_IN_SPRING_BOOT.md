# Google Sign-In from Flutter to Spring Boot

The Flutter client signs the user in with Google, then sends the Google ID token to the app's backend. Android uses the native Google account picker; web uses Google's required rendered sign-in button. The app stores only the access and refresh tokens returned by Spring Boot.

## Google OAuth configuration

1. In Google Cloud Console, configure the OAuth consent screen and create an Android OAuth client for package `com.prm.smarttask`.
2. Add the SHA-1 signing fingerprints used by the Android debug and release builds to that Android client.
3. Create a Web application OAuth client. Configure the authorized JavaScript origins for the web app, and use this web client ID for both the Flutter server client ID and backend audience:

   ```powershell
   cd frontend
   flutter pub get
   flutter run
   flutter build apk
   ```

The Web Client ID is configured in the Flutter Android data source, `web/index.html`, and the backend application properties. Override it with `GOOGLE_SERVER_CLIENT_ID` at Flutter build time or `GOOGLE_CLIENT_ID` in the Spring Boot environment if needed. Also set `CORS_ALLOWED_ORIGINS` to the exact deployed web origin (for example, `https://your-app.example.com`, without a trailing slash); separate multiple origins with commas. For local web development, the default CORS list permits localhost.

The client ID is public configuration, not a client secret; never put a client secret in Flutter.

For local backend development in PowerShell:

```powershell
$env:GOOGLE_CLIENT_ID = "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com"
$env:CORS_ALLOWED_ORIGINS = "http://localhost:7357"
cd backend\prm_smart_task
.\gradlew.bat bootRun
```

## Spring Boot API contract

The Flutter client sends:

```http
POST /api/auth/google
Content-Type: application/json

{"idToken":"<Google ID token>"}
```

The backend verifies the token's signature, issuer, expiration, audience, and verified-email claim before finding or creating the local account and issuing app tokens. The response has the same shape as `/api/auth/login`. Do not trust profile data sent separately by the Flutter client.
