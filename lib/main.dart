import 'dart:async';

import 'package:flutter/material.dart';
import 'package:good_point_client/models/Point.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    onTap: () {},);
  Set<Marker> markerSet = Set();

  static final CameraPosition _vaiBeach = CameraPosition(
    target: LatLng(35.2530876, 26.2626557),
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        initialCameraPosition: _vaiBeach,
        myLocationEnabled: true,
        zoomControlsEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markerSet,
      ),
      appBar: AppBar(actions: [
        IconButton(
            onPressed: _searchNearby,
            icon: const Icon(Icons.place)),
        IconButton(
            onPressed: _clearMarkers,
            icon: const Icon(Icons.clear))
      ],),
    );
  }

  void _searchNearby() {
    setState(() {
      _getMarkers();
    });
  }

  Future<List<Point>> _getPoints(Point point) async {
    var pointsURI = Uri.parse("http://localhost:8080/api/points");
    final response = await http.get(pointsURI);
    if (response.statusCode == 200) {
      return parsePoints(response.body);
    } else {
      throw http.ClientException(
          "Unable to get Points from server.", pointsURI);
    }
  }

  void _getMarkers() async {
    Point pRynGlow = Point.fromCoordinates(
        /* latitude: */ 35.37236770428797,
        /* longitude: */ 24.47105981431628
    );
    List<Point> points = await _getPoints(pRynGlow);
    for (Point point in points) {
      markerSet.add(Marker(
          markerId: MarkerId(point.title),
          position: LatLng(point.latitude, point.longitude),
          infoWindow: InfoWindow(title: point.title),
          onTap: () {})
      );
    }
  }

  void _clearMarkers() {
    setState(() {
      markerSet.clear();
    });
  }

  List<Point> parsePoints(String body) {
    final parsed = jsonDecode(body).cast<String,dynamic>();
    return parsed['_embedded']['points']
        .map<Point>((json) => Point.fromJson(json)).toList();
  }
}