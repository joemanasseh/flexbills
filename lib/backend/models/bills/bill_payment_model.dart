class BillPaymentModel {
  final String status;
  final String message;
  final BillPaymentData? data;

  BillPaymentModel({
    required this.status,
    required this.message,
    this.data,
  });

  bool get isSuccess => status == 'success';

  factory BillPaymentModel.fromJson(Map<String, dynamic> json) =>
      BillPaymentModel(
        status: json['status'] ?? '',
        message: json['message'] ?? '',
        data: json['data'] != null
            ? BillPaymentData.fromJson(json['data'])
            : null,
      );
}

class BillPaymentData {
  final String reference;
  final String flwRef;
  final String txRef;
  final double amount;
  final String network;

  BillPaymentData({
    required this.reference,
    required this.flwRef,
    required this.txRef,
    required this.amount,
    required this.network,
  });

  factory BillPaymentData.fromJson(Map<String, dynamic> json) =>
      BillPaymentData(
        reference: json['reference'] ?? json['order_ref'] ?? '',
        flwRef: json['flw_ref'] ?? '',
        txRef: json['tx_ref'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        network: json['network'] ?? '',
      );
}
