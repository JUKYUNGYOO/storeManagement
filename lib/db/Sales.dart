class Sales {
  int? id;
  DateTime? startDate;
  DateTime? endDate;
  double? revenue;
  double? cumulativeRevenue;
  int? visitors;
  int? maxSales;
  int? minSales;

  Sales({
    this.id,
    this.startDate,
    this.endDate,
    this.revenue,
    this.cumulativeRevenue,
    this.visitors,
    this.maxSales,
    this.minSales,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'revenue': revenue,
      'cumulativeRevenue': cumulativeRevenue,
      'visitors': visitors,
      'maxSales': maxSales,
      'minSales': minSales,
    };
  }

  static Sales fromMap(Map<String, dynamic> map) {
    return Sales(
      id: map['id'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      revenue: map['revenue'],
      cumulativeRevenue: map['cumulativeRevenue'],
      visitors: map['visitors'],
      maxSales: map['maxSales'],
      minSales: map['minSales'],
    );
  }
}
