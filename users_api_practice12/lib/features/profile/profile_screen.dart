import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  void _say(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _choose() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    await _adopt(picked);
  }

  Future<void> _take() async {
    if (kIsWeb) {
      _say('The camera flow works on Android / iOS only.');
      return;
    }
    // At the moment of the tap — never in initState.
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted ||
            PermissionStatus.limited ||
            PermissionStatus.provisional:
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          imageQuality: 85,
        );
        await _adopt(picked);
      case PermissionStatus.denied:
        _say('The camera is needed only to take your profile photo. '
            'You can still choose one from the gallery.');
      case PermissionStatus.restricted:
        _say('The camera is restricted on this device.');
      case PermissionStatus.permanentlyDenied:
        await _showBlocked();
    }
  }

  Future<void> _showBlocked() {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera is blocked'),
        content: const Text(
          'Camera access was denied. To take a photo, allow the camera '
          'for this app in the system settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  /// Copies the picked file into Documents so it survives a restart.
  Future<void> _adopt(XFile? picked) async {
    if (picked == null) return; // Cancel
    if (kIsWeb) {
      if (mounted) _say('Saving photos works on Android / iOS only.');
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final target = '${dir.path}/avatar.jpg';
    await File(picked.path).copy(target);
    await FileImage(File(target)).evict(); // same path, new pixels
    if (!mounted) return;
    await context.read<SettingsModel>().setAvatarPath(target);
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<SettingsModel>().avatarPath;
    ImageProvider? image;
    if (path != null) {
      final f = File(path);
      if (f.existsSync()) image = FileImage(f);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: image,
              child: image == null ? const Icon(Icons.person, size: 64) : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _choose,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose photo'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _take,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
            ),
          ],
        ),
      ),
    );
  }
}
