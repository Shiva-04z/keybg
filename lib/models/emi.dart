import 'dart:ffi';

class EMI {
  String id;
  String uniqueKey;
  double totalAmount;
  double totalAmountLeft;
  String emiName;
  int emiLeft;
  double paymentAmount;
  DateTime dueDate;

  EMI({
    required this.id,
    required this.uniqueKey,
    required this.totalAmount,
    required this.totalAmountLeft,
    required this.emiName,
    required this.emiLeft,
    required this.paymentAmount,
    required this.dueDate,
  });

  factory EMI.fromJson(Map<String, dynamic> json) => EMI(
    id: json['id'] as String,
    uniqueKey: json['unique_key'] as String,
    totalAmount: (json['total_amount'] as num).toDouble(),
    totalAmountLeft: (json['total_amount_left'] as num).toDouble(),
    emiName: json['emi_name'] as String,
    emiLeft: json['emi_left'] as int,
    paymentAmount: (json['payment_amount'] as num).toDouble(),
    dueDate: DateTime.parse(json['due_date'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'unique_key': uniqueKey,
    'total_amount': totalAmount,
    'total_amount_left': totalAmountLeft,
    'emi_name': emiName,
    'emi_left': emiLeft,
    'payment_amount': paymentAmount,
    'due_date': dueDate.toIso8601String(),
  };

  EMI copyWith({
    String? id,
    String? uniqueKey,
    double? totalAmount,
    double? totalAmountLeft,
    String? emiName,
    int? emiLeft,
    double? paymentAmount,
    DateTime? dueDate,
  }) {
    return EMI(
      id: id ?? this.id,
      uniqueKey: uniqueKey ?? this.uniqueKey,
      totalAmount: totalAmount ?? this.totalAmount,
      totalAmountLeft: totalAmountLeft ?? this.totalAmountLeft,
      emiName: emiName ?? this.emiName,
      emiLeft: emiLeft ?? this.emiLeft,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
