import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../models/meal.dart';

class NewOrEditMealScreen extends StatefulWidget {
  Function? newMealCallback;
  Function? editMealCallback;
  Meal? meal;

  NewOrEditMealScreen(this.newMealCallback, this.editMealCallback, this.meal);

  @override
  State<NewOrEditMealScreen> createState() => _NewOrEditMealScreenState();
}

class _NewOrEditMealScreenState extends State<NewOrEditMealScreen> {
  final _mealNameController = TextEditingController();
  final _mealDescriptionController = TextEditingController();

  @override
  void dispose() {
    _mealNameController.dispose();
    _mealDescriptionController.dispose();
    super.dispose();
  }

  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.meal != null;
    if (isEditing) {
      _mealNameController.text = widget.meal!.name;
      _mealDescriptionController.text = widget.meal!.description;
      isFavorite = widget.meal!.favorite == 1;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit meal' : 'New Meal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: _mealNameController,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _mealDescriptionController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              Row(children: [
                Text('Mark as favorite'),
                Switch(
                  onChanged: (value) {
                    setState(() {
                      isFavorite = value;
                      if (isEditing) {
                        widget.meal!.favorite = isFavorite ? 1 : 0;
                      }
                    });
                  },
                  value: isFavorite,
                )
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _mealNameController,
                    builder: (context, value, child) {
                      return ElevatedButton(
                        child: Text('Save'),
                        onPressed: _mealNameController.text.isNotEmpty
                            ? () {
                                Navigator.of(context).pop(
                                  isEditing
                                      ? widget.editMealCallback!(
                                          Meal(
                                            id: widget.meal!.id,
                                            name: _mealNameController.text,
                                            description:
                                                _mealDescriptionController.text,
                                            favorite: isFavorite ? 1 : 0,
                                          ),
                                        )
                                      : widget.newMealCallback!(
                                          _mealNameController.text,
                                          _mealDescriptionController.text,
                                          isFavorite ? 1 : 0,
                                        ),
                                );
                              }
                            : null,
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
