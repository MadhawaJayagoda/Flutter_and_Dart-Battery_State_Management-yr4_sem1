
import 'dart:ffi';

class PowerConsumption {
  int id;
  String appName;
  String imgUrl;
  double charge;
  String activeDuration;
  String backgroundDuration;

  PowerConsumption({ this.appName, this.imgUrl, this.charge, this.activeDuration, this.backgroundDuration});

  PowerConsumption.withId({ this.id, this.appName, this.imgUrl, this.charge, this.activeDuration, this.backgroundDuration});

  // Getters and Setters
  set setId(int _id) {
    this.id = _id;
  }

  int get getId {
    return this.id;
  }

  set setAppName(String _appName) {
    this.appName = _appName;
  }

  String get getAppName {
    return this.appName;
  }

  set setImgUrl(String _imgUrl) {
    this.imgUrl = _imgUrl;
  }

  String get getImgUrl {
    return this.imgUrl;
  }

  set setCharge(double _charge) {
    this.charge = _charge;
  }

  double get getCharge {
    return this.charge;
  }

  set setActiveDuration(String _activeDuration) {
    this.activeDuration = _activeDuration;
  }

  String get getActiveDuration {
    return this.activeDuration;
  }

  set setBackgroundDuration(String _backgroundDuration) {
    this.backgroundDuration = _backgroundDuration;
  }

  String get getBackgroundDuration {
    return this.backgroundDuration;
  }

  Map<String, dynamic> toMap() {

    var map = Map<String, dynamic>();

    if (id != null ){
      map['id'] = id;
    }
    map['appName'] = appName;
    map['imgUrl'] = imgUrl;
    map['charge'] = charge;
    map['activeDuration'] = activeDuration;
    map['backgroundDuration'] = backgroundDuration;

    return map;
  }

  PowerConsumption.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.appName = map['appName'];
    this.imgUrl = map['imgUrl'];
    this.charge = map['charge'];
    this.activeDuration = map['activeDuration'];
    this.backgroundDuration = map['backgroundDuration'];
  }
}