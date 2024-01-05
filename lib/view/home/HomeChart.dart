import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class HomeChart extends StatefulWidget {
  final List<List<num>> dataPoints; // 用於存儲數據點的列表

  HomeChart(this.dataPoints);

  @override
  _HomeChart createState() => _HomeChart();
}

class _HomeChart extends State<HomeChart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            // 標題
            Center(
              child: Text(
                "Weight", // 標題為 "Weight"
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            // 圖表
            Expanded(
              child: charts.NumericComboChart(
                _createSampleData(widget.dataPoints), // 使用傳遞的數據點創建數據
                animate: true,
                defaultRenderer: charts.LineRendererConfig(
                  includePoints: true, // 設置為true以顯示每個數據點
                ),
                primaryMeasureAxis: charts.NumericAxisSpec(
                  tickProviderSpec: charts.BasicNumericTickProviderSpec(
                    zeroBound: true, // 啟用零刻度
                    dataIsInWholeNumbers: false,
                    desiredTickCount: 5,
                  ),
                ),
                domainAxis: charts.NumericAxisSpec(
                  tickProviderSpec: charts.BasicNumericTickProviderSpec(
                    zeroBound: true, // 啟用零刻度
                    desiredTickCount: 19,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  //自動根據資料來指定橫軸縱軸範圍
  List<charts.Series<List<num>, int>> _createSampleData(List<List<num>> dataPoints) {
    return [
      charts.Series<List<num>, int>(
        id: 'Weight', // 數據系列的標識為 'Weight'
        domainFn: (List<num> dataPoint, _) => dataPoint[0].toInt(), // X 軸數據
        measureFn: (List<num> dataPoint, _) => dataPoint[1], // Y 軸數據
        data: dataPoints, // 使用傳遞的數據點
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault, // 設置線的顏色為紅色
        seriesColor: charts.MaterialPalette.red.shadeDefault, // 設置點的顏色為紅色
      ),
    ];
  }


}
