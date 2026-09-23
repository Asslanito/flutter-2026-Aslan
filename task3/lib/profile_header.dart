import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  final String name;
  final String university;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Image.asset(
            'assets/images/profile.jpg',
            width: 144,
            height: 144,
            fit: BoxFit.cover,
            semanticLabel: name,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'ProfileFont',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            university,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
