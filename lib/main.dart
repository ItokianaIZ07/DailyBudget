import 'package:flutter/material.dart';

void main(){
  runApp( const MaterialApp(
    home: HomePage()
  ));
}

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Manager"), elevation: 12,
        actions: [Icon(Icon.add)],
        ),
      body: const Center(child: Text("Test"),),
    );
  }
}
