# Placement Watch 🟢

A personal, Android-only Flutter application for tracking VIT placement shortlist emails. It queries your Gmail account directly, matches company shortlists by your placement ID, and alerts you with system notifications whenever a new result is published.

---

## Google Cloud & OAuth Setup Instructions

To authenticate the app using Google Sign-In, you must associate your Android app's signing key fingerprint with your Google Cloud Console project.

### 1. Retrieve your SHA-1 Fingerprint
On your macOS machine, open a terminal and run the following command to get the SHA-1 fingerprint of your debug keystore:

```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android
```

Under the output certificates, copy the value of the **SHA1** key (e.g. `2F:3A:D4:...`).

### 2. Configure Google Cloud Console
1. Navigate to the [Google Cloud Console](https://console.cloud.google.com/).
2. Select your project **"VIT Placement Tracker"**.
3. Go to **APIs & Services** > **Credentials**.
4. Click **Create Credentials** and select **OAuth client ID**.
5. Set the Application Type to **Android**.
6. Set the **Package Name** to:
   `com.azim.placement_watch`
7. Paste your **SHA-1 certificate fingerprint** copied in Step 1.
8. Click **Create**.

---

## Running the Project in Android Studio

1. Open **Android Studio**.
2. Select **Open** and choose the project directory:
   `/Users/azimabdulla/Documents/VIT_Placement_Tracker`
3. Connect your Android device via USB debugging or start an emulator.
4. Run the project by pressing the green **Run** button or executing:
   ```bash
   flutter run
   ```

---

## Important Device Configuration

To ensure background alerts trigger reliably every 15 minutes when the app is closed:

1. On your Android phone, go to **Settings** > **Apps** > **Placement Watch**.
2. Select **Battery** or **App battery usage**.
3. Change the setting to **Unrestricted** (disabling battery optimization).
4. Ensure notifications are enabled.

---

## Project Structure

* `lib/main.dart` — App bootstrap, MultiProvider routing, and WorkManager background worker setup.
* `lib/core/`
  * `constants/constants.dart` — Default parameters (e.g. `I1F1A6M5` placement ID).
  * `database/db_helper.dart` — SQLite history database helper.
  * `services/`
    * `auth_service.dart` — Secure OAuth state, token caches.
    * `gmail_service.dart` — Deterministic search query (`from:vitianscdc2027@vitstudent.ac.in I1F1A6M5`).
    * `notification_service.dart` — Local alert manager.
    * `placement_provider.dart` — Overview and synchronization manager.
  * `theme/theme.dart` — Modern dark theme.
* `lib/presentation/`
  * `screens/`
    * `main_navigation_shell.dart` — Main bottom navigator, sign-in routing.
    * `home_screen.dart` — Real-time overview status card and latest alerts.
    * `history_screen.dart` — Filterable history of placement shortlists.
    * `detail_screen.dart` — Specific shortlist details with direct links to open the original email.
    * `settings_screen.dart` — Dynamic configuration settings (change criteria, disconnect).
