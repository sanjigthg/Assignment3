import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DeleteMealPlanScreen extends StatefulWidget {
  final Database database;

  DeleteMealPlanScreen({required this.database});

  @override
  _DeleteMealPlanScreenState createState() => _DeleteMealPlanScreenState();
}

class _DeleteMealPlanScreenState extends State<DeleteMealPlanScreen> {
  final _dateController = TextEditingController();

  // UI to allow user to enter the the date with the expected format of 'YYYY-MM-DD',
  // and it's stylized to display the button within the center of the screen. There are
  // not a lot of UI stylization in this application as the logic has been the focus
  // of the development.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Meal Plan'),
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
            Center( // Wrap the button with Center
              child: ElevatedButton(
                onPressed: () {
                  _deleteMealPlan();
                },
                child: Text('Delete Meal Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // When the user wants to delete a meal plan from the database, this function will verify that
  // the meal plan first of all exists by querying for the date of the meal plan. If it exists, then
  // the function will continue and delete the data related to the two tables, 'meal_plan' and
  // 'meal_plan_items'. If the requested date does not exist, the user will be prompted by
  // a error message displayed by SnackBar.
  Future<void> _deleteMealPlan() async {
    String date = _dateController.text.trim();
    if (date.isNotEmpty) {
      var mealPlans = await widget.database.query(
          'meal_plans', where: 'date = ?', whereArgs: [date]);

      if (mealPlans.isNotEmpty) {
        int mealPlanId = mealPlans[0]['id'] as int;
        await widget.database.delete('meal_plan_items', where: 'mealPlanId = ?',
            whereArgs: [mealPlanId]);

        await widget.database.delete(
            'meal_plans', where: 'id = ?', whereArgs: [mealPlanId]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Meal plan and associated items deleted successfully.'),
            duration: Duration(seconds: 2),
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
