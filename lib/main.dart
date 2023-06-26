import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flyer/screens/select_machine.dart';
import 'package:flyer/services/Flyer/provider_service.dart';
import 'package:flyer/services/Carding/provider_service.dart';
import 'package:flyer/services/DrawFrame/provider_service.dart';
import 'package:flyer/services/RingDoubler/provider_service.dart';

import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {


  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Future.delayed(Duration(seconds: 2 ));

  FlutterNativeSplash.remove();

  var status = await Permission.bluetooth.status;
  if (status.isDenied) {

    await Permission.bluetooth.request();
  }

  status = await Permission.bluetoothScan.status;
  if (status.isDenied) {

    await Permission.bluetoothScan.request();
  }

  status = await Permission.bluetoothAdvertise.status;
  if (status.isDenied) {

    await Permission.bluetoothAdvertise.request();
  }

  status = await Permission.bluetoothConnect.status;
  if (status.isDenied) {

    await Permission.bluetoothConnect.request();
  }



  if (await Permission.bluetooth.status.isPermanentlyDenied) {
    openAppSettings();
  }

  ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  runApp(
    MultiProvider(
      providers: [
        Provider<FlyerConnectionProvider>(create: (_) => FlyerConnectionProvider()),
        Provider<CardingConnectionProvider>(create: (_) => CardingConnectionProvider()),
        Provider<RingDoublerConnectionProvider>(create: (_) => RingDoublerConnectionProvider()),
        Provider<DrawFrameConnectionProvider>(create: (_) => DrawFrameConnectionProvider()),
      ],
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
      initialRoute: "/selectMachine",
      routes: {
        '/selectMachine': (context) => SelectMachineUI(),
      },
    );
  }
}
