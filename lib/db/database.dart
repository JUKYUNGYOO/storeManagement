import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:adminapp/db/Sales.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();

  static Database? _db;

  DatabaseHelper._instance();

  String salesTable = 'sales_table';
  String colId = 'id';
  String colStartDate = 'startDate';
  String colEndDate = 'endDate';
  String colRevenue = 'revenue';
  String colCumulativeRevenue = 'cumulativeRevenue';
  String colVisitors = 'visitors';
  String colMaxSales = 'maxSales';
  String colMinSales = 'minSales';

  Future<Database?> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + '/sales.db';
    final salesListDB = await openDatabase(path, version: 1, onCreate: _createDb);
    return salesListDB;
  }

  void _createDb(Database db, int version) async {
    await db.execute('CREATE TABLE $salesTable'
        '($colId INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$colStartDate TEXT,'
        '$colEndDate TEXT,'
        '$colRevenue REAL,'
        '$colCumulativeRevenue REAL,'
        '$colVisitors INTEGER,'
        '$colMaxSales INTEGER,'
        '$colMinSales INTEGER)');
  }

  Future<List<Map<String, dynamic>>> getSalesMapList() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(salesTable);
    return result;
  }

  Future<List<Sales>> getSalesList() async {
    final List<Map<String, dynamic>> salesMapList = await getSalesMapList();

    final List<Sales> salesList = [];
    salesMapList.forEach((saleMap) {
      salesList.add(Sales.fromMap(saleMap));
    });

    salesList.sort((a, b) => a.startDate!.compareTo(b.startDate!));

    return salesList;
  }

  // 임의의 판매 데이터를 데이터베이스에 넣음
  Future<int> insertSale(Sales sales) async {
    Database? db = await this.db;
    final int result = await db!.insert(
      salesTable,
      sales.toMap(),
    );
    return result;
  }
}

void main() async {
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  Sales sales = Sales(
    startDate: DateTime(2022, 1, 1),
    endDate: DateTime(2022, 1, 5),
    revenue: 2000,
    cumulativeRevenue: 3000,
    visitors: 25,
    maxSales: 12,
    minSales: 6,
  );
  int insertedId = await dbHelper.insertSale(sales);
  print('삽입된 ID: $insertedId');
}
