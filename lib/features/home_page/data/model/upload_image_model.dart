class UploadedImageModel {
  final String url;
  final String name;
  final String mime;
  final int size;

  UploadedImageModel({
    required this.url,
    required this.name,
    required this.mime,
    required this.size,
  });

  factory UploadedImageModel.fromJson(Map<String, dynamic> json) {
    final imageData = json["image"];

    return UploadedImageModel(
      url: imageData["url"],
      name: imageData["name"],
      mime: imageData["mime"],
      size: imageData["size"],
    );
  }
}

