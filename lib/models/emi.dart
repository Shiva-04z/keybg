import 'dart:ffi';

class EMI {
  double totalAmount;
  double totalAmountLeft;
  String emiName;
  int emiLeft;
  double paymentAmount;
  DateTime dueDate;

  EMI({

    required this.totalAmount,
    required this.totalAmountLeft,
    required this.emiName,
    required this.emiLeft,
    required this.paymentAmount,
    required this.dueDate,
  });

  factory EMI.fromJson(Map<String, dynamic> json) {
    return EMI(
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmountLeft: (json['totalAmountLeft'] as num?)?.toDouble() ?? 0.0,
      emiName: json['emiName'] as String? ?? '',
      emiLeft: json['emiLeft'] as int? ?? 0,
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble() ?? 0.0,
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
    );
  }


  Map<String, dynamic> toJson() => {
    'total_amount': totalAmount,
    'total_amount_left': totalAmountLeft,
    'emi_name': emiName,
    'emi_left': emiLeft,
    'payment_amount': paymentAmount,
    'due_date': dueDate.toIso8601String(),
  };

  EMI copyWith({

    double? totalAmount,
    double? totalAmountLeft,
    String? emiName,
    int? emiLeft,
    double? paymentAmount,
    DateTime? dueDate,
  }) {
    return EMI(

      totalAmount: totalAmount ?? this.totalAmount,
      totalAmountLeft: totalAmountLeft ?? this.totalAmountLeft,
      emiName: emiName ?? this.emiName,
      emiLeft: emiLeft ?? this.emiLeft,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
