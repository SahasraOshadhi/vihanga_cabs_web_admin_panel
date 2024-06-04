import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String timeText = "";
  String dateText = "";

  String formatCurrentLiveTime(DateTime time){
    return DateFormat("hh:mm:ss a").format(time);
  }

  String formatCurrentDate(DateTime time){
    return DateFormat("dd MMMM, yyyy").format(time);
  }


  getCurrentTimeLive(){
    final DateTime timeNow = DateTime.now();
    final String LiveTime = formatCurrentLiveTime(timeNow);
    final String LiveDate = formatCurrentDate(timeNow);

    if(this.mounted){
      setState(() {
       timeText = LiveTime;
       dateText = LiveDate;

      });
    }
  }

  @override
  void initState(){

    super.initState();

    timeText = formatCurrentLiveTime(DateTime.now());
    dateText = formatCurrentDate(DateTime.now());

    Timer.periodic(const Duration(seconds: 1), (timer){
      getCurrentTimeLive();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: const Text(
          "Welcome to Admin Web Portal"
        ),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                timeText + '\n' + dateText,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
