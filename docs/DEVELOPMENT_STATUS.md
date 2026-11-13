# GP Health development status

## Implemented in the prototype
- Flutter app shell with large, high-contrast Home, Medicines and Family screens.
- Add medicine with a name, reminder-time label and optional note.
- Record an individual medicine dose as taken or skipped.
- Persist a local dose history with medicine name, action and timestamp (latest 500 entries).
- Show the latest 12 dose-history entries in the Medicines screen.
- Medicine list persists locally across app restarts using SharedPreferences; core list viewing and editing does not require internet.
- Basic corrupt-data handling for saved medicine and contact JSON.
- Add family contacts with a name and phone number; contact data persists locally.
- Mark one saved family contact as the emergency contact.
- Call flow opens the phone app only after an explicit confirmation dialog.
- SOS screen routes to Family & SOS, where the saved emergency contact can be called after confirmation.
- Medicine model serialization tests.
- GitHub Actions workflow for Flutter static analysis and tests.

## Not implemented yet
- Scheduled local medicine notifications, permission flow and reboot rescheduling.
- Snoozing doses and editing/deleting medicines with automatic reminder updates.
- Voice recognition, text-to-speech, wake phrase and spoken-language auto-detection.
- Complete translated UI catalog and verified offline speech packs for the 20 target Indian languages.
- Secure multi-user caregiver sharing and cloud synchronization.
- Authentication, subscription entitlements, Google Play Billing and Apple In-App Purchase.
- Encrypted health-data storage and formal privacy/security review.
- Device testing on Android and iOS.

## Offline and safety rules
- Medicine and contact lists are stored locally and usable without internet.
- Cross-device family sharing requires connectivity; offline mode can only use data already on the device.
- Do not make medication, dosage or treatment recommendations.
- Do not place a call without an explicit confirmation step.
- Do not represent the app as a medical device or substitute for professional care.
- SharedPreferences is prototype convenience storage, not encrypted medical-record storage. Replace it with a properly secured database before production.
- Phone call launch behavior must be tested on real Android and iOS devices. The app opens the platform phone handler; it does not bypass carrier or device confirmation behavior.

## Next implementation sequence
1. Local notifications, permission flow, schedule validation and notification rescheduling.
2. Snooze support and medicine editing/deletion.
3. Language selector and translated UI framework.
4. Offline speech capability detection and push-to-talk fallback.
5. Family access, consent, revocation and secure synchronization.
6. Privacy/security review, accessibility testing with older adults, and store compliance.
