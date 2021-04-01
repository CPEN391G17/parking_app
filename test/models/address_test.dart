import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/models/address.dart';

void main() {
  test('address test', () async {
    final address = Address();
    address.placeFormattedAddress = 'placeFormattedAddress';
    address.placeName = 'placeName';
    address.placeId = 'placeId';

    // check address
    expect(address.placeFormattedAddress, 'placeFormattedAddress');    
    expect(address.placeName, 'placeName');
    expect(address.placeId, 'placeId');    

    // modify address
    address.placeFormattedAddress = 'newPlaceFormattedAddress';
    address.placeName = 'newPlaceName';
    address.placeId = 'newPlaceId';

    // check modify address
    expect(address.placeFormattedAddress, 'newPlaceFormattedAddress');    
    expect(address.placeName, 'newPlaceName');
    expect(address.placeId, 'newPlaceId');  
  });
}
