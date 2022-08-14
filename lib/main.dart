import 'dart:async';

import 'package:flutter/material.dart';
import 'package:good_point_client/models/Point.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Set<Marker> markerSet = Set();
List<Point> points = List.empty();

void main() => runApp(GoodPoint());

class GoodPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Good Point',
      home: MapSample(),
    );
  }
}

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

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  Marker firstMarker = Marker(
    markerId: MarkerId("Venetian Fortezza Castle"),
    position: LatLng(35.37236770428797, 24.47105981431628),
    infoWindow: InfoWindow(title: "This Is Info Window"),
    onTap: () {},
  );

  static final CameraPosition _vaiBeach = CameraPosition(
    target: LatLng(35.2530876, 26.2626557),
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: [
        GoogleMap(
              initialCameraPosition: _vaiBeach,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: markerSet,
          ),
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
                            IconButton(onPressed: () => {}, icon: const Icon(Icons.star)),
                            Text("Suggest")
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
