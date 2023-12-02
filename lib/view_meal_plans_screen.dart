import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'meal_plan_details_screen.dart';
import 'meal_plan_screen.dart';

class ViewMealPlansScreen extends StatefulWidget {
  final Database database;

  ViewMealPlansScreen({required this.database});

  @override
  _ViewMealPlansScreenState createState() => _ViewMealPlansScreenState();
}

class _ViewMealPlansScreenState extends State<ViewMealPlansScreen> {
  final _dateController = TextEditingController();

  // Widget to display the user input box for the date, and presented by a button that
  // will allow the user to query for the requested date if it exists within the database.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Meal Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  _queryMealPlan();
                },
                child: Text('Query Meal Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function that will display the required details from the provided date for a meal plan
  // after checking that the meal plan actually exists. It will display the required information
  // on the screen with the users requested target calories, the total calories of all the food items
  // that they selected. The messages upon successful or failure are presented using SnackBar.
  // The database is queried based on the date, and there are two tables being referenced when
  // the required data is being displayed on the screen.
  Future<void> _queryMealPlan() async {
    String date = _dateController.text.trim();
    if (date.isNotEmpty) {
      var mealPlans = await widget.database.query(
          'meal_plans', where: 'date = ?', whereArgs: [date]);

      if (mealPlans.isNotEmpty) {
        int mealPlanId = mealPlans[0]['id'] as int;
        var mealPlanItems = await widget.database.rawQuery(
          'SELECT foods.name, foods.calories FROM foods INNER JOIN meal_plan_items ON foods.id = meal_plan_items.foodId WHERE meal_plan_items.mealPlanId = ?',
          [mealPlanId],
        );

        int totalCalories = 0;
        List<String> foodItemsList = [];
        for (var item in mealPlanItems) {
          foodItemsList.add('${item['name']} - ${item['calories']} calories');
          totalCalories += item['calories'] as int;
        }

        int targetCalories = mealPlans[0]['targetCalories'] as int;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MealPlanDetailsScreen(
                  foodItemsList: foodItemsList,
                  totalCalories: totalCalories,
                  targetCalories: targetCalories,
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No meal plan found for the specified date.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a date.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

