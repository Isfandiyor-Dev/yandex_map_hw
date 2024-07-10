import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson74_yandexmap/services/location_service.dart';
import 'package:lesson74_yandexmap/services/yandex_map_service.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

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
