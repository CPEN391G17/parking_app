import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/models/slider_model.dart';

void main() {
  test('slider model test', () async {
    final sliderModel = SliderModel();
    sliderModel.imagePath = 'imagePath';
    sliderModel.title = 'title';
    sliderModel.description = 'description';

    // check sliderModel
    expect(sliderModel.imagePath, 'imagePath');
    expect(sliderModel.title, 'title');
    expect(sliderModel.description, 'description');

    // modify sliderModel
    sliderModel.imagePath = 'newImagePath';
    sliderModel.title = 'newTitle';
    sliderModel.description = 'newDescription';

    // check modify sliderModel
    expect(sliderModel.imagePath, 'newImagePath');
    expect(sliderModel.title, 'newTitle');
    expect(sliderModel.description, 'newDescription');
  });
}
