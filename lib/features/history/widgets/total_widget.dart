import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';
import 'package:gestion_depenses/models/month.dart';

class TotalWidget extends StatelessWidget {
  final double totalExpense;
  final Month? selectedMonth;
  final int selectedYear;
  final _format = CurrencyUtil.getFormater();

  TotalWidget({
    required this.totalExpense,
    required this.selectedMonth,
    required this.selectedYear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAF5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD5EBDD),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2E5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 36,
              color: Color(0xFF159447),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total des dépenses',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF536174),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _format.format(totalExpense),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${selectedMonth?.value == null ? "" : selectedMonth?.label} ${selectedYear < 0 ? "Toutes les années" : selectedYear}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF159447),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2E5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up,
              size: 28,
              color: Color(0xFF159447),
            ),
          ),
        ],
      ),
    );
  }
}
