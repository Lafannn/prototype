import 'package:flutter/material.dart';
import 'package:test/groups_list.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

const headerHeight = 60.0;

class _MyAppState extends State<MyApp> {
  var tapped = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Prototype')),
        body: GroupsList(),
      ),
    );
  }
}
