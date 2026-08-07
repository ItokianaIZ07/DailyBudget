import 'package:flutter/material.dart';
import 'package:gestion_depenses/models/category.dart';
import 'package:gestion_depenses/models/category_limit.dart';
import 'package:gestion_depenses/repositories/category_repository.dart';
import 'package:gestion_depenses/repositories/category_limit_repository.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({super.key});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  late TextEditingController _nameEditingController;
  late TextEditingController _amountEditingController;
  final List<String> _colors = ["rouge", "bleu", "vert", "gris"];
  String? _colorChoosed = "rouge";

  @override
  void initState() {
    super.initState();
    _nameEditingController = TextEditingController();
    _amountEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nouvelle catégorie")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Nom de la catégorie"),
            TextField(controller: _nameEditingController),
            Text("Couleur"),
            DropdownButton<String>(
              value: _colorChoosed,
              items: _colors.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: (String? nouvelleValeur) {
                setState(() {
                  _colorChoosed = nouvelleValeur;
                });
              },
            ),
            Text("Limite de dépense mensuel pour cette catégorie"),
            TextField(controller: _amountEditingController, keyboardType: TextInputType.numberWithOptions(),),
            ElevatedButton(
              onPressed: () async {
                if (!_isCategoryNameValid(_nameEditingController.text)) {
                  _showErrorDialog(context, "Veuillez entrer le nom de la catégorie");
                  return;
                }
                if(!_isColorValid(_colorChoosed!)){
                  _showErrorDialog(context, "Veuillez choisir une couleur");
                  return;
                }
                if(!_isAmountValid(_amountEditingController.text)){
                  _showErrorDialog(context, "Veuillez entrer un nombre positif pour la limite mensuel");
                  return;
                }
                Category category = Category(
                  name: _nameEditingController.text,
                  color: _colorChoosed,
                );
                category.id = await CategoryRepository.createCategory(
                  category,
                );
                CategoryLimit limit = CategoryLimit(
                  amount: double.parse(_amountEditingController.text),
                  category: category,
                );
                await CategoryLimitRepository.createCategoryLimit(limit);
                Navigator.pop(context);
              },
              child: Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    _amountEditingController.dispose();
    super.dispose();
  }

  bool _isCategoryNameValid(String name) {
    try {
      double.parse(name);
      return false;
    // ignore: empty_catches
    } catch (e) {}
    return !name.isEmpty;
  }

  bool _isColorValid(String color) {
    return !color.isEmpty;
  }

  bool _isAmountValid(String amount) {
    try {
      double montant = double.parse(amount);
      if(montant < 0){
        return false;
      }
    } catch (e) {
      return false;
    }
    return !amount.isEmpty;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Erreur'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
