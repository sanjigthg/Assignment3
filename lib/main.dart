import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'add_food_screen.dart';
import 'delete_meal_plan_screen.dart';
import 'meal_plan_screen.dart';
import 'view_meal_plans_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Database _database;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  // Initializing the three tables that are required to properly handle CRUD operations and not cause errors, as well as distinguishing
  // the features for the application. These main features involve the user to add food items and calorie amounts for each, a meal plan that stores
  // the given food item(s) and its calories, as well as the date and max calorie amount for the meal plan itself.
  // Without properly initializing all three tables, I ran into errors whenever I tried to complete CRUD operations for specific meal plans.
  Future<void> _initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'food_database.db'),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE foods(id INTEGER PRIMARY KEY, name TEXT, calories INTEGER)',
        );
        db.execute(
          'CREATE TABLE meal_plans(id INTEGER PRIMARY KEY, date TEXT, targetCalories INTEGER)',
        );
        db.execute(
          'CREATE TABLE meal_plan_items(id INTEGER PRIMARY KEY, mealPlanId INTEGER, foodId INTEGER, '
              'FOREIGN KEY(mealPlanId) REFERENCES meal_plans(id), FOREIGN KEY(foodId) REFERENCES foods(id))',
        );
      },
      version: 1,
    );
  }

  // Main screens button selections that are styled to simply appear in the center of the screen, due to the nature of this
  // assignment, I did not spend time in making the UI more stylized and kept it simple as the importance is the overall
  // functionality of this assignment. In flutter/dart, the way to create buttons is using the ElevatedButtons package
  // and creating the widget that displays the text of each button.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Planner'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _navigateToAddFoodScreen(context);
                },
                child: Text('Add Food Item'),
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToMealPlanScreen(context);
                },
                child: Text('Make a Meal Plan'),
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToDeleteMealPlanScreen(context);
                },
                child: Text('Delete a Meal Plan'),
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToViewMealPlansScreen(context);
                },
                child: Text('View Meal Plans'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation functions to handle the button requests from above, when user selects any of the buttons
  // on the main screen, the navigate functions will take the user to the requested screen based on the selection (push).
  // The navigate functions are simple and straight forward to just handle page navigation and nothing more.
  void _navigateToMealPlanScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealPlanScreen(database: _database),
      ),
    );
  }

  void _navigateToViewMealPlansScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewMealPlansScreen(database: _database),
      ),
    );
  }

  void _navigateToDeleteMealPlanScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeleteMealPlanScreen(database: _database),
      ),
    );
  }

  void _navigateToAddFoodScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddFoodScreen(database: _database),
      ),
    );
  }
}
