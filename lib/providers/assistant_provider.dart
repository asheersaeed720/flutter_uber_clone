import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_uber_clone/models/address.dart';
import 'package:flutter_uber_clone/models/direction_detail.dart';
import 'package:flutter_uber_clone/providers/main_provider.dart';
import 'package:flutter_uber_clone/services/assistant_service.dart';
import 'package:flutter_uber_clone/utils/secret.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

class AssistantProvider extends MainProvider {
  AssistantService _assistantService = AssistantService();
  Address? pickUpLocation, dropOffLocation;

  Future<String> searchCoordinateAddress(Position position) async {
    String placeAddress = '';
    // String url =
    //     'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${Secret.mapKey}';
    String url =
        'https://api.opencagedata.com/geocode/v1/json?q=${position.latitude}+${position.longitude}&key=8f0fd77ebac640b7a3a03d3806b7b310';

    var response = await _assistantService.getRequest(url);

    if (response != 'failed') {
      log(response.toString(), name: 'locationRes');
      placeAddress = response['results'][0]['formatted'];
      Address userPickUpAddress = Address();
      userPickUpAddress.latitude = '${position.latitude}';
      userPickUpAddress.longitude = '${position.longitude}';
      userPickUpAddress.placeName = placeAddress;
      log('${userPickUpAddress.placeName}', name: 'formattedAddress');
      updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }

  // Future<Directions> obtainPlaceDirectionDetails(
  //     LatLng initialPostion, LatLng finalPosition) async {
  //   String directionUrl =
  //       'https://maps.googleapis.com/maps/api/directions/json?origin=24.9012,67.1155&destination=24.9324,67.0873&key=${Secret.mapKey}';

  //   var res = await http.get(Uri.parse(directionUrl));
  //   var jsonRes = jsonDecode(res.body);
  //   log('res: $jsonRes');
  //   return Directions.fromMap(jsonRes);
  // }

  Future<DirectionDetail> obtainPlaceDirectionDetails(
      LatLng initialPostion, LatLng finalPosition) async {
    String directionUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${initialPostion.latitude},${initialPostion.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=${Secret.mapKey}';

    var res = await _assistantService.getRequest(directionUrl);
    // if (res == 'failed') {
    //   return null;
    // }

    DirectionDetail directionDetail = DirectionDetail();
    if (res != 'failed') {
      log('$res', name: 'obtainedPlaceDirection');
      directionDetail.encodedPoints = res['routes'][0]['overview_polyline']['points'].toString();
      directionDetail.distanceText = res['routes'][0]['legs'][0]['distance']['text'].toString();
      directionDetail.distanceValue = res['routes'][0]['legs'][0]['distance']['value'].toString();
      directionDetail.durationText = res['routes'][0]['legs'][0]['duration']['text'].toString();
      directionDetail.durationValue = res['routes'][0]['legs'][0]['duration']['value'].toString();
    }
    return directionDetail;
  }
}

final assitantProvider = ChangeNotifierProvider((ref) => AssistantProvider());
