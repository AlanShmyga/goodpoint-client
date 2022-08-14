import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends GoogleMap {

  MapWidget(
      {required CameraPosition initialCameraPosition,
      required bool myLocationEnabled,
      required bool zoomControlsEnabled,
      required Set<Marker> markers})
      : super(
          initialCameraPosition: initialCameraPosition,
          myLocationEnabled: myLocationEnabled,
          zoomControlsEnabled: zoomControlsEnabled,
          onMapCreated: (GoogleMapController controller) {
            Completer().complete(controller);
          },
          markers: markers
        );
}
