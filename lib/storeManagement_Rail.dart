import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:adminapp/colors.dart';
import 'package:adminapp/profileCard.dart';
import 'package:adminapp/home.dart';
import 'package:provider/provider.dart';
import 'package:adminapp/tokenModel.dart';
import 'package:adminapp/checkboxListTitleApp.dart';
import 'package:adminapp/storeManagement_scene1.dart';

class storeManagement_Rail extends StatefulWidget {
  @override
  _storeManagementState createState() => _storeManagementState();
}

class _storeManagementState extends State<storeManagement_Rail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Fetching the accessToken from Provider
    // final token = Provider.of<tokenModel>(context).accessToken;
    final token = Provider.of<tokenModel>(context).accessToken;
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final double offset = -780 / 2.54 * ui.window.devicePixelRatio;

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Text('InterMinds 사내매장'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: Container(
                height: 1400.0,
                child: profileCard(
                  name: "John Doe",
                  jobTitle: "Manager(InterMinds.co)",
                  accessToken: token,
                ),
              ),
            ),
          ],
        ),
      ),
      // drawer: buildSideMenu(context, token),
      body: Container(
        child: storeManagement_scene1(),
      ),
    );
  }
}
