import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/color_utils.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';
import 'package:gestion_depenses/models/expense_category.dart';
import 'package:gestion_depenses/services/statistic_service.dart';

class CategoryBudgetProgressCard extends StatelessWidget {
  final ExpenseCategory expense;
  final _progress = StatisticService.getProgress;
  final _formatAr = CurrencyUtil.getFormater();
  final _getLimitLabel = StatisticService.getLimitLabel;
  final _calculLimitPerPeriod = StatisticService.adjustLimitByPeriod;
  final int period;

  CategoryBudgetProgressCard({
    super.key,
    required this.expense,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    Color progressColor = AppTheme.colors.primary;
    if (_progress.call(expense, period) >= 0.90 && period != 0) {
      progressColor = AppTheme.colors.danger;
    } else if (_progress.call(expense, period) >= 0.75) {
      progressColor = AppTheme.colors.accent;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: parseColor(
                        expense.category.category.color!,
                      ).withValues(alpha: 0.15),
                      child: Icon(
                        Icons.category_outlined,
                        color: parseColor(expense.category.category.color!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      expense.category.category.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${(_progress.call(expense, period) * 100).toDouble().toStringAsFixed(2)}%",
                    style: TextStyle(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatAr.format(expense.amount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: progressColor,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLimitLabel(period),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatAr.format(
                        _calculLimitPerPeriod(
                          limiteMensuelle:
                              expense.category.categoryLimit.amount,
                          period: period,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.colors.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress.call(expense, period).clamp(0.0, 1.0), // 0.75 -> 75%
                minHeight: 10, // Épaisseur de la barre
                backgroundColor: AppTheme.colors.surfaceMuted,
                color: progressColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
