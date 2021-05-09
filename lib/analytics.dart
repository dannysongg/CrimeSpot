import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:pie_chart/pie_chart.dart';

class Analytics extends StatefulWidget {
  List<dynamic> crimeData;

  Analytics({Key key, this.crimeData}) : super(key: key);

  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  Map<String, double> crimeTypes = <String, double>{};

  void initState() {
    super.initState();
    crimeTypes = analyze();
  }

  Widget build(BuildContext context) {
    if (!widget.crimeData.isEmpty) {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
            child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 50.0),
                        child: PieChart(
                      dataMap: crimeTypes,
                      animationDuration: Duration(milliseconds: 1000),
                      chartLegendSpacing: 40,
                      chartRadius: MediaQuery.of(context).size.width / 1.5,
                      initialAngleInDegree: 0,
                      chartType: ChartType.disc,
                      ringStrokeWidth: 12,
                      centerText: "Crime Types",
                      legendOptions: LegendOptions(
                        showLegendsInRow: false,
                        legendPosition: LegendPosition.bottom,
                        showLegends: true,
                        legendShape: BoxShape.circle,
                        legendTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      chartValuesOptions: ChartValuesOptions(
                        showChartValueBackground: true,
                        showChartValues: true,
                        showChartValuesInPercentage: true,
                        showChartValuesOutside: true,
                      ),
                    ))
                  ],
                )));
      });
    } else
      return Center(child: CircularProgressIndicator());
  }

  Widget googleMapUI() {
    return GoogleMap();
  }

  Map<String, double> analyze() {
    Map<String, double> crimeTypes = <String, double>{};
    widget.crimeData.forEach((crime) {
      if (crimeTypes[crime["primary_type"]] == null)
        crimeTypes[crime["primary_type"]] = 1;
      else {
        crimeTypes[crime["primary_type"]] =
            crimeTypes[crime["primary_type"]] += 1;
      }
    });

    final sortedCrimes = new SplayTreeMap.from(
        crimeTypes, (a, b) => crimeTypes[a] < crimeTypes[b] ? 1 : -1);

    //get crimes within a threshold
    int threshold = 40;
    Map<String, double> topCrimes = Map.from(sortedCrimes)
      ..removeWhere((key, value) => value <= threshold);

    return topCrimes;
  }
}
