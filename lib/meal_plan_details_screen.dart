import 'package:flutter/material.dart';

class MealPlanDetailsScreen extends StatelessWidget {
  final List<String> foodItemsList;
  final int totalCalories;
  final int targetCalories;

  MealPlanDetailsScreen({
    required this.foodItemsList,
    required this.totalCalories,
    required this.targetCalories,
  });

  // Stylized UI where it displays the information about the meal plan which contains the details
  // about the food items selected in the meal plan, the total calories of all the food items
  // and the target calories for that meal plan. This is mainly for display purposes and does not
  // contain any functional features as this screen is simply to display the required information.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Plan Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Meal Plan Details:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...foodItemsList.map((item) => Text(
                item,
                style: TextStyle(fontSize: 18),
              )),
              SizedBox(height: 16),
              Text(
                'Total Calories: $totalCalories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Target Calories: $targetCalories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
