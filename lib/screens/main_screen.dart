import 'dart:async';
import 'dart:developer';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_uber_clone/models/address.dart';
import 'package:flutter_uber_clone/models/direction_detail.dart';
import 'package:flutter_uber_clone/models/directions_model.dart';
import 'package:flutter_uber_clone/providers/assistant_provider.dart';
import 'package:flutter_uber_clone/screens/search_screen.dart';
import 'package:flutter_uber_clone/widgets/divider_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';

  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _googleMapcontroller = Completer();
  GoogleMapController? _newGoogleMapController;

  var colorizeColors = [
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  var colorizeTextStyle = TextStyle(
    fontSize: 34.0,
    fontFamily: 'Poppins',
  );

  DirectionDetail? tripDirectionDetail;

  List<LatLng> pLineCoordinate = [];
  Set<Polyline> polyLineSet = {};

  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300.0;

  bool drawerOpen = true;

  DatabaseReference? _rideRequestRef;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      context.read(assitantProvider).getCurrentOnlineUserInfo();
    });
    super.initState();
  }

  void saveRideRequest() {
    _rideRequestRef = FirebaseDatabase.instance.reference().child('Ride Requests').push();
    var pickUp = context.read(assitantProvider).pickUpLocation;
    var dropOff = context.read(assitantProvider).dropOffLocation;
    Map pickUpLocation = {
      'latitude': pickUp?.latitude.toString(),
      'longitude': pickUp?.longitude.toString(),
    };
    Map dropOffLocation = {
      'latitude': dropOff?.latitude.toString(),
      'longitude': dropOff?.longitude.toString(),
    };

    Map rideInfoMap = {
      'driver_id': 'waiting',
      'payment_method': 'cash',
      'pickup': pickUpLocation,
      'dropoff': dropOffLocation,
      'created_at': DateTime.now().toString(),
      'rider_name': context.read(assitantProvider).userCurrentInfo.name,
      'rider_phone': context.read(assitantProvider).userCurrentInfo.mobileNo,
      'pickup_address': pickUp?.placeName,
      'dropoff_address': dropOff?.placeName,
    };
    _rideRequestRef?.set(rideInfoMap);
    // ?my work
    showRangAroundCurrentLocation(context.read(assitantProvider));
  }

  showRangAroundCurrentLocation(assistantPvd) async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPostion = position;
    LatLng _latlongPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: _latlongPosition, zoom: 14.4746);
    _newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await assistantPvd.searchCoordinateAddress(position);
    polyLineSet.clear();
    _markers.clear();
    // _circles.clear();
    print('your current address :: $address');
    _circles = Set.from([
      Circle(
        circleId: CircleId('pickUpId'),
        center: LatLng(position.latitude, position.longitude),
        strokeWidth: 1,
        fillColor: Colors.blueAccent.withOpacity(0.3),
        strokeColor: Colors.blueAccent.withOpacity(0.3),
        radius: 1000,
      )
    ]);
    setState(() {});
  }

  void cancelRideRequest() {
    _rideRequestRef?.remove();
  }

  void displayRequestRideContainer() {
    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });
    saveRideRequest();
  }

  resetApp(assistantPvd) {
    setState(() {
      searchContainerHeight = 300;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
      polyLineSet.clear();
      _markers.clear();
      _circles.clear();
      pLineCoordinate.clear();
    });
    locatePostion(assistantPvd);
  }

  void displayRideDetailContainer(assistantPvd) async {
    await getPlaceDirection(assistantPvd);
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });
  }

  // Directions? _info;

  Position? currentPostion;
  var geolocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  void locatePostion(AssistantProvider assistantPvd) async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPostion = position;
    LatLng _latlongPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: _latlongPosition, zoom: 14.4746);
    _newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await assistantPvd.searchCoordinateAddress(position);
    print('your current address :: $address');
    setState(() {});
  }

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // getDirection(AssistantProvider assistantPvd) async {
  //   final assistantPvd = context.read(assitantProvider);
  //   Address? initialPos = assistantPvd.pickUpLocation;
  //   Address? finalPos = assistantPvd.dropOffLocation;

  //   var pickUpLatLng =
  //       LatLng(double.parse('${initialPos?.latitude}'), double.parse('${initialPos?.longitude}'));
  //   var dropOffLatLng =
  //       LatLng(double.parse('${finalPos?.latitude}'), double.parse('${finalPos?.longitude}'));
  //   final direction = await assistantPvd.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);
  //   setState(() {
  //     _info = direction;
  //   });
  //   log('$_info', name: 'info');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main'),
      ),
      // drawer: ,
      body: Stack(
        children: [
          Consumer(
            builder: (context, watch, _) {
              final assistantPvd = watch(assitantProvider);
              return GoogleMap(
                padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                mapType: MapType.normal,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                initialCameraPosition: _kGooglePlex,
                polylines: polyLineSet,
                markers: _markers,
                circles: _circles,
                // polylines: {
                //   if (_info != null)
                //     Polyline(
                //       polylineId: const PolylineId('overview_polyline'),
                //       color: Colors.red,
                //       width: 5,
                //       points: _info!.polylinePoints
                //           .map((e) => LatLng(e.latitude, e.longitude))
                //           .toList(),
                //     ),
                // },
                onMapCreated: (GoogleMapController controller) {
                  _googleMapcontroller.complete(controller);
                  _newGoogleMapController = controller;
                  setState(() {
                    bottomPaddingOfMap = 280.0;
                  });
                  locatePostion(assistantPvd);
                },
              );
            },
          ),
          Positioned(
            top: 32.0,
            left: 32.0,
            // right: 50.0,
            child: Consumer(builder: (context, watch, _) {
              final assistantPvd = watch(assitantProvider);
              return GestureDetector(
                onTap: () {
                  if (!drawerOpen) {
                    resetApp(assistantPvd);
                  }
                },
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              );
            }),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0),
                      Text('Hi There,', style: TextStyle(fontSize: 12.0)),
                      Text('Where to?,', style: TextStyle(fontSize: 20.0)),
                      SizedBox(height: 28.0),
                      Consumer(builder: (context, watch, _) {
                        final assistantPvd = watch(assitantProvider);
                        return GestureDetector(
                          onTap: () async {
                            var res = await Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return SearchScreen();
                            }));
                            if (res == 'obtainedDirection') {
                              displayRideDetailContainer(assistantPvd);
                              // await getPlaceDirection(assistantPvd);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: Colors.blueAccent),
                                  SizedBox(width: 10.0),
                                  Text('Search Drop OFF'),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: 24.0),
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.grey),
                          SizedBox(width: 12.0),
                          Consumer(
                            builder: (context, watch, _) {
                              final assistantPvd = watch(assitantProvider);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      assistantPvd.pickUpLocation != null
                                          ? '${assistantPvd.pickUpLocation?.placeName}'
                                          : 'Add Home',
                                      overflow: TextOverflow.ellipsis,
                                      // maxLines: 1,
                                      softWrap: false,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Your living home address',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      DividerWidget(),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Icon(Icons.work, color: Colors.grey),
                          SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Work'),
                              SizedBox(height: 4.0),
                              Text(
                                'Your office address',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/taxi.png',
                                height: 70.0,
                                width: 80.0,
                              ),
                              SizedBox(width: 16.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Car', style: TextStyle(fontSize: 18.0)),
                                  Text(
                                      (tripDirectionDetail != null)
                                          ? '${tripDirectionDetail?.distanceText}'
                                          : '',
                                      style: TextStyle(fontSize: 16.0, color: Colors.grey)),
                                ],
                              ),
                              Expanded(child: Container()),
                              Consumer(
                                builder: (context, watch, _) {
                                  final assistantPvd = watch(assitantProvider);
                                  return Text(
                                    (tripDirectionDetail != null)
                                        ? 'Pkr ${assistantPvd.calculateFares(tripDirectionDetail!)}'
                                        : '',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.moneyCheckAlt,
                              size: 18.0,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 10.0),
                            Text('Cash'),
                            const SizedBox(width: 6.0),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                              size: 16.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Request',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  FontAwesomeIcons.taxi,
                                  color: Colors.white,
                                  size: 26.0,
                                )
                              ],
                            ),
                          ),
                          onPressed: () {
                            displayRequestRideContainer();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: requestRideContainerHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.5,
                    blurRadius: 16.0,
                    color: Colors.black54,
                    offset: Offset(0.7, 0.7),
                  )
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 18.0),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedTextKit(
                      onTap: () {
                        print("Tap Event");
                      },
                      isRepeatingAnimation: true,
                      animatedTexts: [
                        ColorizeAnimatedText(
                          'Requesting a ride',
                          textStyle: colorizeTextStyle,
                          colors: colorizeColors,
                          textAlign: TextAlign.center,
                        ),
                        ColorizeAnimatedText(
                          'Please wait...',
                          textStyle: colorizeTextStyle,
                          colors: colorizeColors,
                          textAlign: TextAlign.center,
                        ),
                        ColorizeAnimatedText(
                          'Finding a driver',
                          textStyle: colorizeTextStyle,
                          colors: colorizeColors,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22.0),
                  LinearProgressIndicator(),
                  SizedBox(height: 22.0),
                  Consumer(
                    builder: (context, watch, _) {
                      return GestureDetector(
                        onTap: () {
                          cancelRideRequest();
                          resetApp(watch(assitantProvider));
                        },
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28.0),
                            border: Border.all(width: 2.0, color: Colors.grey),
                          ),
                          child: Icon(Icons.close, size: 26.0),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    width: double.infinity,
                    child: Text('Cancel Ride', textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getPlaceDirection(AssistantProvider assistantPvd) async {
    Address? initialPos = assistantPvd.pickUpLocation;
    Address? finalPos = assistantPvd.dropOffLocation;

    var pickUpLatLng =
        LatLng(double.parse('${initialPos?.latitude}'), double.parse('${initialPos?.longitude}'));
    var dropOffLatLng =
        LatLng(double.parse('${finalPos?.latitude}'), double.parse('${finalPos?.longitude}'));

    var details = await assistantPvd.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetail = details;
    });

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline('${details.encodedPoints}');
    pLineCoordinate.clear();
    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinate.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId('PolylineID'),
        points: pLineCoordinate,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    // to fix route

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.latitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
        northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
      );
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
        northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
      );
    } else {
      latLngBounds = LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    _newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: initialPos?.placeName, snippet: 'My Location'),
      position: pickUpLatLng,
      markerId: MarkerId('pickUpId'),
    );

    Marker dropOffLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: finalPos?.placeName, snippet: 'Drop Off Location'),
      position: dropOffLatLng,
      markerId: MarkerId('dropOffId'),
    );

    setState(() {
      _markers.add(pickUpLocationMarker);
      _markers.add(dropOffLocationMarker);
    });

    Circle pickUpCircle = Circle(
      circleId: CircleId('pickUpId'),
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12.0,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
    );

    Circle dropOffCircle = Circle(
      circleId: CircleId('dropOffId'),
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12.0,
      strokeWidth: 4,
      strokeColor: Colors.purple,
    );

    setState(() {
      _circles.add(pickUpCircle);
      _circles.add(dropOffCircle);
    });
  }
}
