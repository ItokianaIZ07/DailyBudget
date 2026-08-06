import 'package:flutter/material.dart';
import 'category_list_page.dart';

class SettingPage extends StatelessWidget {

  Widget _buildMenuList(){
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text("Categories"),
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