class RulesModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String rule;

  RulesModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.rule,
  });

  factory RulesModel.fromJson(Map<String, dynamic> json) {
    return RulesModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      rule: json['rule'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'rule': rule,
    };
  }
}
