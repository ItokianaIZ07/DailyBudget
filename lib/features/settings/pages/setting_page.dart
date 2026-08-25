import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/features/settings/pages/about_page.dart';
import 'package:gestion_depenses/features/settings/pages/salary_page.dart';
import 'package:gestion_depenses/services/expense_service.dart';
import 'category_list_page.dart';
import 'package:gestion_depenses/features/settings/widgets/option_menu.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check, color: AppTheme.colors.success),
              const SizedBox(width: 8),
              const Text('Success'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Supprimer la dépense ?"),
          content: const Text(
            "Cette action est irréversible. Voulez-vous vraiment supprimer toutes les dépenses ?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Annuler"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ExpenseService.deleteAllExpenses();
      _showSuccessDialog(context, "Toutes les dépenses ont été supprimé");
    }
  }

  Widget _buildPreferenceMenuList(BuildContext context) {
    return Column(
      children: [
        OptionMenu(
          context: context,
          icon: Icon(Icons.category_outlined),
          title: "Catégories",
          screen: CategoriesPage(),
        ),
        OptionMenu(
          context: context,
          icon: Icon(Icons.info_outline),
          title: "${"à".toUpperCase()} propos",
          screen: AboutPage(),
        ),
        OptionMenu(
          context: context,
          icon: Icon(Icons.payments_outlined),
          title: "Salaire",
          screen: SalaryPage(),
        ),
      ],
    );
  }

  Widget _buildDataMenuList(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8),
        _buildSettingButton(
          label: "Supprimer toutes les dépenses",
          icon: Icon(
            Icons.delete_outline_outlined,
            color: AppTheme.colors.danger,
          ),
          color: AppTheme.colors.danger.withValues(alpha: 0.75),
          onPush: () async{
            await _confirmDelete(context);
          },
        ),
        // SizedBox(height: 10),
        // _buildSettingButton(
        //   label: "Restaurer les configuration par défaut",
        //   icon: Icon(Icons.refresh_sharp),
        //   onPush: (){}
        // ),
      ],
    );
  }

  Widget _buildSettingButton({
    required String label,
    Icon? icon,
    required VoidCallback onPush,
    Color? color,
  }) {
    return InkWell(
      onTap: () {
        onPush.call();
      },
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.colors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.colors.shadow.withValues(alpha: 0.20),
              offset: const Offset(0, 3),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color ?? AppTheme.colors.text,
              ),
            ),
            icon ?? Icon(Icons.do_not_disturb_alt),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Paramètre")),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Préference",
              style: TextStyle(
                color: AppTheme.colors.textMuted.withValues(alpha: 0.75),
              ),
            ),
            _buildPreferenceMenuList(context),
            SizedBox(height: 16),
            Text(
              "Données",
              style: TextStyle(
                color: AppTheme.colors.textMuted.withValues(alpha: 0.75),
              ),
            ),
            _buildDataMenuList(context),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "\u00A9${DatetimeUtil.getNowYear()} - SpendWise by ItokianaIZ07. Compte bien, dépense peu",
            style: TextStyle(color: AppTheme.colors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
