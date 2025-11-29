class UploadedImageModel {
  final String secureUrl;
  final String publicId;
  final int width;
  final int height;
  final String format;
  final int bytes;
  final String? folder;

  UploadedImageModel({
    required this.secureUrl,
    required this.publicId,
    required this.width,
    required this.height,
    required this.format,
    required this.bytes,
    this.folder,
  });

  factory UploadedImageModel.fromJson(Map<String, dynamic> json) {
    return UploadedImageModel(
      secureUrl: json['secure_url'] as String,
      publicId: json['public_id'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      format: json['format'] as String,
      bytes: json['bytes'] as int,
      folder: json['folder'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'secure_url': secureUrl,
      'public_id': publicId,
      'width': width,
      'height': height,
      'format': format,
      'bytes': bytes,
      'folder': folder,
    };
  }
}

