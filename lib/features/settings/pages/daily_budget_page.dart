import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:gestion_depenses/core/utils/currency_util.dart';
import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/exception/daily_budget_not_found.dart';
import 'package:gestion_depenses/core/widgets/daily_budget_edit_form.dart';
import 'package:gestion_depenses/models/daily_budget.dart';
import 'package:gestion_depenses/services/daily_budget_service.dart';

class DailyBudgetPage extends StatefulWidget {
  const DailyBudgetPage({super.key});

  @override
  State<DailyBudgetPage> createState() => _DailyBudgetPageState();
}

class _DailyBudgetPageState extends State<DailyBudgetPage> {
  final _formatAr = CurrencyUtil.getFormater();
  final ScrollController _scrollController = ScrollController();

  DailyBudget? _budget;
  String? _message;

  final List<DailyBudget> _listBudget = [];

  static const int _pageSize = 20;

  int _offset = 0;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  Future<void> _loadTodayBudget() async {
    final DateTime today = DateTime.now();

    try {
      final budget = await DailyBudgetService.getBudgetByDate(today);

      if (!mounted) return;

      setState(() {
        _budget = budget;
        _message = null;
      });
    } on DailyBudgetNotFound {
      if (!mounted) return;

      setState(() {
        _budget = null;
        _message = "Aucun budget n'a été défini pour aujourd'hui.";
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement du budget d'aujourd'hui : $e");

      if (!mounted) return;

      setState(() {
        _message = "Impossible de charger le budget d'aujourd'hui.";
      });
    }
  }

  Future<void> _loadBudgets({bool refresh = false}) async {
    if (_isLoadingMore) return;

    if (refresh) {
      _offset = 0;
      _hasMore = true;
      _listBudget.clear();
    }

    if (!_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final budgets = await DailyBudgetService.getAllPlanifiedBudget(
        limit: _pageSize,
        offset: _offset,
      );

      if (!mounted) return;

      setState(() {
        _listBudget.addAll(budgets);

        _offset += budgets.length;

        if (budgets.length < _pageSize) {
          _hasMore = false;
        }

        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des budgets planifiés : $e");

      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadTodayBudget();
    await _loadBudgets(refresh: true);
  }

  Future<void> _showEditDialog() async {
    if (_budget == null) return;

    await showDialog(
      context: context,
      builder: (context) {
        return DailyBudgetEditForm(
          budget: _budget,
          onEdited: () async {
            await _loadTodayBudget();
            await _loadBudgets();
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {

    if(_budget == null) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Supprimer le budget ?"),
          content: const Text(
            "Cette action est irréversible. Voulez-vous vraiment supprimer ce budget ?",
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
      await DailyBudgetService.deleteBudget(_budget!.id!);
      await _refresh();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadBudgets();
    }
  }

  Widget _buildTodayBudget() {
    return Card(
      elevation: 0,
      color: AppTheme.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius.md),
        side: BorderSide(color: AppTheme.colors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing.lg),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacing.sm),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius.sm),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppTheme.colors.primary,
              ),
            ),

            SizedBox(width: AppTheme.spacing.md),

            Expanded(
              child: _budget == null
                  ? Text(
                      _message ?? "Aucun budget aujourd'hui",
                      style: TextStyle(color: AppTheme.colors.textMuted),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Budget d'aujourd'hui",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.colors.secondary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _formatAr.format(_budget!.amount),
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.colors.text,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),

            if (_budget != null) ...[
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppTheme.colors.danger,
                tooltip: "Supprimer le budget",
                onPressed: () => _confirmDelete(context),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: AppTheme.colors.primary,
                onPressed: _showEditDialog,
                tooltip: "Modifier le budget",
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(DailyBudget budget) {
    final DateTime today = DateTime.now();

    final bool isToday =
        budget.date.year == today.year &&
        budget.date.month == today.month &&
        budget.date.day == today.day;

    return Card(
      elevation: 0,
      color: AppTheme.colors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius.sm),
        side: BorderSide(color: AppTheme.colors.border),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing.md,
          vertical: 4,
        ),

        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppTheme.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radius.sm),
          ),
          child: Icon(
            Icons.calendar_today_outlined,
            color: AppTheme.colors.primary,
          ),
        ),

        title: Text(
          DatetimeUtil.formatDate(budget.date),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: isToday
            ? Text(
                "Aujourd'hui",
                style: TextStyle(
                  color: AppTheme.colors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,

        trailing: Text(
          _formatAr.format(budget.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    _initialize();
  }

  Future<void> _initialize() async {
    await _loadTodayBudget();

    await _loadBudgets();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Budget")),

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.colors.primary),
            )
          : RefreshIndicator(
              onRefresh: _refresh,

              child: ListView(
                controller: _scrollController,

                padding: EdgeInsets.all(AppTheme.spacing.md),

                children: [
                  _buildTodayBudget(),

                  const SizedBox(height: 24),

                  Text(
                    "Budgets planifiés",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.colors.text,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_listBudget.isEmpty && !_isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "Aucun budget planifié.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.colors.textMuted),
                      ),
                    )
                  else
                    ..._listBudget.map((budget) => _buildBudgetCard(budget)),

                  if (_isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.colors.primary,
                          ),
                        ),
                      ),
                    ),

                  if (!_hasMore && _listBudget.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "Tous les budgets ont été chargés.",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.colors.textMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
