import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lesson74_yandexmap/services/location_service.dart';
import 'package:lesson74_yandexmap/services/yandex_map_service.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isCurLocTaped = false;
  bool isPolyninesTap = false;
  bool isTapPlace = false;
  bool isNightMode = false;
  Point? selectedLocation;

  late YandexMapController mapController;

  List<MapObject>? polylines;

  Point? myCurrentLocation;

  Point tapedPace = const Point(
    latitude: 41.2856806,
    longitude: 69.2034646,
  );

  void onMapCreated(YandexMapController controller) {
    mapController = controller;
    mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: Point(
            latitude: 41.2856806,
            longitude: 69.2034646,
          ),
          zoom: 1,
        ),
      ),
    );
    setState(() {});
  }

  void onPositionChanged(
    CameraPosition position,
    CameraUpdateReason reason,
    bool finished,
  ) async {
    myCurrentLocation = position.target;

    if (finished) {
      await LocationService.getCurrentLcoation();
      myCurrentLocation = Point(
        latitude: LocationService.currentLocation!.latitude!,
        longitude: LocationService.currentLocation!.longitude!,
      );
    }

    setState(() {});
  }

  final _yourGoogleAPIKey = 'AIzaSyBEjfX9jrWudgRcWl2scld4R7s0LtlaQmQ';
  final _textController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            nightModeEnabled: isNightMode,
            onMapCreated: onMapCreated,
            onMapTap: (argument) async {
              isTapPlace = !isTapPlace;
              tapedPace = argument;
              if (isPolyninesTap) {
                isTapPlace = true;
                polylines = await YandexMapService.getDirection(
                  myCurrentLocation!,
                  tapedPace,
                );
              }
              setState(() {});
            },
            mapType: MapType.vector,
            mapObjects: [
              if (isTapPlace)
                PlacemarkMapObject(
                  mapId: const MapObjectId("najotTalim"),
                  point: tapedPace,
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      image: BitmapDescriptor.fromAssetImage(
                        "assets/route_start.png",
                      ),
                    ),
                  ),
                ),
              if (isCurLocTaped)
                PlacemarkMapObject(
                  mapId: const MapObjectId("myCurrentLocation"),
                  point: myCurrentLocation!,
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      image: BitmapDescriptor.fromAssetImage(
                        "assets/route_stop_by.png",
                      ),
                    ),
                  ),
                ),
              if (isPolyninesTap) ...?polylines,
            ],
          ),
          Positioned(
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
                child: GooglePlacesAutoCompleteTextFormField(
                  textEditingController: _textController,
                  googleAPIKey: _yourGoogleAPIKey,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Enter your address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  maxLines: 1,
                  overlayContainer: (child) => Material(
                    elevation: 1.0,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  ),
                  getPlaceDetailWithLatLng: (prediction) {
                    if ((prediction.lat != null) && prediction.lng != null) {
                      selectedLocation = Point(
                        latitude: double.parse(prediction.lat!),
                        longitude: double.parse(prediction.lng!),
                      );
                      setState(() {});
                      mapController.moveCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: selectedLocation!),
                        ),
                      );
                      tapedPace = selectedLocation!;
                      isTapPlace = true;
                    }
                  },
                  itmClick: (Prediction prediction) =>
                      _textController.text = prediction.description!,
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(1, -0.7),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // MyBottomSheet(isNightMode: isNightMode),
                  const SizedBox(height: 20),
                  FloatingActionButton(
                    onPressed: () async {
                      isPolyninesTap = !isPolyninesTap;
                      if (isPolyninesTap) {
                        polylines = await YandexMapService.getDirection(
                          myCurrentLocation!,
                          tapedPace,
                        );
                      }
                      setState(() {});
                    },
                    backgroundColor: Colors.white.withOpacity(0.85),
                    child: Icon(
                      CupertinoIcons.location_north_line_fill,
                      color: isPolyninesTap ? Colors.blue[800] : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(1, 0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      mapController.moveCamera(
                        CameraUpdate.zoomIn(),
                      );
                    },
                    backgroundColor: Colors.white.withOpacity(0.85),
                    child: const Icon(
                      CupertinoIcons.add,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    onPressed: () {
                      mapController.moveCamera(
                        CameraUpdate.zoomOut(),
                      );
                    },
                    backgroundColor: Colors.white.withOpacity(0.85),
                    child: const Icon(
                      CupertinoIcons.minus,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: FloatingActionButton(
          onPressed: () async {
            isCurLocTaped = !isCurLocTaped;
            await LocationService.getCurrentLcoation();
            myCurrentLocation = Point(
              latitude: LocationService.currentLocation!.latitude!,
              longitude: LocationService.currentLocation!.longitude!,
            );
            mapController.moveCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: myCurrentLocation!, zoom: 20),
              ),
            );
            setState(() {});
          },
          backgroundColor: Colors.white.withOpacity(0.85),
          child: Icon(
            CupertinoIcons.location_fill,
            color: isCurLocTaped ? Colors.blue[800] : Colors.black,
          ),
        ),
      ),
    );
  }
}

// class MyBottomSheet extends StatefulWidget {
//   bool isNightMode;
//   MyBottomSheet({super.key});

//   @override
//   State<MyBottomSheet> createState() => _MyBottomSheetState();
// }

// class _MyBottomSheetState extends State<MyBottomSheet> {
//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton(
//       onPressed: () {
//         showModalBottomSheet(
//           context: context,
//           builder: (context) => Container(
//             height: 500,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("Tugni holat"),
//                     Switch(
//                       value: widget.isNightMode,
//                       onChanged: (value) {
//                         widget.isNightMode = value;
//                         setState(() {});
//                       },
//                     )
//                   ],
//                 )
//               ],
//             ),
//           ),
//         );
//         ;
//       },
//       backgroundColor: Colors.white.withOpacity(0.85),
//       child: const Icon(
//         CupertinoIcons.map_fill,
//         color: Colors.black,
//       ),
//     );
//   }
// }
