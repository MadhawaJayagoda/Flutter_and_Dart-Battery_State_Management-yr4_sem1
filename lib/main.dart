import 'package:battery_usage/pages/add_app.dart';
import 'package:battery_usage/pages/app_detail.dart';
import 'package:battery_usage/pages/loading.dart';
import 'package:flutter/material.dart';
import 'package:battery_usage/pages/home_battery_usage.dart';

void main() {
  return runApp(MaterialApp(
    initialRoute: '/loading',
    routes: {
      '/': (context) => HomeBatteryUsage(),
      '/add': (context) => AddApp(),
      '/update': (context) => AppDetail(),
      '/loading': (context) => Loading()
    },
  ));
}




