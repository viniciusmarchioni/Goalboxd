import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre"),
        flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue, Colors.white]))),
      ),
      body: const Scaffold(
          body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text("UI Developer"),
          Text("Vinicius Marchioni"),
          Text("Backend Developer"),
          Text("Vinicius Marchioni"),
          Text("Software Archtect"),
          Text("Vinicius Marchioni"),
          Text("UX Designer"),
          Text("Vinicius Marchioni"),
          Text("QA Tester"),
          Text("Vinicius Marchioni"),
          Text("Project Manager"),
          Text("Vinicius Marchioni")
        ]),
      )),
    );
  }
}
