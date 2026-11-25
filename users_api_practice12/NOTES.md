# Practice 12 — NOTES

## Level 1: package verdicts
(fill the `___` from each pub.dev page: Overview + Versions + Scores tabs)

1. **shared_preferences** — publisher flutter.dev (verified), last release ___ , all six platforms, ___ pub points, BSD-3, ___ open issues vs. recent commits; depends only on Flutter-team plugin packages.
2. **flutter_secure_storage** — publisher ___ (verified?), last release ___ , Android / iOS / macOS / Linux / Windows / web, ___ points, BSD-3, ___ issues vs. commits; Keychain / Keystore wrapper.
3. **path_provider** — publisher flutter.dev (verified), last release ___ , Android / iOS / macOS / Linux / Windows (no web), ___ points, BSD-3, federated plugin.
4. **image_picker** — publisher flutter.dev (verified), last release ___ , Android / iOS / web / macOS / Windows / Linux, ___ points, BSD-3.
5. **permission_handler** — publisher baseflow.com (verified?), last release ___ , Android / iOS / web / Windows (+ more), ___ points, MIT, ___ issues vs. commits.
6. **url_launcher** — publisher flutter.dev (verified), last release ___ , all six platforms, ___ points, BSD-3.

### The caret
- `http: ^1.2.0` accepts `>=1.2.0 <2.0.0` (1.2.1, 1.6.0 …); it refuses 1.1.x (too old) and 2.0.0 (a breaking major).
- `pubspec.lock` is committed for an app so every machine and the CI resolve exactly the same versions (reproducible builds); for a library it is not committed.
- `flutter pub outdated`: ___ could be newer, not upgraded because ___.

## Level 3: where a token must (not) live
- `prefs.setString('token', …)` would land in a plain XML file (`shared_prefs/…xml`, Android) / a plist (iOS) inside the app folder. Readable from a backup, with root, or over a cable (adb / backup extraction).
- iOS Keychain: items may survive an app uninstall, so after a reinstall an old token can still be there.
- Android Keystore: if the lock screen is removed, the keys can be invalidated and the stored data becomes unreadable (read fails → treated as signed out).

## Level 5: permissions
- Android: 1st No → `denied`; 2nd No → `permanentlyDenied` right away; on the 3rd tap no system dialog, only my dialog → "Open settings".
- iOS: the system asks only once. The first No → already `permanentlyDenied`; only Settings can change it. The fourth Photos state is `limited` (user shared selected photos only).
- `launchUrl(Uri.parse('kbtu.edu.kz'))` (no scheme) → false, nothing opens; with `https://` the browser opens.
