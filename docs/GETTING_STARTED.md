# Run GP Health locally

## Requirements
- Flutter stable SDK (the CI workflow currently pins Flutter 3.29.3).
- Android Studio or Xcode for device builds. Xcode is required for iOS builds and is available only on macOS.
- A physical phone is recommended for checking phone-call handoff and accessibility.

## Start the app
```bash
flutter pub get
flutter run
```

## Run checks
```bash
flutter analyze
flutter test
```

## Current prototype behavior
- Add medicines and mark them as taken. The medicine list is stored on the device.
- Add family contacts and choose one emergency contact. Contacts are stored on the device.
- Tap a contact and confirm to open the phone dialler.
- SOS takes the user to the Family & SOS page; the emergency contact call also requires confirmation.

No OpenAI API key is needed for these offline prototype functions. Voice AI is not connected in this milestone.
