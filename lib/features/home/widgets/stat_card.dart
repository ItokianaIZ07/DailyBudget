import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String mainContent;
  const StatCard({required this.title, required this.mainContent, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.colors.surface,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              style: TextStyle(color: AppTheme.colors.text, fontSize: 12),
            ),
            Text(
              mainContent,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppTheme.colors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
