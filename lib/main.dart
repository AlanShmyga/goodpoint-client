import 'package:flutter/material.dart';
import 'package:good_point_client/widgets/MainWidget.dart';

void main() => runApp(GoodPoint());

class GoodPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Good Point',
      home: MainWidget(),
    );
  }
}
