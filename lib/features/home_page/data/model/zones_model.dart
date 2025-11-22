class ZonesModel {
  final String zone;

  ZonesModel({
    required this.zone,
  });

  factory ZonesModel.fromJson(Map<String, dynamic> json) {
    return ZonesModel(
      zone: json['zone'] ?? 'zone',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zone': zone,
    };
  }
}
