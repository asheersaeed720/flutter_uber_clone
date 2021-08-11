import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_uber_clone/models/address.dart';
import 'package:flutter_uber_clone/models/place_prediction.dart';
import 'package:flutter_uber_clone/providers/assistant_provider.dart';
import 'package:flutter_uber_clone/services/assistant_service.dart';
import 'package:flutter_uber_clone/utils/secret.dart';
import 'package:flutter_uber_clone/widgets/divider_widget.dart';

AssistantService _assistantService = AssistantService();

class SearchScreen extends StatefulWidget {
  static const String routeName = '/search';

  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();

  List<PlacePrediction> placePredictionList = [];

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=${Secret.mapKey}&sessiontoken=1234567890&components=country:pk';

      var res = await _assistantService.getRequest(autoCompleteUrl);
      if (res == 'failed') {
        return;
      }
      if (res['status'] == 'OK') {
        var predictions = res['predictions'];
        var placeList = (predictions as List).map((e) => PlacePrediction.fromJson(e)).toList();
        setState(() {
          placePredictionList = placeList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String placeAddress = context.read(assitantProvider).pickUpLocation?.placeName ?? '';
    pickUpTextEditingController.text = placeAddress;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 215.0,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 25.0, top: 20.0, right: 25.0, bottom: 20.0),
                child: Column(
                  children: [
                    SizedBox(height: 5.0),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context);
                          },
                          child: Icon(Icons.arrow_back),
                        ),
                        Center(
                          child: Text(
                            'Set Drop Off',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/pickicon.png',
                          height: 16.8,
                          width: 16.8,
                        ),
                        SizedBox(height: 10.0),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[400], borderRadius: BorderRadius.circular(5.0)),
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: TextField(
                                controller: pickUpTextEditingController,
                                decoration: InputDecoration(
                                  hintText: 'Pickup Location',
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/desticon.png',
                          height: 16.8,
                          width: 16.8,
                        ),
                        SizedBox(height: 10.0),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[400], borderRadius: BorderRadius.circular(5.0)),
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: TextField(
                                controller: dropOffTextEditingController,
                                onChanged: (value) {
                                  findPlace(value);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Where to ?',
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.0),
            (placePredictionList.length > 0)
                ? Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListView.separated(
                        padding: EdgeInsets.all(0),
                        itemBuilder: (context, i) {
                          return PredictionTile(placePrediction: placePredictionList[i]);
                        },
                        separatorBuilder: (context, int index) => DividerWidget(),
                        itemCount: placePredictionList.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}

class PredictionTile extends StatefulWidget {
  final PlacePrediction placePrediction;

  const PredictionTile({Key? key, required this.placePrediction}) : super(key: key);

  @override
  _PredictionTileState createState() => _PredictionTileState();
}

class _PredictionTileState extends State<PredictionTile> {
  void getPlaceAddressDetails(
      BuildContext context, String placeId, AssistantProvider assitantPvd) async {
    String placeDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${Secret.mapKey}';

    var res = await _assistantService.getRequest(placeDetailsUrl);
    if (res == 'failed') {
      return;
    }
    if (res['status'] == 'OK') {
      log('$res', name: 'Predictions');
      Address address = Address();
      address.placeName = res['result']['name'];
      address.placeId = '$placeId';
      address.latitude = res['result']['geometry']['location']['lat'].toString();
      address.longitude = res['result']['geometry']['location']['lng'].toString();
      assitantPvd.updateDropOffLocationAddress(address);
      print('this is drop off location :: ${address.placeName}');
      Navigator.of(context).pop('obtainedDirection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, _) {
        final assitantPvd = watch(assitantProvider);
        return ListTile(
          onTap: () {
            getPlaceAddressDetails(context, '${widget.placePrediction.placeId}', assitantPvd);
          },
          leading: Icon(Icons.add_location, color: Colors.blueAccent),
          title: Text(
            '${widget.placePrediction.mainText}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16.0),
          ),
          subtitle: Text(
            '${widget.placePrediction.secondaryText}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
        );
        // return TextButton(
        //   onPressed: () {
        //     getPlaceAddressDetails(context, '${widget.placePrediction.placeId}', assitantPvd);
        //   },
        //   child: Container(
        //     child: Column(
        //       children: [
        //         const SizedBox(width: 10.0),
        //         Row(
        //           children: [
        //             Icon(Icons.add_location),
        //             SizedBox(width: 14.0),
        //             Expanded(
        //               child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Text(
        //                     '${widget.placePrediction.mainText}',
        //                     overflow: TextOverflow.ellipsis,
        //                     style: TextStyle(fontSize: 16.0),
        //                   ),
        //                   SizedBox(height: 8.0),
        //                   Text(
        //                     '${widget.placePrediction.secondaryText}',
        //                     overflow: TextOverflow.ellipsis,
        //                     style: TextStyle(fontSize: 12.0, color: Colors.grey),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ],
        //         ),
        //         const SizedBox(width: 10.0),
        //       ],
        //     ),
        //   ),
        // );
      },
    );
  }
}
