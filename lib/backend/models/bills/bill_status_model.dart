class BillStatusModel {
  final String status;
  final String message;
  final BillStatusData? data;

  BillStatusModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory BillStatusModel.fromJson(Map<String, dynamic> json) =>
      BillStatusModel(
        status: json['status'] ?? '',
        message: json['message'] ?? '',
        data: json['data'] != null
            ? BillStatusData.fromJson(json['data'])
            : null,
      );
}

class BillStatusData {
  final String currency;
  final String type;
  final double amount;
  final double fee;
  final String txStatus; // 'successful' | 'failed' | 'pending'
  final String reference;
  final String country;
  final String provider;

  BillStatusData({
    required this.currency,
    required this.type,
    required this.amount,
    required this.fee,
    required this.txStatus,
    required this.reference,
    required this.country,
    required this.provider,
  });

  bool get isSuccessful => txStatus.toLowerCase() == 'successful';
  bool get isFailed => txStatus.toLowerCase() == 'failed';
  bool get isPending => !isSuccessful && !isFailed;

  factory BillStatusData.fromJson(Map<String, dynamic> json) =>
      BillStatusData(
        currency: json['currency'] ?? '',
        type: json['type'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        fee: (json['fee'] ?? 0).toDouble(),
        txStatus: json['tx_status'] ?? 'pending',
        reference: json['reference'] ?? '',
        country: json['country'] ?? '',
        provider: json['provider'] ?? '',
      );
}
