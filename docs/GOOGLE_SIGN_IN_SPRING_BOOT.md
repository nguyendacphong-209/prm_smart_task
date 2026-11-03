# Google Sign-In from Flutter to Spring Boot

The Flutter client signs the user in with Google, then sends the Google ID token to the app's backend. Android uses the native Google account picker; web uses Google's required rendered sign-in button. The app stores only the access and refresh tokens returned by Spring Boot.

## Google OAuth configuration

1. In Google Cloud Console, configure the OAuth consent screen.
2. Create an Android OAuth client for package `com.prm.smarttask` and add the SHA-1 fingerprint for the Android build you use.
3. Create a separate OAuth client of type **Web application**. Use this Web Client ID in Flutter and the backend. Do not use the Android Client ID as the backend audience.

Create the Flutter config file from its checked-in template:

```powershell
cd frontend
Copy-Item .env.example.json .env.json
notepad .env.json
```

Set `GOOGLE_WEB_CLIENT_ID` in `frontend/.env.json` to the Web application Client ID. The `.env.json` file is local and ignored by Git. Run or build Flutter with:

```powershell
flutter pub get
flutter run --dart-define-from-file=.env.json
flutter build apk --dart-define-from-file=.env.json
flutter build web --dart-define-from-file=.env.json
```

For a local Android Emulator test, start Spring Boot first from `backend\prm_smart_task`, then run Flutter against the host machine through Android Emulator's `10.0.2.2` address:

```powershell
cd frontend
flutter run --dart-define-from-file=.env.json --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

For a physical Android device, use the computer's LAN IP instead of `10.0.2.2`, and allow port `8080` through the computer firewall if needed. The Android cleartext HTTP setting is enabled only for debug builds; use HTTPS for release builds.

The Google Client ID is public configuration and is included in the compiled application; it is not a secret. Never put a Google client secret in Flutter.

## Backend local environment

Spring Boot imports `.env` from the backend project directory. Create it from the safe template and fill in the database, JWT, and Google Web Client ID values:

```powershell
cd backend\prm_smart_task
Copy-Item .env.example .env
notepad .env
.\gradlew.bat bootRun
```

The `GOOGLE_CLIENT_ID` value must be the same Web application Client ID used for Flutter. Keep `.env` private; only commit `.env.example`. For deployed Flutter Web, set `CORS_ALLOWED_ORIGINS` on the backend to the exact frontend origin (without a trailing slash).

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
