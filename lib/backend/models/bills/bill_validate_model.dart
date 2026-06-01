class BillValidateModel {
  final String status;
  final String message;
  final BillValidateData? data;

  BillValidateModel({
    required this.status,
    required this.message,
    this.data,
  });

  bool get isSuccess => status == 'success' || status == '00';

  factory BillValidateModel.fromJson(Map<String, dynamic> json) =>
      BillValidateModel(
        status: json['status'] ?? '',
        message: json['message'] ?? '',
        data: json['data'] != null
            ? BillValidateData.fromJson(json['data'])
            : null,
      );
}

class BillValidateData {
  final String responseCode;
  final String address;
  final String responseMessage;
  final String name;
  final String billerCode;
  final String customer;

  BillValidateData({
    required this.responseCode,
    required this.address,
    required this.responseMessage,
    required this.name,
    required this.billerCode,
    required this.customer,
  });

  factory BillValidateData.fromJson(Map<String, dynamic> json) =>
      BillValidateData(
        responseCode: json['response_code'] ?? json['responseCode'] ?? '',
        address: json['address'] ?? '',
        responseMessage:
            json['response_message'] ?? json['responseMessage'] ?? '',
        name: json['name'] ?? '',
        billerCode: json['biller_code'] ?? json['billerCode'] ?? '',
        customer: json['customer'] ?? '',
      );
}
