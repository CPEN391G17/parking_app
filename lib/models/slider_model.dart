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
  sliderModel.setTitle("Slide 1");
  sliderModel.setDescription("Search destination");
  slides.add(sliderModel);

  sliderModel = new SliderModel();
  //2
  sliderModel.setImageAssetPath("assets/images/test.jpg");
  sliderModel.setTitle("Slide 2");
  sliderModel.setDescription("Book parking");
  slides.add(sliderModel);

  sliderModel = new SliderModel();
  //3
  sliderModel.setImageAssetPath("assets/images/test.jpg");
  sliderModel.setTitle("Slide 3");
  sliderModel.setDescription("Verify at parking");
  slides.add(sliderModel);

  return slides;
}