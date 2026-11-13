# GP Health

An elderly-friendly, offline-first health companion for older adults in India.

## Product goals
- Large, high-contrast controls and simple navigation.
- Medicine schedules with local reminders and taken/skipped history.
- Family calling with explicit confirmation before opening the phone dialler.
- Emergency contact shortcut with confirmation.
- Manual language selection and voice interaction where the device supports the language offline.
- Optional caregiver access with explicit permissions and revocation.

## Safety and privacy
GP Health is a reminder and communication tool, not a medical professional. It does not diagnose, prescribe, or change doses. Keep essential data on-device by default; family sharing requires a network connection and clear consent. SOS calls require user confirmation.

## Planned app stack
Flutter for Android and iOS, local persistence, and platform local notifications. Offline speech recognition and text-to-speech will be capability-checked per device and language; the large microphone button and accessible manual controls remain available as fallbacks.

## Subscription concept (monthly, USD)
Free $0 · Pro $1 · Max $10 · Max Plus $50 · Ultra $100 · Ultra Pulse $500.

Core medicine reminders, saved contacts, and SOS contact access should remain free.

## Status
Project specification captured. The first implementation milestone is the accessible offline-first app shell and medicine workflow. Platform speech support, background wake-word behavior, multi-device family sync, and store billing require separate platform testing and configuration.
