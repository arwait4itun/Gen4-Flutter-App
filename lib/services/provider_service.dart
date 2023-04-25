
import 'package:flutter/material.dart';
import 'package:flyer/globals.dart' as globals;

class ConnectionProvider extends ChangeNotifier{

  bool _isConnected = false;
  bool _PIDEnabled = false;

  bool get isConnected => _isConnected;
  bool get PIDEnabled => _PIDEnabled;

  void setConnection(bool c){

    _isConnected = c;
    globals.isConnected = c;
    notifyListeners();
  }


  void setPID(bool c){

    _PIDEnabled = c;
    notifyListeners();
  }

}
