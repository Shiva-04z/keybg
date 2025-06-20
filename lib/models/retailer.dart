class Retailer {
  String id;
  String shopName;
  String qrUrl;
  String phoneNumber;
  String email;

  Retailer({
    required this.id,
    required this.shopName,
    required this.qrUrl,
    required this.phoneNumber,
    required this.email,
  });

  factory Retailer.fromJson(Map<String, dynamic> json) => Retailer(
    id: json['id'] as String,
    shopName: json['shop_name'] as String,
    qrUrl: json['qr_url'] as String,
    phoneNumber: json['phone_number'] as String,
    email: json['email'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop_name': shopName,
    'qr_url': qrUrl,
    'phone_number': phoneNumber,
    'email': email,
  };

  Retailer copyWith({
    String? id,
    String? shopName,
    String? qrUrl,
    String? phoneNumber,
    String? email,
  }) {
    return Retailer(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      qrUrl: qrUrl ?? this.qrUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}
