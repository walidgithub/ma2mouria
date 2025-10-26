class InvoiceMembersModel {
  final String id;
  final String name;
  final double shareValue;

  InvoiceMembersModel({
    required this.id,
    required this.name,
    required this.shareValue,
  });

  factory InvoiceMembersModel.fromJson(Map<String, dynamic> json) {
    return InvoiceMembersModel(
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
