import 'package:battery_usage/services/database_helper.dart';
import 'package:battery_usage/services/power_consumption.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';

class AppDetail extends StatefulWidget {

  @override
  _AppDetailState createState() => _AppDetailState();
}

class _AppDetailState extends State<AppDetail> {

  Map data = {};

  final activeDurationController = TextEditingController();
  final backgroundDurationController = TextEditingController();
  final batteryPercentageController = TextEditingController();

  int batteryPercentage;
  String activeDuration;
  String backgroundDuration;

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));

    if ( duration.inHours > 0 ) {
      return "${twoDigits(duration.inHours)} hours  $twoDigitMinutes minutes";
    } else {
      return "$twoDigitMinutes minutes";
    }
  }

  // Database instance
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    activeDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    DatabaseHelper databaseHelper = DatabaseHelper();
    data = ModalRoute.of(context).settings.arguments;

    // Used for: Input field validations
    GlobalKey<FormState> _key = new GlobalKey();

    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 10.0),
          child: SingleChildScrollView(
            child: Column( 
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.grey[900],
                      elevation: 10,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.grey[50],
                              ),
                              onPressed: () {
                                moveToLastScreen();
                              }
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '${data['appName']} app settings',
                              style: TextStyle(
                                color: Colors.grey[50],
                                fontSize: 19.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ]
                ),
                SizedBox(height: 60.0,),
                Center(
                  child: SizedBox(
                    height: 180.0,
                    width: 180.0,
                    child: Card(
                      color: Colors.grey[800],
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Center(
                        child: CircleAvatar(
                          backgroundImage: AssetImage(data['imgUrl'].toString()),
                          radius: 80.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Center(
                    child: Divider(
                      thickness: 1.0,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(50.0),
                  child: Form(
                    key: _key,
                    child: Column(
                      children: [
                        SizedBox(height: 20,),
                        TextFormField(
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.grey[50],
                          ),
                          decoration: InputDecoration(
                            hintText: 'Battery percentage used',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            labelText: 'Battery percentage used',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          readOnly: true,
                          controller: batteryPercentageController,
                          onTap: () => onTapBatteryPercentage(),
                        ),
                        SizedBox(height: 25.0,),
                        TextFormField(
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.grey[50],
                          ),
                          decoration: InputDecoration(
                            hintText: 'Active hours',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            labelText: 'Active hours',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          readOnly: true,
                          controller: activeDurationController,
                          onTap: () => onTapActiveField(),

                        ),
                        SizedBox(height: 25.0,),
                        TextFormField(
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.grey[50],
                          ),
                          decoration: InputDecoration(
                            hintText: 'Background running hours',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            labelText: 'Background running hours',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          readOnly: true,
                          controller: backgroundDurationController,
                          onTap: () => onTapBackgroundField(),
                        ),
                        SizedBox(height: 70.0,),
                        SizedBox(
                          width: 180.0,
                          height: 45.0,
                          child: ElevatedButton(
                            onPressed: () {
                              updateBtnClicked();

                              activeDurationController.text = "";
                              backgroundDurationController.text = "";
                              batteryPercentageController.text = "";
                            },
                            child: Text('update'),
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              elevation: 5.0,
                              primary: Colors.deepOrangeAccent,
                              textStyle: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700
                              )
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> moveToLastScreen() async {
    Navigator.pop(context, {
      'updatedPowerStats': true
    });
  }

  updateBtnClicked() async {
    if(data['id'] != null) {
      int result = await databaseHelper.updatePowerConsumption(
        PowerConsumption.withId(
          id: data['id'],
          appName: data['appName'],
          imgUrl: data['imgUrl'],
          charge: this.batteryPercentage.toDouble(),
          activeDuration: this.activeDuration,
          backgroundDuration: this.backgroundDuration
        ));

      if(result != 0) {    // Successfully updated the app power consumption details
        showAlertDialog("✅ Successfully updated", "Power consumption stats saved successfully");
      } else {
        showAlertDialog("🛑 Error updating", "Error updating power consumption stats");
      }
    }
  }

  void showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: (){
              Navigator.of(context, rootNavigator: true).pop();
              moveToLastScreen();
            },
            child: Text('OK')
        )
      ],
      elevation: 24.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

  onTapBatteryPercentage() {
    FocusManager.instance.primaryFocus.unfocus();
    new Picker(
        adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
          const NumberPickerColumn(begin: 0, end: 99),
        ]),
        hideHeader: true,
        title: new Text("Select Battery usage"),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print("This is the battery usage by the app:${picker.getSelectedValues()[0].toString()} ");
          batteryPercentage = picker.getSelectedValues()[0];
          batteryPercentageController.text = '${batteryPercentage.toString()}%';
        }
    ).showDialog(context);
  }

  onTapActiveField(){
    FocusManager.instance.primaryFocus.unfocus();
    new Picker(
        adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
          const NumberPickerColumn(begin: 0, end: 999, suffix: Text(' hours')),
          const NumberPickerColumn(begin: 0, end: 60, suffix: Text(' minutes'), jump: 15),
        ]),
        hideHeader: true,
        title: new Text("Select Active Duration"),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print("This is the picked time: hours:${picker.getSelectedValues()[0].toString()} minutes: ${picker.getSelectedValues()[1].toString()}  ");
          if(picker.getSelectedValues()[0] > 0) {
            activeDuration = '${picker.getSelectedValues()[0]} hours ${picker.getSelectedValues()[1]} minutes';
          } else {
            activeDuration = '${picker.getSelectedValues()[1]} minutes';
          }
          print("Finalized duration active: $activeDuration" );
          activeDurationController.text = activeDuration;
        }
    ).showDialog(context);
  }

  onTapBackgroundField(){
    FocusManager.instance.primaryFocus.unfocus();
    new Picker(
        adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
          const NumberPickerColumn(begin: 0, end: 999, suffix: Text(' hours')),
          const NumberPickerColumn(begin: 0, end: 60, suffix: Text(' minutes'), jump: 15),
        ]),
        hideHeader: true,
        title: new Text("Select Background Duration"),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print("This is the picked time: hours:${picker.getSelectedValues()[0].toString()} minutes: ${picker.getSelectedValues()[1].toString()}  ");
          if(picker.getSelectedValues()[0] > 0 ){
            backgroundDuration = '${picker.getSelectedValues()[0]} hours ${picker.getSelectedValues()[1]} minutes';
          } else {
            backgroundDuration = '${picker.getSelectedValues()[1]} minutes';
          }
          print("Finalized duration active: $backgroundDuration" );
          backgroundDurationController.text = backgroundDuration;
        }
    ).showDialog(context);
  }
}
