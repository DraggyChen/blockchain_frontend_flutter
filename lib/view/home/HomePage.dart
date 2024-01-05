
import 'package:blockchain_frontend_flutter/view/home/HomeChart.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<List<num>> dataPoints = [
    [0, 0.2],
    [6, 0.15],
    [10, 0.1],
    [15, 0.05],
    [18, 0.05],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
                height: 200,
                width: 800,
                child: HomeChart(dataPoints),
              ),
              SizedBox(height: 20),
              Divider(  // 這裡使用 Divider
                thickness: 3,  // 設置線條的厚度
                color: Colors.black,  // 設置線條的顏色
                indent: 20,  // 設置線條開始位置的偏移
                endIndent: 20,  // 設置線條結束位置的偏移
              ),
              // Center(child: Text("文字介紹")),
              // Add more widgets here
            ],
          ),
        ),
      ),
    );
  }
}
