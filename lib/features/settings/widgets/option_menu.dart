import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';

class OptionMenu extends StatelessWidget {
  final BuildContext context;
  final Icon icon;
  final String title;
  final Widget screen;

  const OptionMenu({
    required this.context,
    required this.icon,
    required this.title,
    required this.screen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.shadow.withValues(alpha: 0.25),
            offset: const Offset(0, 3),
            blurRadius: 6,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title), icon],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
    );
  }
}
