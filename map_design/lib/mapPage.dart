import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart' as lottie;

class mapPage extends StatefulWidget {
  const mapPage({Key? key}) : super(key: key);
  @override
  State<mapPage> createState() => _mapPageState();
}

class _mapPageState extends State<mapPage> {
  GoogleMapController? mapController;
  LocationData? currentLocation;
  LocationData? userLocation;
  Set<Marker> _markers = Set<Marker>();
  List<LatLng> locations = <LatLng>[];
  late LatLng lastLocation;
  var rand = Random();
  double fontDialog = 15.0;
  late BitmapDescriptor customIcon;
  bool loaded = false;


  @override
  initState() {
    super.initState();
    getCurrentLocation();
  }

  //Function to update the marker
  void _setMarker(LatLng point) {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
          markerId: MarkerId('user'), position: point, icon: customIcon));
    });
  }

  //Gets the current location of the user, updates the marker and the customIcon
  Future<Widget?> getCurrentLocation() async {
    Location location = Location();
    LocationData locationData = await location.getLocation();
    userLocation = locationData;
    currentLocation = userLocation;
    lastLocation =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
    //marker = Marker(markerId: MarkerId("user"),position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!));
    customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(1, 1)), 'lib/assets/icon.png');
    _setMarker(LatLng(currentLocation!.latitude!, currentLocation!.longitude!));
    setState(() {
      loaded = true;
    });
  }

  //Two outputs depending if the location is loaded or not
  @override
  Widget build(BuildContext context) {
    if (loaded) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 14),
              onMapCreated: (controller) {
                mapController = controller;
              },
              myLocationEnabled: false,
              markers: _markers,
            ),
            buttonsColumn()
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: lottie.LottieBuilder.asset('lib/assets/location_animation.json'),
        )
      );
    }
  }

  //Sign fucntion used for the random coordinates
  int sign(){
    int coin = rand.nextInt(100);
    if(coin<50){
      return -1;
    } else return 1;

  }

  //Column of buttonMaps
  Widget buttonsColumn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buttonMap(' Teleport me to somewhere  random', Colors.lightBlueAccent,
              true),
          SizedBox(
            height: 5,
          ),
          buttonMap('Bring me back home', Colors.purple, false),
          SizedBox(
            height: 2,
          ),
        ],
      ),
    );
  }

  //Creates the two buttons with each functionality. It also gives the random coordinates if the Random button is pressed
  Widget buttonMap(String text, Color color, bool randomLocation) {
    return SizedBox(
        height: 80,
        width: 220,
        child: Card(
            color: color,
            margin: const EdgeInsets.all(10),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              onTap: () {
                if (randomLocation) {
                  double long =
                      double.parse(rand.nextDouble().toStringAsFixed(9)) *
                          rand.nextInt(181) *
                          sign();
                  double lat =
                      double.parse(rand.nextDouble().toStringAsFixed(9)) *
                          rand.nextInt(91) *
                          sign();
                  LatLng newCoords = LatLng(lat, long);
                  locations.add(lastLocation);
                  lastLocation = newCoords;

                  mapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: newCoords, zoom: 14)));
                  _setMarker(newCoords);
                  dialogWindow();
                } else {
                  LatLng userCoords =
                      LatLng(userLocation!.latitude!, userLocation!.longitude!);
                  locations.add(lastLocation);
                  lastLocation = userCoords;

                  locations.add(userCoords);
                  mapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: userCoords, zoom: 14)));
                  _setMarker(userCoords);
                  dialogWindow();
                  debugPrint(locations.toString());
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: Text(
                    text,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  )),
                ],
              ),
            )));
  }


  dialogWindow() {
    return showDialog(context: context, builder: (_) => mySimpleDialog());
  }

  //Dialog with the visited locations and the closing overflowing button
  mySimpleDialog() {
    return Container(
        child: SimpleDialog(
      backgroundColor: Colors.grey.withOpacity(0.5),
      titlePadding: EdgeInsets.all(0),
      title: Center(
        child: Stack(clipBehavior: Clip.none, children: [
          dialogText(),
          Positioned(
              top: -15,
              right: -30,
              child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    debugPrint('ok');
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                        color: Colors.black, shape: BoxShape.circle),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ))),
        ]),
      ),
    ));
  }

  //List view with the different visited locations
  dialogText() {
    return Container(
        height: 300,
        width: 250,
        child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: locations.length,
            itemBuilder: (BuildContext context, int index) {
              Widget message = Column(
                children: [
                  Text(
                    'Latitude: ${locations[index].latitude.round()}',
                    style: TextStyle(color: Colors.white, fontSize: fontDialog),
                  ),
                  Text(
                    'Longitude: ${locations[index].longitude.round()}',
                    style: TextStyle(color: Colors.white, fontSize: fontDialog),
                  )
                ],
              );
              if (index == 0) {
                return Column(
                  children: [
                    Text(
                      'Current Location',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontDialog,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Latitude: ${lastLocation.latitude.round()}',
                      style:
                          TextStyle(color: Colors.white, fontSize: fontDialog),
                    ),
                    Text(
                      'Longitude: ${lastLocation.longitude.round()}',
                      style:
                          TextStyle(color: Colors.white, fontSize: fontDialog),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Previous Location',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontDialog,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Latitude: ${locations[index].latitude.round()}',
                      style:
                          TextStyle(color: Colors.white, fontSize: fontDialog),
                    ),
                    Text(
                      'Longitude: ${locations[index].longitude.round()}',
                      style:
                          TextStyle(color: Colors.white, fontSize: fontDialog),
                    )
                  ],
                );
              }
              return Container(
                height: 50,
                child: Center(
                    child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: message,
                )),
              );
            }));
  }
}
