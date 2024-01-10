import 'package:dbhazirlik/utils/dbhelper.dart';
import 'package:dbhazirlik/models/car.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  List<Car> cars = [];
  List<Car> carsByName = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController milesController = TextEditingController();
  TextEditingController queryController = TextEditingController();
  TextEditingController idUpdateController = TextEditingController();
  TextEditingController mileUpdateController = TextEditingController();
  TextEditingController nameUpdateController = TextEditingController();
  TextEditingController idDeleteController = TextEditingController();

  void _showMessageInScaffold(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 5,
        child: Scaffold(
          key: _scaffoldkey,
          appBar: AppBar(
            title: Text("Car App"),
            bottom: TabBar(tabs: [
              Tab(
                text: "Insert",
              ),
              Tab(
                text: "View",
              ),
              Tab(
                text: "Query",
              ),
              Tab(
                text: "Update",
              ),
              Tab(
                text: "Delete",
              ),
            ]),
          ),
          body: TabBarView(
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Car Name",
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextField(
                          controller: milesController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Car Miles",
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          String name = nameController.text;
                          int miles = int.parse(milesController.text);
                          _insert(name, miles);
                        },
                        child: Text("Insert Car Details")),
                  ],
                ),
              ),
              Container(
                  child: ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: cars.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == cars.length) {
                          return ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _queryAll();
                                });
                              },
                              child: Text("Refresh"));
                        }
                        return Container(
                          height: 40,
                          child: Center(
                            child: Text(
                              "id : ${cars[index].id} name : ${cars[index].name} miles : ${cars[index].miles}",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      })),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      child: TextField(
                        controller: queryController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Car Name",
                        ),
                        onChanged: (text) {
                          setState(() {
                            if (text.length >= 2) {
                              setState(() {
                                _query(text);
                              });
                            } else {
                              setState(() {
                                carsByName.clear();
                              });
                            }
                          });
                        },
                      ),
                      height: 100,
                    ),
                    Expanded(
                      child: Container(
                        height: 300,
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: carsByName.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                margin: EdgeInsets.all(2),
                                height: 40,
                                child: Center(
                                  child: Text(
                                    "id : ${carsByName[index].id} name : ${carsByName[index].name} miles : ${carsByName[index].miles}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: TextField(
                            controller: idUpdateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Car ID",
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: TextField(
                            controller: nameUpdateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Car Name",
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: TextField(
                            controller: mileUpdateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Car Miles",
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            int id = int.parse(idUpdateController.text);
                            String name = nameUpdateController.text;
                            int miles = int.parse(mileUpdateController.text);
                            _update(id, name, miles);
                          },
                          child: Text("Update Car Details")),
                    ],
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextField(
                          controller: idDeleteController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Car ID",
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          int id = int.parse(idDeleteController.text);
                          _delete(id);
                        },
                        child: Text("Update Car Details")),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void _insert(String name, int miles) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnMiles: miles
    };
    Car car = Car.fromMap(row);
    final id = await dbHelper.insert(car);
    _showMessageInScaffold("inserted row id : $id");
  }

  void _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    cars.clear();
    allRows.forEach((row) {
      Car car = Car.fromMap(row);
      cars.add(car);
      _showMessageInScaffold("Query Done");
      setState(() {});
    });
  }

  void _query(name) async {
    final allRows = await dbHelper.queryRows(name);
    carsByName.clear();
    allRows.forEach((row) {
      Car car = Car.fromMap(row);
      carsByName.add(car);
      setState(() {});
    });
  }

  void _update(int id, String name, int miles) async {
    Car car = Car(id, name, miles);
    final rowsAffected = await dbHelper.update(car);
    _showMessageInScaffold("updated $rowsAffected row(s)");
  }

  void _delete(int id) async {
    final rowsDeleted = await dbHelper.delete(id);
    _showMessageInScaffold("deleted $rowsDeleted row(s) : row $id");
  }
}
