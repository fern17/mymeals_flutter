import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

import '../models/meal.dart';
import 'new_edit_meal_screen.dart';

class MealScreen extends StatelessWidget {
  final Meal meal;
  final Function editMealCallback;
  final Function deleteMealCallback;

  MealScreen(
    this.meal,
    this.editMealCallback,
    this.deleteMealCallback,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              meal.name,
            ),
            IconButton(
              icon: Icon(
                  meal.favorite == 1 ? Icons.star : Icons.star_border_outlined),
              onPressed: () {
                meal.favorite = (meal.favorite == 0 ? 1 : 0);
                editMealCallback(meal);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Text(
              meal.description,
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  child: const Text('Edit'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => NewOrEditMealScreen(
                          null,
                          editMealCallback,
                          meal,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.of(context).pop(
                      deleteMealCallback(meal.id),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
