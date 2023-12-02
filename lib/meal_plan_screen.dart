import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class MealPlanScreen extends StatefulWidget {
  final Database database;

  MealPlanScreen({required this.database});

  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  late List<Map<String, dynamic>> foodItems;
  List<Map<String, dynamic>> selectedFoodItems = [];
  int selectedCalories = 1500;

  final _dateController = TextEditingController();
  final _caloriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    foodItems = await widget.database.query('foods');
    setState(() {});
  }

  // User input for calories and date for the meal plan, it also shows a scrollable
  // list view of the existing food items and their calories.
  // Once the user finishes entering the data and selecting the food items, they can select
  // the 'Build a Meal Plan' button which sends the information to the database.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make a Meal Plan'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Food Items:'),
              _buildFoodItemsList(),
              SizedBox(height: 16),
              Text('Enter Calorie Amount:'),
              TextField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Calories'),
              ),
              SizedBox(height: 16),
              Text('Enter Date:'),
              TextField(
                controller: _dateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(labelText: 'YYYY-MM-DD'),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _buildMealPlan();
                  },
                  child: Text('Build Meal Plan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This is the listview where it shows the food items that are stored in the database by
  // the user and are shown as a selectable option for the user to choose from and store into
  // their meal plan.
  Widget _buildFoodItemsList() {
    return Container(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Food Items:'),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              height: 150,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedFoodItems.contains(
                      foodItems[index]);
                  return ListTile(
                    title: Text(foodItems[index]['name']),
                    subtitle: Text('Calories: ${foodItems[index]['calories']}'),
                    tileColor: isSelected ? Colors.blue.withOpacity(0.3) : null,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedFoodItems.remove(foodItems[index]);
                        } else {
                          selectedFoodItems.add(foodItems[index]);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          Text('Selected Calories: ${_calculateSelectedCalories()}'),
        ],
      ),
    );
  }

  int _calculateSelectedCalories() {
    int totalCalories = 0;
    for (var foodItem in selectedFoodItems) {
      totalCalories += (foodItem['calories'] as int);
    }
    return totalCalories;
  }

  // This is the function logic where the values are entered and stored into the database.
  // The details from the meal plan are stored into two tables, one where the target calories
  // and date are stored into one table and joined with another table that holds the food items
  // related to that meal plan. There is also error checking to ensure that the user cannot enter
  // blank details for the meal plan and it requires them to fill out a date, target calories and
  // ensure that the total calories do not exceed the target calories.
  Future<void> _buildMealPlan() async {
    String date = _dateController.text.trim();
    String caloriesText = _caloriesController.text.trim();

    if (date.isNotEmpty && caloriesText.isNotEmpty) {
      int enteredCalories = int.tryParse(caloriesText) ?? 0;
      int totalCalories = 0;

      for (var foodItem in selectedFoodItems) {
        totalCalories += (foodItem['calories'] as int);
      }

      var existingMealPlans = await widget.database.query('meal_plans', where: 'date = ?', whereArgs: [date]);

      if (existingMealPlans.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A meal plan already exists for the selected date.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (totalCalories > enteredCalories) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Total calories exceed the entered calorie amount.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        int mealPlanId = await widget.database.insert(
          'meal_plans',
          {'date': date, 'targetCalories': enteredCalories},
        );

        for (var foodItem in selectedFoodItems) {
          await widget.database.insert(
            'meal_plan_items',
            {'mealPlanId': mealPlanId, 'foodId': foodItem['id']},
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal plan created successfully.'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter both date and calories.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
