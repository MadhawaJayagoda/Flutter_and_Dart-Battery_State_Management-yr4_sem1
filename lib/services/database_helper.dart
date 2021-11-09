import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:battery_usage/services/power_consumption.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;

  static Database _database;

  String powerConsumptionTable = 'powerconsumption_table';
  String colId = 'id';
  String colAppName = 'appName';
  String colImgUrl = 'imgUrl';
  String colCharge = 'charge';
  String colActiveDuration = 'activeDuration';
  String colBackgroundDuration = 'backgroundDuration';

  DatabaseHelper.createInstance();

  factory DatabaseHelper() {
    if(_databaseHelper == null ){
      _databaseHelper = DatabaseHelper.createInstance();
    }

    return _databaseHelper;
  }

  Future<Database> get getDatabase async {
    if(_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'powerconsumption.db';

    // Create/open the database at given path
    var powerConsumptionDB = await openDatabase(path, version: 1, onCreate: createDB);
    return powerConsumptionDB;
  }

  void createDB(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $powerConsumptionTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colAppName TEXT, '
        '$colImgUrl TEXT, $colCharge REAL, $colActiveDuration TEXT, $colBackgroundDuration TEXT)');
  }

  // Fetch operation: Get all PowerConsumption objects from the database
  Future<List<Map<String, dynamic>>> getPowerConsumptionMapList() async {

    Database db = await getDatabase;

    var result = db.query(powerConsumptionTable, orderBy: '$colCharge ASC');
    return result;
  }

  // Insert operation: Insert a PowerConsumption object
  Future<int> insertPowerConsumption(PowerConsumption powerConsumption) async {
    Database db = await getDatabase;
    var result = await db.insert(powerConsumptionTable, powerConsumption.toMap());
    return result;
  }

  // Update operation: Update a PowerConsumption object
  Future<int> updatePowerConsumption(PowerConsumption powerConsumption) async {
    Database db = await getDatabase;
    var result = await db.update(powerConsumptionTable, powerConsumption.toMap(), where: '$colId = ?', whereArgs: [powerConsumption.id]);
    return result;
  }

  // Delete operation: Delete a PowerConsumption object
  Future<int> deletePowerConsumption(int id) async {
    Database db = await getDatabase;
    int result = await db.rawDelete('DELETE FROM $powerConsumptionTable WHERE $colId = $id');
    return result;
  }

  Future<int> deleteAllPowerConsumption() async {
    Database db = await getDatabase;
    int result = await db.rawDelete('DELETE FROM $powerConsumptionTable');
    return result;
  }

  // Get Number of PowerConsumption objects in the database
  Future<int> getCount() async {
    Database db = await getDatabase;
    List<Map<String, dynamic>> num = await db.rawQuery('SELECT COUNT (*) FROM $powerConsumptionTable');
    int result = Sqflite.firstIntValue(num);
    return result;
  }

  // Get the MapLIst ( List<Map< String, dynamic>> ) and convert to PowerConsumption object List ( List<PowerConsumption>)
  Future<List<PowerConsumption>> getPowerConsumptionList() async {
    var powerConsumptionMapList = await getPowerConsumptionMapList();
    int count = powerConsumptionMapList.length;

    List<PowerConsumption> powerConsumptionObjectList = [];
    for(int i = 0;  i < count; i++ ) {
      powerConsumptionObjectList.add(PowerConsumption.fromMapObject(powerConsumptionMapList[i]));
    }
    return powerConsumptionObjectList;
  }
}