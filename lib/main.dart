import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyer/screens/Dashboard.dart';
import 'package:flyer/screens/bluetoothPage.dart';
import 'package:flyer/services/provider_service.dart';
import 'package:provider/provider.dart';
import 'globals.dart' as globals;



void main() {

  runApp(
    ChangeNotifierProvider(
      create: (context) => ConnectionProvider(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //disable landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.lightGreen,
        highlightColor: Colors.blue,
        sliderTheme: const SliderThemeData(
          showValueIndicator: ShowValueIndicator.always,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: "/bluetooth",
      routes: {
        '/bluetooth': (context) => BluetoothPage(),
      },
    );
  }
}
