import 'package:flutter/widgets.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';

class BudgetInfoWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const BudgetInfoWidget({
    required this.label,
    required this.value,
    this.valueColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppTheme.colors.textMuted),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.colors.text,
          ),
        ),
      ],
    );
  }
}
