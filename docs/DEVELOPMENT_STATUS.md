# GP Health development status

## Implemented in the starter milestone
- Flutter app shell with large, high-contrast Home, Medicines and Family screens.
- Add a medicine with a name, reminder-time label and optional note.
- Mark a medicine as taken / not taken.
- Local on-device persistence using SharedPreferences. The medicine list survives an app restart and does not require internet access.
- Basic corrupt-data handling so invalid local JSON does not crash startup.
- SOS confirmation UI that explicitly does not claim to place a call yet.
- Medicine model serialization tests.

## Not implemented yet
- Scheduled local medicine notifications, notification permissions and reboot rescheduling.
- Taken/skipped event history and caregiver audit trail.
- Real phone-call integration and emergency contact management.
- Voice recognition, text-to-speech, wake phrase or language auto-detection.
- Translation catalog and verified offline speech packs for the 20 target Indian languages.
- Secure multi-user caregiver sharing and cloud synchronization.
- Authentication, subscription entitlements, Google Play Billing and Apple In-App Purchase.
- Encrypted health-data storage and formal privacy/security review.

## Offline and safety rules
- Medicine data must remain usable without internet.
- Cross-device family sharing requires connectivity; offline mode can only use data already on the device.
- Do not make medication, dosage or treatment recommendations.
- Do not place an SOS call without an explicit confirmation step.
- Do not represent the app as a medical device or substitute for professional care.
- Local preferences storage is a prototype convenience layer, not encrypted medical-record storage. Replace or protect it before production.

## Next implementation sequence
1. Local notifications, permission flow, schedule validation and notification rescheduling.
2. Contact management and confirmation-gated dialler launch.
3. Language selector and translated UI framework.
4. Offline speech capability detection and push-to-talk fallback.
5. Family access, consent, revocation and secure synchronization.
6. Privacy/security review, accessibility testing with older adults, and store compliance.
