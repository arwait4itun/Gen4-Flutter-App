import 'dart:async';

import 'package:flyer/globals.dart' as globals;

import 'package:flutter/material.dart';
import 'package:flyer/screens/animations/ripple_animation.dart';

class UtilitiesPage extends StatefulWidget {
  const UtilitiesPage({Key? key}) : super(key: key);

  @override
  _UtilitiesPageState createState() => _UtilitiesPageState();
}

class _UtilitiesPageState extends State<UtilitiesPage>  with SingleTickerProviderStateMixin {

  var _visible = true;



  late AnimationController animationController;
  late Animation<double> animation;


  @override
  void initState() {
    super.initState();

    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 1));
    animation =
    new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });

  }

  MaterialButton _customButton(){

    return MaterialButton(
        child: globals.isRecording?
          const RipplesAnimation()
          : Center(
            child: Container(
            height: MediaQuery.of(context).size.height*0.3,
            width: MediaQuery.of(context).size.width*0.3,
            decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 55,
            ),
          ),
          ),
          onPressed: (){
            setState(() {
              globals.isRecording=!globals.isRecording;
            });
          }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.5,
      width: MediaQuery.of(context).size.width*0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          _customButton(),
          SizedBox.fromSize(),
          Text("File size: 0KB"),
          SizedBox.fromSize(),
          ElevatedButton(
              onPressed: ()=>{},
              child: Text("UPLOAD TO SERVER"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
              ),
          )
        ],
      )
    );

  }
}
