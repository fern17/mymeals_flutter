import 'package:flutter/material.dart';
import 'package:my_meals/screens/new_edit_meal_screen.dart';
import 'models/meal.dart';
import 'screens/meal_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

const String DATABASE_NAME = 'meals_database.db';
const String TABLE_MEALS = 'Meals';

void initializeDatabase() async {
  sqfliteFfiInit();
  var mealsDatabase = await databaseFactoryFfi.openDatabase(DATABASE_NAME);
  await mealsDatabase.execute(
      'CREATE TABLE IF NOT EXISTS $TABLE_MEALS (id TEXT PRIMARY KEY, name TEXT, description TEXT, favorite INTEGER)');
  await mealsDatabase.setVersion(1);
  await mealsDatabase.close();
}

Future main() async {
  initializeDatabase();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyMeals',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage('MyMeals'),
      /*
      initialRoute: '/'
      routes: {
        '/': (context) => MyHomePage(('MyMeals'),
        '/meal': (context) => MealScreen(),
        '/new_meal': (context) => NewOrEditMealScreen(),
        '/edit_meal': (context) => NewOrEditMealScreen(),
      },
      */
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage(this.title);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Meal> meals = [];
  final _searchController = TextEditingController();
  bool showOnlyFavorites = false;

  void _readMealsFromDataBase() async {
    var mealsDatabase = await _openDatabase();
    final List<Map<String, dynamic>> maps =
        await mealsDatabase.query(TABLE_MEALS);
    setState(() {
      meals = List.generate(maps.length, (i) {
        return Meal(
          id: maps[i]['id'],
          name: maps[i]['name'],
          description: maps[i]['description'],
          favorite: maps[i]['favorite'],
        );
      });
    });
    await mealsDatabase.close();
  }

  @override
  void initState() {
    super.initState();
    _readMealsFromDataBase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget buildList(String filter) {
    return meals.isNotEmpty
        ? Expanded(
            child: ListView.builder(
              itemCount: meals.length,
              itemBuilder: (BuildContext context, int index) {
                SizedBox emptyWidget = new SizedBox(
                  height: 0,
                );
                if (filter.isEmpty || meals[index].name.contains(filter)) {
                  if (showOnlyFavorites && meals[index].favorite == 0) {
                    return emptyWidget;
                  } else {
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => MealScreen(
                              meals[index],
                              _editMealCallback,
                              _deleteMealCallback,
                            ),
                          ),
                        );
                      },
                      title: Text(meals[index].name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              meals[index].favorite == 1
                                  ? Icons.star
                                  : Icons.star_border_outlined,
                              size: 20.0,
                            ),
                            onPressed: () {
                              Meal meal = meals[index].copy();
                              meal.favorite = (meal.favorite == 0 ? 1 : 0);
                              _editMealCallback(meal, pop: false);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              size: 20.0,
                            ),
                            onPressed: () {
                              _deleteMealCallback(meals[index].id);
                            },
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  return emptyWidget;
                }
              },
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'No meals. Add one with the + button.',
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('What are you cooking today?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                Text('Show favorites only'),
                Switch(
                  value: showOnlyFavorites,
                  onChanged: (value) {
                    setState(() {
                      showOnlyFavorites = value;
                    });
                  },
                ),
              ],
            ),
            buildList(_searchController.text),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => NewOrEditMealScreen(
                  _newMealCallback,
                  null,
                  null,
                ),
              ),
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<Database> _openDatabase() async {
    Database db = await databaseFactoryFfi.openDatabase(DATABASE_NAME);
    return db;
  }

  void _newMealCallback(String name, String description, int favorite) async {
    var uuid = const Uuid();
    Meal newMeal = Meal(
      id: uuid.v1(),
      name: name,
      description: description,
      favorite: favorite,
    );
    var mealsDatabase = await _openDatabase();
    var newMealAsMap = newMeal.toMap();
    mealsDatabase.insert(
      TABLE_MEALS,
      newMealAsMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await mealsDatabase.close();
    _readMealsFromDataBase();
  }

  void _editMealCallback(Meal meal, {bool pop = true}) async {
    var mealsDatabase = await _openDatabase();
    await mealsDatabase.update(
      TABLE_MEALS,
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
    mealsDatabase.close();

    _readMealsFromDataBase();

    if (pop) {
      Navigator.pop(this.context);
    }
    /*
    Navigator.push(
      this.context,
      MaterialPageRoute(
        builder: (BuildContext context) => MealScreen(
          meal,
          _editMealCallback,
          _deleteMealCallback,
        ),
      ),
    );*/
  }

  void _deleteMealCallback(String mealId) async {
    var mealsDatabase = await _openDatabase();
    await mealsDatabase.delete(
      TABLE_MEALS,
      where: 'id = ?',
      whereArgs: [mealId],
    );
    mealsDatabase.close();
    _readMealsFromDataBase();
  }
}
