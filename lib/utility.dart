import 'package:flutter/material.dart';

List<DataRow> createRowsPrice(
    String productId, String productName, double productMass) {
  return [
    DataRow(cells: [
      DataCell(
        Container(
          width: 100,
          child: Text(productId,
              style: TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
        ),
      ),
      DataCell(
        Container(
          width: 100,
          child: Text(productName,
              style: TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
        ),
      ),
      DataCell(
        Container(
          width: 100,
          child: Text(productMass.toString(),
              style: TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
        ),
      ),
    ]),
  ];
}
