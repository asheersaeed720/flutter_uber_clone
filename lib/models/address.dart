class Address {
  String? placeFormattedAddress;
  String? placeName;
  String? placeId;
  String? latitude;
  String? longitude;
  Address({
    this.placeFormattedAddress,
    this.placeName,
    this.placeId,
    this.latitude,
    this.longitude,
  });

  @override
  String toString() {
    return 'Address(placeFormattedAddress: $placeFormattedAddress, placeName: $placeName, placeId: $placeId, latitude: $latitude, longitude: $longitude)';
  }
}
