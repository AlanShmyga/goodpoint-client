import 'package:flutter/material.dart';

import 'MainWidget.dart';

class PointList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: markerSet.length,
        itemBuilder: (builder, index) {
          final point = points[index];
          return ListTile(
            title: Text(point.title),
            subtitle: Text(point.description),
          );
        }
    );
  }
}
