import 'package:check_app_version/show_dialog.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check App Version',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Check App Version'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    ShowDialog(
      context: context,
      jsonUrl: 'https://besimsoft.com/example.json',
      updateButtonColor: Colors.blue,
      cupertinoDialog: true,
      onPressDecline: () => Navigator.of(context).pop(),
      onPressConfirm: () => Navigator.of(context).pop(),
    ).checkVersion();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(),
    );
  }
}
