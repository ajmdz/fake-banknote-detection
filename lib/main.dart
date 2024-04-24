import 'package:flutter/material.dart';
import 'package:counterfeat/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'CounterFeat',
        theme: ThemeData(
          
          useMaterial3: true,
        ),
        // home: ResultPage(data: {'message': 'test'})
        home: const HomePage(title: "CounterFeat") 
    );
  }
}
