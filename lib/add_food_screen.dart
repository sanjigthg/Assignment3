import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class AddFoodScreen extends StatefulWidget {
  final Database database;

  AddFoodScreen({required this.database});

  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();

  // Combined with the UI and logic to allow the user to save their food item and the calories
  // related to that food item. There is a error check to make sure that both fields are filled out
  // and if the details are valid, it will allow the user to store the information into the food items
  // table within the database. There are 3 tables in total, each table has its own purpose.
  // SnackBar is also used throughout all the application for error checking and successful
  // completions of user input to let the user know what the outcome is.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Food Name'),
            ),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Calories'),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  String name = _nameController.text.trim();
                  String caloriesText = _caloriesController.text.trim();
                  if (name.isNotEmpty && caloriesText.isNotEmpty) {
                    int calories = int.tryParse(caloriesText) ?? 0;
                    List<Map<String, dynamic>> existingFood = await widget.database.query(
                      'foods',
                      where: 'name = ?',
                      whereArgs: [name],
                    );

                    if (existingFood.isEmpty) {
                      await widget.database.insert(
                        'foods',
                        {'name': name, 'calories': calories},
                        conflictAlgorithm: ConflictAlgorithm.replace,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Food added successfully'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Food item already exists'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter both food name and calories'),
                      ),
                    );
                  }
                },
                child: Text('Save'),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
