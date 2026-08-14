import 'package:flutter/material.dart';
import 'package:gestion_depenses/features/home/presentation/home_page.dart';
import 'package:gestion_depenses/features/expense/presentation/expense_page.dart';
import 'package:gestion_depenses/features/settings/pages/setting_page.dart';
import 'package:gestion_depenses/features/history/pages/history_page.dart';
import 'package:gestion_depenses/core/utils/datetime_util.dart';
import 'package:gestion_depenses/services/expense_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  int _selectedYear = DatetimeUtil.getNowYear();
  final List<int> _years = [];

  Future<void> _loadTransactionYears() async{
    try{
      final years = await ExpenseService.getListYearTransaction();
      setState(() {
        _years.clear();
        _years.addAll(years);
        _years.insert(0, -1);
        if(_years.length == 1 || !_years.contains(_selectedYear)){
          _selectedYear = _years.first;
        }
      });
    }catch(e){
      debugPrint("Erreur lors de l'initialisation des années :$e");
    }
  }

  @override
  void initState(){
    super.initState();
    _loadTransactionYears();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(),
      ExpensePage(),
      HistoryPage(selectedYear: _selectedYear,),
      SettingPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Manager'),
        actions: [
          if(_currentIndex == 2)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: _years.map((int year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: year > 0 ? Text('$year') : Text("Toutes"),
                      );
                    }).toList(),
                    onChanged: (int? newYear) {
                      if (newYear != null) {
                        setState(() => _selectedYear = newYear);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: "Dépenses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historique",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Paramètres",
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
