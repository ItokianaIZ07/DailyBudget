import 'package:flutter/material.dart';
import 'package:gestion_depenses/models/option_result.dart';
import 'package:gestion_depenses/services/category_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({super.key});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  late TextEditingController _nameEditingController;
  late TextEditingController _amountEditingController;
  late Color _currentColor;

  void changeColor(Color color) => setState(() => _currentColor = color);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Choisir une couleur"),
                Container(
                  width: 32.0, 
                  height: 32.0, 
                  decoration: BoxDecoration(
                    color: _currentColor, 
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [BoxShadow(color: const Color.fromARGB(90, 36, 36, 36), offset: Offset(2, 2))]
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _showColorPicker(context);
              },
              child: Text("Choisir une couleur"),
            ),
            Text("Limite de dépense mensuel pour cette catégorie"),
            TextField(
              controller: _amountEditingController,
              keyboardType: TextInputType.numberWithOptions(),
            ),
            ElevatedButton(
              onPressed: () async {
                String colorString =
                    '#${_currentColor.toARGB32().toRadixString(16).padLeft(8, '0')}';
                OperationResult result = await CategoryService.insert(
                  _nameEditingController.text,
                  colorString,
                  _amountEditingController.text,
                );
                if (!result.success) {
                  _showErrorDialog(context, result.message);
                  return;
                }
                _showSuccessDialog(context, result.message);
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

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 8),
              Text('Success'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context, true);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une couleur'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _currentColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
