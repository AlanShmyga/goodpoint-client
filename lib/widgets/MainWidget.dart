import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  LatLng currentLatLng = LatLng(35.2530876, 26.2626557);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
          children: [
            MapWidget(
              initialCameraPosition:
                  CameraPosition(target: currentLatLng, zoom: 7),
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
                          IconButton(onPressed: () => {
                            _determinePosition().then((value) => {
                              currentLatLng = LatLng(value.latitude, value.longitude)
                            }),
                            _searchNearby(currentLatLng)
                          },
                              icon: const Icon(Icons.place)),
                          Text("Places")
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(onPressed: () => {},
                              icon: const Icon(Icons.route)),
                          Text("Routes")
                        ],
                      ),
                      Column(
                          children: [
                            IconButton(onPressed: () => {},
                                icon: const Icon(Icons.explore)),
                            Text("Explore")
                          ]
                      ),
                      Column(
                        children: [
                          IconButton(onPressed: () => {},
                              icon: const Icon(Icons.menu)),
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

  void _searchNearby(LatLng around) {
    setState(() {
      _getMarkers(around);
    });
  }

  void _getPoints(LatLng around, {int radius = 4000}) async {
    var baseUrl = "http://localhost:8080";
    var pointsAPIUrl = baseUrl + "/api/points";
    var queryParametersUrl = pointsAPIUrl +
        "?latitude=" + around.latitude.toString() +
        "&longitude=" + around.longitude.toString() +
        "&radius=" + radius.toString();
    var pointsURI = Uri.parse(queryParametersUrl);
    http.Response response = await http.get(pointsURI);
    print(response.request);
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

  void _getMarkers(LatLng around) async {
    _getPoints(around);
    for (Point point in points) {
      markerSet.add(Marker(
          markerId: MarkerId(point.title),
          position: LatLng(point.latitude, point.longitude),
          infoWindow: InfoWindow(title: point.title),
          onTap: () {}));
    }
  }


  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
