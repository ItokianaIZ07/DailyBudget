import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';
import 'package:gestion_depenses/models/daily_budget_situation.dart';

class BudgetStatCard extends StatefulWidget {
  final DailyBudgetSituation? situation;
  final String message;

  const BudgetStatCard({
    required this.situation,
    required this.message,
    super.key,
  });

  @override
  State<BudgetStatCard> createState() => _BudgetStatCardState();
}

class _BudgetStatCardState extends State<BudgetStatCard> {
  final _formatAr = CurrencyUtil.getFormater();

  Widget _buildSummaryPanel({
    required double budget,
    required double depense,
    required double reste,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildStatItem("Budget", _formatAr.format(budget), Colors.black87),
        _buildVerticalDivider(),
        _buildStatItem("Dépensé", _formatAr.format(depense), Colors.redAccent),
        _buildVerticalDivider(),
        _buildStatItem("Reste", _formatAr.format(reste), Colors.teal),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 32, width: 1, color: Colors.grey[300]);
  }

  @override
  Widget build(BuildContext context) {
    Color progressColor = AppTheme.colors.primary;
    if (widget.situation != null) {
      if (widget.situation!.percentage / 100 >= 0.90) {
        progressColor = AppTheme.colors.danger;
      } else if (widget.situation!.percentage / 100 >= 0.50) {
        progressColor = AppTheme.colors.accent;
      }
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.background,
        borderRadius: BorderRadius.circular(AppTheme.radius.lg),
        border: Border.all(color: AppTheme.colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.end,
        spacing: AppTheme.spacing.lg,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Aujourd'hui",
                style: TextStyle(
                  color: AppTheme.colors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.calendar_month_outlined),
            ],
          ),
          if (widget.message.trim().isNotEmpty && widget.situation == null)
            Text(widget.message, textAlign: TextAlign.center)
          else if (widget.situation != null) ...[
            _buildSummaryPanel(
              budget: widget.situation!.budget,
              depense: widget.situation!.spent,
              reste: widget.situation!.remaining,
            ),
            LinearProgressIndicator(
              value: widget.situation!.budget > 0
                  ? (widget.situation!.percentage / 100).clamp(0.0, 1.0)
                  : 0.0,
              borderRadius: BorderRadius.circular(8),
              minHeight: 10,
              backgroundColor: AppTheme.colors.surfaceMuted,
              color: progressColor,
            ),
            Row(
              mainAxisAlignment: widget.situation!.percentage > 100
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                if (widget.situation!.percentage > 100)
                  Text(
                    "Dépassement: ${_formatAr.format(widget.situation!.remaining * -1)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.colors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  "${widget.situation!.percentage.toStringAsFixed(1)}% consommé",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.colors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
