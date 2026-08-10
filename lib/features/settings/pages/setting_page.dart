import 'package:flutter/material.dart';
import 'category_list_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  Widget _buildMenuList(){
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Catégories"),
              Icon(Icons.category_outlined),
            ],
          ),
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context){
                return CategoriesPage();
              }));
          },
        );
      } 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Paramètre")),
      body : _buildMenuList()
    );
  }
}