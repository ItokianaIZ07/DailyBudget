import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';
import 'package:gestion_depenses/models/monthly_budget_situation.dart';

class HomePageHeader extends StatelessWidget {
  final String title;
  final String date;
  final MonthlyBudgetSituation? montlySituation;
  final _formatAr = CurrencyUtil.getFormater();

  HomePageHeader({
    required this.title,
    required this.date,
    this.montlySituation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.colors.primary,
            AppTheme.colors.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.shadow.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.colors.surface.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppTheme.radius.md),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppTheme.colors.surface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.colors.surface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.colors.surface.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              date,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.colors.surface,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 18,),
          if(montlySituation != null)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reste du mois",
                  style: TextStyle(
                    color: AppTheme.colors.primarySoft,
                    fontSize: 16
                  ),
                ),
                Text(
                  _formatAr.format(montlySituation?.remaining),
                  style: TextStyle(
                    color: AppTheme.colors.background,
                    fontSize: 32,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            )
        ],
      ),
    );
  }
}