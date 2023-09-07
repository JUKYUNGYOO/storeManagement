// import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vertical_barchart/vertical-barchart.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:vertical_barchart/vertical-legend.dart';

class barchartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Creating a list of bar data models to display in the chart
    List<VBarChartModel> bardata = [
      VBarChartModel(
        index: 0,
        label: "주류",
        colors: [Colors.red, Colors.deepOrange],
        jumlah: 20,
        tooltip: "20 Pcs",
      ),
      VBarChartModel(
        index: 1,
        label: "과자류",
        colors: [Colors.blue, Colors.blueAccent],
        jumlah: 35,
        tooltip: "35 Pcs",
      ),
      VBarChartModel(
        index: 2,
        label: "식품",
        colors: [Colors.green, Colors.lightGreen],
        jumlah: 50,
        tooltip: "50 Pcs",
      ),
      VBarChartModel(
        index: 3,
        label: "음료",
        colors: [Colors.purple, Colors.deepPurple],
        jumlah: 30,
        tooltip: "30 Pcs",
      ),
      VBarChartModel(
        index: 4,
        label: "기타",
        colors: [Colors.orange, Colors.deepOrange],
        jumlah: 15,
        tooltip: "15 Pcs",
      ),
    ];

    // Returning a VerticalBarchart widget
    return VerticalBarchart(
      maxX: 55,
      data: bardata,
      showLegend: true,
      legend: [
        Vlegend(
          isSquare: false,
          color: Colors.red,
          text: "주류",
        ),
        Vlegend(
          isSquare: false,
          color: Colors.blue,
          text: "과자류",
        ),
        Vlegend(
          isSquare: false,
          color: Colors.green,
          text: "식품",
        ),
        Vlegend(
          isSquare: false,
          color: Colors.purple,
          text: "음료",
        ),
        Vlegend(
          isSquare: false,
          color: Colors.orange,
          text: "기타",
        ),
      ],
    );
  }
}
