import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';

class HomePageHeader extends StatelessWidget {
  final String title;
  final String date;


  const HomePageHeader({
    required this.title,
    required this.date,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          date,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.colors.textMuted,
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}