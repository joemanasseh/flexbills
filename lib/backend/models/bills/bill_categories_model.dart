class BillCategoriesModel {
  final String status;
  final String message;
  final List<BillCategoryData> data;

  BillCategoriesModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BillCategoriesModel.fromJson(Map<String, dynamic> json) =>
      BillCategoriesModel(
        status: json['status'] ?? '',
        message: json['message'] ?? '',
        data: json['data'] != null
            ? List<BillCategoryData>.from(
                json['data'].map((x) => BillCategoryData.fromJson(x)))
            : [],
      );
}

class BillCategoryData {
  final String billerCode;
  final String name;
  final String country;
  final String itemCode;
  final String shortName;
  final double fee;
  final double amount;
  final String labelName;
  final bool isAirtime;

  BillCategoryData({
    required this.billerCode,
    required this.name,
    required this.country,
    required this.itemCode,
    required this.shortName,
    required this.fee,
    required this.amount,
    required this.labelName,
    required this.isAirtime,
  });

  bool get isVariableAmount => amount == 0;

  factory BillCategoryData.fromJson(Map<String, dynamic> json) =>
      BillCategoryData(
        billerCode: json['biller_code'] ?? '',
        name: json['name'] ?? '',
        country: json['country'] ?? '',
        itemCode: json['item_code'] ?? '',
        shortName: json['short_name'] ?? '',
        fee: (json['fee'] ?? 0).toDouble(),
        amount: (json['amount'] ?? 0).toDouble(),
        labelName: json['label_name'] ?? 'Customer ID',
        isAirtime: json['is_airtime'] ?? false,
      );
}
