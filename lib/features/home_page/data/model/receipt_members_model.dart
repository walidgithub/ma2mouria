class ReceiptMembersModel {
  final String id;
  final String name;
  final double shareValue;

  ReceiptMembersModel({
    required this.id,
    required this.name,
    required this.shareValue,
  });

  factory ReceiptMembersModel.fromJson(Map<String, dynamic> json) {
    return ReceiptMembersModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      shareValue: (json['share_value'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'share_value': shareValue,
    };
  }
}
