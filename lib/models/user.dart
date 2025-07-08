import 'package:keybg/models/emi.dart';
import 'package:keybg/models/features.dart';
import 'package:keybg/models/retailer.dart';

class User {
  String uniqueKey;
  String retailerId;
  Retailer retailer;
  String imei1;
  String imei2;
  dynamic location;
  String getRecentContacts;
  Features features;
  EMI emi;

  User({
    required this.uniqueKey,
    required this.retailerId,
    required this.retailer,
    required this.imei1,
    required this.imei2,
    required this.location,
    required this.getRecentContacts,
    required this.features,
    required this.emi,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    uniqueKey: json['unique_key'] as String? ?? '',
    retailerId: json['retailer_id'] as String? ?? '',
    retailer: Retailer.fromJson(
      Map<String, dynamic>.from(json['retailer'] ?? {}),
    ),
    imei1: json['imei1'] as String? ?? '',
    imei2: json['imei2'] as String? ?? '',
    location: json['location'],
    getRecentContacts: json['get_recent_contacts'] as String? ?? '',
    features: Features.fromJson(
      Map<String, dynamic>.from(json['features'] ?? {}),
    ),
    emi: EMI.fromJson(Map<String, dynamic>.from(json['emi'] ?? {})),
  );

  Map<String, dynamic> toJson() => {
    'unique_key': uniqueKey,
    'retailer_id': retailerId,
    'retailer': retailer.toJson(),
    'imei1': imei1,
    'imei2': imei2,
    'location': location,
    'get_recent_contacts': getRecentContacts,
    'features': features.toJson(),
    'emi': emi.toJson(),
  };

  User copyWith({
    String? uniqueKey,
    String? retailerId,
    Retailer? retailer,
    String? imei1,
    String? imei2,
    dynamic location,
    String? getRecentContacts,
    Features? features,
    EMI? emi,
  }) {
    return User(
      uniqueKey: uniqueKey ?? this.uniqueKey,
      retailerId: retailerId ?? this.retailerId,
      retailer: retailer ?? this.retailer,
      imei1: imei1 ?? this.imei1,
      imei2: imei2 ?? this.imei2,
      location: location ?? this.location,
      getRecentContacts: getRecentContacts ?? this.getRecentContacts,
      features: features ?? this.features,
      emi: emi ?? this.emi,
    );
  }
}
