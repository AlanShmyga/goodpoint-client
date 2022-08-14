import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:good_point_client/widgets/MapWidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/Point.dart';
import 'package:http/http.dart' as http;


Set<Marker> markerSet = Set();
List<Point> points = List.empty();


class MainWidget extends StatefulWidget {
  @override
  State<MainWidget> createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> {

  static final CameraPosition _vaiBeach = CameraPosition(
    target: LatLng(35.2530876, 26.2626557),
    zoom: 7,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
          children: [
            MapWidget(
                initialCameraPosition: _vaiBeach,
                myLocationEnabled: true,
                zoomControlsEnabled: true,
                markers: markerSet,
            )
            // PointList()
          ],
        ),
        bottomNavigationBar: Container(
            height: 90,
            child:
            Column(
              children: [
                Flexible(
                  flex: 9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          IconButton(onPressed: _searchNearby, icon: const Icon(Icons.place)),
                          Text("Places")
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(onPressed: () => {}, icon: const Icon(Icons.route)),
                          Text("Routes")
                        ],
                      ),
                      Column(
                          children: [
                            IconButton(onPressed: () => {}, icon: const Icon(Icons.explore)),
                            Text("Explore")
                          ]
                      ),
                      Column(
                        children: [
                          IconButton(onPressed: () => {}, icon: const Icon(Icons.menu)),
                          Text("Menu")
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2)
              ],
            )
        )
    );
  }

  void _searchNearby() {
    setState(() {
      _getMarkers();
    });
  }

  void _getPoints(Point point) async {
    var pointsURI = Uri.parse("http://localhost:8080/api/points");
    final response = await http.get(pointsURI);
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body).cast<String, dynamic>();
      points = parsed['_embedded']['points']
          .map<Point>((json) => Point.fromJson(json))
          .toList();
    } else {
      throw http.ClientException(
          "Unable to get Points from server.", pointsURI);
    }
  }

  void _getMarkers() async {
    Point pRynGlow = Point.fromCoordinates(
      /* latitude: */
        35.37236770428797,
        /* longitude: */ 24.47105981431628);
    _getPoints(pRynGlow);
    for (Point point in points) {
      markerSet.add(Marker(
          markerId: MarkerId(point.title),
          position: LatLng(point.latitude, point.longitude),
          infoWindow: InfoWindow(title: point.title),
          onTap: () {}));
    }
  }

  void _clearMarkers() {
    setState(() {
      markerSet.clear();
    });
  }
}
