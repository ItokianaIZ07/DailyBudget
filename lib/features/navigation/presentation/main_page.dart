import 'package:flutter/material.dart';
import 'package:gestion_depenses/features/home/presentation/home_page.dart';
import 'package:gestion_depenses/features/expense/presentation/expense_page.dart';
import 'package:gestion_depenses/features/settings/pages/setting_page.dart';
import 'package:gestion_depenses/features/history/pages/history_page.dart';
import 'package:gestion_depenses/core/utils/datetime_util.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  int _selectedYear = DatetimeUtil.getNowYear();

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
                    items: [2024, 2025, 2026].map((int year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text('$year'),
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
}
