class SliderModel {
  String imagePath;
  String title;
  String description;

  SliderModel({this.imagePath, this.title, this.description});

  void setImageAssetPath(String getImagePath) {
    imagePath = getImagePath;
  }

  void setTitle(String getTitle) {
    title = getTitle;
  }

  void setDescription(String getDescription) {
    description = getDescription;
  }

  String getImageAssetPath() {
    return imagePath;
  }

  String getTitle() {
    return title;
  }

  String getDescription() {
    return description;
  }

}

List <SliderModel> getSlides() {
  List<SliderModel> slides = new List<SliderModel>();
  SliderModel sliderModel = new SliderModel();

  //1
  sliderModel.setImageAssetPath("assets/images/test.jpg");
  sliderModel.setTitle("Welcome to ParKing!");
  sliderModel.setDescription("A revolutionary pay to park service");
  slides.add(sliderModel);

  sliderModel = new SliderModel();
  //2
  sliderModel.setImageAssetPath("assets/images/test.jpg");
  sliderModel.setTitle("Pay using ParKoins");
  sliderModel.setDescription("Use ParKoins to park anywhere in Canada. Use License Plate Recognition, QR and BT to pay");
  slides.add(sliderModel);

  sliderModel = new SliderModel();
  //3
  sliderModel.setImageAssetPath("assets/images/test.jpg");
  sliderModel.setTitle("CPEN 391 Concept");
  sliderModel.setDescription("This has been made for CPEN 391 by Group#17.");
  slides.add(sliderModel);

  return slides;
}