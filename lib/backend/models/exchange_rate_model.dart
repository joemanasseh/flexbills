class ExchangeRateModel {
  final String baseCurrency;
  final String targetCurrency;
  final double allInclusiveRate;
  final String rateExpiresAt;

  ExchangeRateModel({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.allInclusiveRate,
    required this.rateExpiresAt,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) =>
      ExchangeRateModel(
        baseCurrency: json['base_currency'].toString(),
        targetCurrency: json['target_currency'].toString(),
        allInclusiveRate: double.parse(json['all_inclusive_rate'].toString()),
        rateExpiresAt: json['rate_expires_at'].toString(),
      );

  Map<String, dynamic> toJson() => {
        'base_currency': baseCurrency,
        'target_currency': targetCurrency,
        'all_inclusive_rate': allInclusiveRate,
        'rate_expires_at': rateExpiresAt,
      };

  // True when the quoted rate window has passed and must be re-fetched.
  bool get isExpired {
    try {
      return DateTime.parse(rateExpiresAt).isBefore(DateTime.now());
    } catch (_) {
      return true;
    }
  }
}
