# Local Flutter setup

Checked on Windows on 13 September 2026.

| Component | Result |
| --- | --- |
| Git and GitHub CLI | Installed; repository accessible as Asslanito |
| Flutter | 3.47.3, stable |
| Dart | 3.13.3, stable |
| SDK path | `C:\Users\Aslan\develop\flutter` |
| Course project | `C:\dev\flutter-2026-Aslan` |
| Android Studio | Installed, version 2025.1.3 |
| Editor plugins | Flutter and Dart installed and enabled |
| Android SDK | API 35 and API 36 installed |
| Build tools | 35.0.0 and 36.1.0 installed |
| Command-line tools, platform tools, emulator | Installed |
| Android licenses | All accepted |
| Java | Android Studio bundled OpenJDK 21 |
| NDK | 28.2.13676358 installed |
| Course emulator | Pixel_7_API_35, x86_64 Google APIs image, hardware GPU |
| Android device verification | Booted successfully; Flutter detects Android 15 / API 35 |
| Virtualization | Windows Hypervisor Platform available |

The existing Flutter SDK works and is already in the system PATH. Its location
contains no spaces or Cyrillic and is outside cloud-synced directories, so it was
kept in place instead of installing a duplicate. This location is also an example
in the [official Windows installation guide](https://docs.flutter.dev/install/manual).

`flutter doctor -v` reports the Flutter and Android toolchain checks as healthy.
Visual Studio for Windows desktop development is not installed; the course's
instructions explicitly allow desktop-target warnings.

API 35's system image and the required NDK were added. The installed sdkmanager
compatibility script splits semicolon-separated package names incorrectly, so
the packages were installed using the Android CLI directly:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\android.exe" --no-metrics sdk install 'system-images;android-35;google_apis;x86_64'
& "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\android.exe" --no-metrics sdk install 'ndk;28.2.13676358'
```

Low free disk space initially prevented the new emulator from creating its data
partition. Windows NTFS compression was applied to the Android system-image
directories and the saved RAM snapshots of inactive emulators. Files were retained.

## Completed code checks

- `dart run lib/week02/main.dart`: exits successfully and prints the report.
- `dart analyze`: `No issues found!`.
- `dart test`: all 12 Practice 2 tests pass.
- `flutter analyze` in `practice01/hello`: `No issues found!`.
- `flutter test` in `practice01/hello`: the counter increment test passes.
- Starter data compared against the original handout.
- No exclamation marks in `lib/week02/`.
- Only two explicit `dynamic` declarations: the unchanged starter data and the
  required factory parameter; the handout conflict is explained in the README.

The terminal demonstration output is saved in `practice02-output.txt`.

## Android first run

- `flutter build apk --debug --target-platform android-x64`: successful.
- `flutter run -d emulator-5554`: built, installed and launched the counter app.
- The on-device Increment button changed the displayed counter from 0 to 1.
- Pressing `r` completed hot reload in 550 ms (compile 16 ms, reassemble 242 ms).
- `flutter doctor -v`: Flutter, Android toolchain and Connected device are healthy;
  the connected emulator is Android 15 (API 35).

The verification emulator was run without a desktop window and is shut down after
testing. Open Android Studio's Device Manager and start `Pixel_7_API_35`, or use
`flutter emulators --launch Pixel_7_API_35` before the next `flutter run`.

The debug APK is generated locally at
`practice01/hello/build/app/outputs/flutter-apk/app-debug.apk`. Build products and
local SDK paths are excluded from Git; the source and dependency lockfiles are tracked.

<img src="flutter-counter-api35.png" width="280" alt="Flutter counter on Pixel 7 API 35, displaying 1 after tapping Increment">

## Course access

The repository is private, as required by the installation handout. The supplied
handout contains the placeholder `[my GitHub username]` instead of the teacher's
actual GitHub login. That login is needed to send the collaborator invitation.
