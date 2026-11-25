// ignore_for_file: avoid_print
// Run once from the project root:  dart run tool/patch_platforms.dart
// Adds the camera permission + <queries> (Android) and the usage strings (iOS).
import 'dart:io';

const _intents = '''
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="mailto" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="tel" />
        </intent>
    ''';

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (manifest.existsSync()) {
    var s = manifest.readAsStringSync();
    if (!s.contains('android.permission.CAMERA')) {
      s = s.replaceFirst(
        '<application',
        '<uses-permission android:name="android.permission.CAMERA" />\n    <application',
      );
    }
    if (!s.contains('android:scheme="mailto"')) {
      if (s.contains('</queries>')) {
        s = s.replaceFirst('</queries>', '$_intents</queries>');
      } else {
        s = s.replaceFirst(
          '<application',
          '<queries>\n$_intents</queries>\n    <application',
        );
      }
    }
    manifest.writeAsStringSync(s);
    print('AndroidManifest.xml patched');
  }

  final plist = File('ios/Runner/Info.plist');
  if (plist.existsSync()) {
    var t = plist.readAsStringSync();
    if (!t.contains('NSCameraUsageDescription')) {
      t = t.replaceFirst(
        RegExp(r'</dict>\s*</plist>'),
        '\t<key>NSCameraUsageDescription</key>\n'
            '\t<string>The camera is used to take your profile photo.</string>\n'
            '\t<key>NSPhotoLibraryUsageDescription</key>\n'
            '\t<string>Your photo library is used to choose a profile photo.</string>\n'
            '</dict>\n</plist>',
      );
      plist.writeAsStringSync(t);
      print('Info.plist patched');
    }
  }
}
