import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/models/directionDetails.dart';

void main() {
  test('directionDetails test', () async {
    final directionDetails = DirectionDetails();
    directionDetails.distanceValue = 100;
    directionDetails.durationValue = 100;
    directionDetails.distanceText = 'distanceText';
    directionDetails.durationText = 'durationText';
    directionDetails.encodedPoints = 'encodedPoints';

    // check directionDetails
    expect(directionDetails.distanceValue, 100);
    expect(directionDetails.durationValue, 100);
    expect(directionDetails.distanceText, 'distanceText');
    expect(directionDetails.durationText, 'durationText');
    expect(directionDetails.encodedPoints, 'encodedPoints');

    // modify directionDetails
    directionDetails.distanceValue = 200;
    directionDetails.durationValue = 200;
    directionDetails.distanceText = 'newDistanceText';
    directionDetails.durationText = 'newDurationText';
    directionDetails.encodedPoints = 'newEncodedPoints';

    // check modify directionDetails
    expect(directionDetails.distanceValue, 200);
    expect(directionDetails.durationValue, 200);
    expect(directionDetails.distanceText, 'newDistanceText');
    expect(directionDetails.durationText, 'newDurationText');
    expect(directionDetails.encodedPoints, 'newEncodedPoints');
  });
}
