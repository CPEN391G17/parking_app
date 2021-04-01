import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/models/placePredictions.dart';

void main() {
  test('placePredictions test', () async {
    final placePredictions = PlacePredictions();
    placePredictions.main_text = 'main_text';
    placePredictions.secondary_text = 'secondary_text';
    placePredictions.place_id = 'place_id';

    // check placePrediction
    expect(placePredictions.main_text, 'main_text');
    expect(placePredictions.secondary_text, 'secondary_text');
    expect(placePredictions.place_id, 'place_id');

    // modify placePrediction
    placePredictions.main_text = 'new_main_text';
    placePredictions.secondary_text = 'new_secondary_text';
    placePredictions.place_id = 'new_place_id';

    // check placePrediction
    expect(placePredictions.main_text, 'new_main_text');
    expect(placePredictions.secondary_text, 'new_secondary_text');
    expect(placePredictions.place_id, 'new_place_id');
  });
}
