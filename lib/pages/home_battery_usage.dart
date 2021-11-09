import 'package:battery_usage/main.dart';
import 'package:battery_usage/services/power_consumption.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:battery_usage/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class HomeBatteryUsage extends StatefulWidget {

  @override
  _HomeBatteryUsageState createState() => _HomeBatteryUsageState();
}

class _HomeBatteryUsageState extends State<HomeBatteryUsage> {

  int _currentIndex = 4;

  DateTime now = new DateTime.now();
  final formatter = DateFormat.yMMMMd('en_US');
  String formattedDate;

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));

    if ( duration.inHours > 0 ) {
      return "${twoDigits(duration.inHours)} hours  $twoDigitMinutes minutes";
    } else {
      return "$twoDigitMinutes minutes";
    }
  }

  List<PowerConsumption> powerData = [];

  // DB Config attributes
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<PowerConsumption> powerConsumptionData;
  int count = 0;

  GlobalKey _tileKey = GlobalObjectKey("tile_2");
  GlobalKey _tileKey1 = GlobalObjectKey("tile_1");

  // PieChart data
  List<PowerLevelData> _chartData;

  @override
  void initState() {
    formattedDate = formatter.format(now);

    if(powerConsumptionData == null ) {
      powerConsumptionData = [];
      updateListView();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Battery usage by mobile apps',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 20.0,
        centerTitle: true,
        backgroundColor: Colors.grey[700],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 8.0),
        child: Column (
          children: [
            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            openPopupPieChart(context);
                          },
                          icon: Icon(
                            Icons.bar_chart,
                            size: 38.0,
                            color: Colors.white,
                          ),
                          iconSize: 20.0,
                        ),
                        IconButton(
                          onPressed: () {
                            showCoachMarkTileUpdate();
                          },
                          icon: Icon(
                            Icons.live_help_outlined,
                            size: 35.0,
                            color: Colors.white,
                          ),
                          iconSize: 20.0,
                        ),
                      ]
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 34.0, 0, 0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: Image.asset(
                    'assets/battery.png',
                    width: 60.0,
                    height: 100.0,
                    fit: BoxFit.contain,
                  ),
                  elevation: 20.0,
                  color: Colors.grey[800],
                ),
              ],
            ),
            SizedBox(height: 30.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Colors.grey[900],
                    elevation: 10,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            '$formattedDate',
                            style: TextStyle(
                              color: Colors.grey[50],
                              fontSize: 19.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ]
            ),
            SizedBox(height: 15.0,),
            Expanded(
              child: ListView.builder(
                itemCount: powerData.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: index == 2 ? _tileKey : index == 1 ? _tileKey1 : UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_){
                      setState(() {
                        snackBarMessage(context, '${powerData[index].appName} app data deleted successfully');
                        powerData.removeAt(index);
                        // deleteAppData(context, powerData[index]);
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
                      child: Card(
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage('${powerData[index].imgUrl}'),
                            radius: 26.0,
                          ),
                          onTap: () {
                            navigateToAppDetails(index);
                          },
                          onLongPress: () {
                            print("Long pressed on item: ${powerData[index].appName}");
                          },
                          title: Text(
                            '${powerData[index].appName}',
                            style: TextStyle(
                              color: Colors.grey[50],
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          subtitle: Text(
                            'Active: ${powerData[index].activeDuration}\nBackground: ${powerData[index].backgroundDuration}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12.0
                            ),
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            '${powerData[index].charge}%',
                            style: TextStyle(
                              color: Colors.grey[50],
                              fontSize: 15
                            ),
                          ),
                        ),
                      ),
                    ),
                    background: Container(
                      color: Colors.red,
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                        child: Icon(
                          Icons.delete,
                          size: 30.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
              ),
            )
          ],
        ),
      ),


      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedIconTheme: IconThemeData(
            color: Colors.deepOrange,
            size: 30.0
        ),
        unselectedItemColor: Colors.grey[400],
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.plumbing),
              label: 'Charge Status',
              backgroundColor: Colors.grey[850]
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Charge History',
              backgroundColor: Colors.grey[850]
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.grey[850]
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.bolt),
              label: 'Health',
              backgroundColor: Colors.grey[850]
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Battery Usage',
              backgroundColor: Colors.grey[850]
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  void navigateToAppDetails(index) async {
    dynamic result = await Navigator.pushNamed(context, '/update', arguments: {
      'id': powerData[index].id,
      'appName': powerData[index].appName,
      'imgUrl': powerData[index].imgUrl,
      'charge': powerData[index].charge,
      'activeDuration': powerData[index].activeDuration,
      'backgroundDuration': powerData[index].backgroundDuration
    });

    if(result['updatedPowerStats'] == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<PowerConsumption>> powerConsumptionFutureList = databaseHelper.getPowerConsumptionList();
      powerConsumptionFutureList.then((powerConsumptionList) {
        setState(() {
          this.powerConsumptionData = powerConsumptionList;
          this.count = powerConsumptionList.length;
          if(this.count == 0 ) {
            insertDataToDB();
            updateListView();
          }
          powerConsumptionList.sort((a, b) => a.charge.compareTo(b.charge));
          this.powerData = powerConsumptionList.reversed.toList();
          _chartData = getChartData();
          print("Database retrieved data count: $count");
        });
      });
    });
  }

  void insertDataToDB() async{
    int res1 = await databaseHelper.insertPowerConsumption(PowerConsumption( appName: 'NetFlix',imgUrl: 'assets/netflix.jpg', charge: 60.8, activeDuration: '4 hours 45 minutes', backgroundDuration: '45 minutes'));
    if(res1 != 0) {
      int res2 = await databaseHelper.insertPowerConsumption(PowerConsumption(
          appName: 'Facebook',
          imgUrl: 'assets/facebook.png',
          charge: 14.2,
          activeDuration: '1 hours 15 minutes',
          backgroundDuration: '10 minutes'));
      if (res2 != 0) {
        int res3 = await databaseHelper.insertPowerConsumption(PowerConsumption(
            appName: 'YouTube',
            imgUrl: 'assets/youtube.png',
            charge: 5.2,
            activeDuration: '35 minutes',
            backgroundDuration: '5 minutes'));
        if (res3 != 0) {
          int res4 = await databaseHelper.insertPowerConsumption(
              PowerConsumption(appName: 'Twitter',
                  imgUrl: 'assets/twitter.png',
                  charge: 8.2,
                  activeDuration: '45 minutes',
                  backgroundDuration: '5 minutes'));
          if (res4 != 0) {
            int res5 = await databaseHelper.insertPowerConsumption(
                PowerConsumption(appName: 'WhatsApp',
                    imgUrl: 'assets/whatsapp.png',
                    charge: 2.0,
                    activeDuration: '15 minutes',
                    backgroundDuration: '3 minutes'));
            if (res5 != 0) {
              int res6 = await databaseHelper.insertPowerConsumption(
                  PowerConsumption(appName: 'Shazam',
                      imgUrl: 'assets/shazam.png',
                      charge: 1.0,
                      activeDuration: '4 minutes',
                      backgroundDuration: '50 minutes'));
              if (res6 != 0) {
                print("Multiple Data added successfully to the database");
              } else {
                print("Could not save the data in the database");
              }
            } else {
              print("Could not save the data in the database");
            }
          } else {
            print("Could not save the data in the database");
          }
        } else {
          print("Could not save the data in the database");
        }
      } else {
        print("Could not save the data in the database");
      }
    } else {
      print("Could not save the data in the database");
    }
  }

  void deleteAllDataInDB() async {
    int result = await databaseHelper.deleteAllPowerConsumption();
    if( result > 0 ) {
      print("All the data rows in the Table deleted successfully");
    }
  }

  void deleteAppData(BuildContext context, PowerConsumption powerConsumption) async {
    int result = await databaseHelper.deletePowerConsumption(powerConsumption.id);
    if( result != 0) {
      snackBarMessage(context, '${powerConsumption.appName} app data deleted successfully');
      updateListView();
    }
  }

  void snackBarMessage(BuildContext context, String message){
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.grey[850],
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic
        ),
      ),
      backgroundColor: Colors.deepOrange,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showCoachMarkTileUpdate() {
    CoachMark coachMarkTile = CoachMark();
    RenderBox target = _tileKey.currentContext.findRenderObject();
    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = markRect.inflate(5.0);
    coachMarkTile.show(
      targetContext: _tileKey.currentContext,
      markRect: markRect,
      markShape: BoxShape.rectangle,
      children: [
        Positioned(
            top: markRect.top - 40.0,
            right: 5.0,
            child: Text("👇   Tap on App to update",
                style: const TextStyle(
                  fontSize: 24.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                )))
      ],
      duration: null,
      onClose: () {
        Timer(Duration(seconds: 1), () => showCoachMarkTileDelete());
      },
    );
  }

  void showCoachMarkTileDelete() {
    CoachMark coachMarkTile = CoachMark();
    RenderBox target = _tileKey1.currentContext.findRenderObject();
    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = markRect.inflate(5.0);
    coachMarkTile.show(
      targetContext: _tileKey1.currentContext,
      markRect: markRect,
      markShape: BoxShape.rectangle,
      children: [
        Positioned(
            top: markRect.bottom + 15.0,
            right: 5.0,
            child: Text("👈   Swipe to delete app",
                style: const TextStyle(
                  fontSize: 24.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                )))
      ],
      duration: Duration(seconds: 5),
    );
  }

  List<PowerLevelData> getChartData() {
    List<PowerLevelData> chartData = [];
    powerData.forEach((element) {
      var instancePowerLevel = PowerLevelData(element.charge, element.appName);
      chartData.add(instancePowerLevel);
    });
    return chartData;
  }

  openPopupPieChart(context) {
    Alert(
      style: AlertStyle(
        backgroundColor: Colors.grey[300],
      ),
      context: context,
      title: "Battery usage by apps \n pie chart view",
      content: Column(
        children: [
          Column(
            children: [
              Container(
                width: 300.0,
                height: 240.0,
                child: Center(
                    child: SfCircularChart(
                      legend: Legend(
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                      ),
                      series: <CircularSeries>[
                        DoughnutSeries<PowerLevelData, String>(
                          radius: '100%',
                          dataSource: _chartData,
                          xValueMapper: (PowerLevelData data, _) => data.appName,
                          yValueMapper: (PowerLevelData data, _) => data.powerLevel,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                          )
                        )
                      ],
                    )
                ),
              )
            ],
          )
        ],
      ),
    ).show();
  }
}

class PowerLevelData {
  double powerLevel;
  String appName;
  PowerLevelData(this.powerLevel, this.appName);
}
