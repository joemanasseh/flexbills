
import 'package:intl/intl.dart';

import '../backend/services/api_endpoint.dart';
import '../utils/basic_widget_imports.dart';

// ─── Cached en_US formatters ──────────────────────────────────────────────────
// Constructed once at startup. 'en_US' locale pins the grouping separator to
// a comma and the decimal separator to a dot, regardless of the device locale.
final _fiatFmt   = NumberFormat('#,##0.00', 'en_US');
final _cryptoFmt = NumberFormat('#,##0.000000', 'en_US');
final _wholeFmt  = NumberFormat('#,##0', 'en_US');

extension DoubleFormatting on double {
  /// FIAT display — exactly 2 dp with Western comma grouping: 1,234,567.89
  String toFiatString() => _fiatFmt.format(this);

  /// Crypto display — exactly 6 dp with Western comma grouping: 0.123456
  String toCryptoString() => _cryptoFmt.format(this);

  /// Whole-number display with grouping: 1,234,567
  String toWholeString() => _wholeFmt.format(this);

  /// General-purpose display with [decimals] dp and Western comma grouping.
  /// Covers the common `currencyType == "FIAT" ? 2 : 6` branching pattern.
  String toFormattedCurrency([int decimals = 2]) {
    if (decimals == 2) return _fiatFmt.format(this);
    if (decimals == 0) return _wholeFmt.format(this);
    if (decimals == 6) return _cryptoFmt.format(this);
    return NumberFormat('#,##0.${'0' * decimals}', 'en_US').format(this);
  }

  /// Exchange-rate display with configurable precision (default 4 dp).
  /// Same grouping rules as the other helpers.
  String toRateString([int decimals = 4]) {
    if (decimals == 2) return _fiatFmt.format(this);
    return NumberFormat('#,##0.${'0' * decimals}', 'en_US').format(this);
  }
}

extension NumberParsing on String {
  int parseInt() {
    return int.parse(this);
  }


  double parseDouble() {
    return double.parse(this);
  }
  get toDouble => double.parse(this);
}

extension EndPointExtensions on String {
  String addBaseURl() {
    return ApiEndpoint.baseUrl + this;
  }

  double parseDouble() {
    return double.parse(this);
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}



/// Parses [value] and formats it with Western comma grouping.
/// Falls back to 0.0 on any parse failure — safe for raw API strings.
String makeBalance(String value, [int end = 2]) {
  return (double.tryParse(value) ?? 0.0).toFormattedCurrency(end);
}

/// Multiplies two string numbers and formats the result.
String makeMultiplyBalance(String value1, String value2, [int end = 2]) {
  final result =
      (double.tryParse(value1) ?? 0.0) * (double.tryParse(value2) ?? 0.0);
  return result.toFormattedCurrency(end);
}


Map<String, dynamic> getDate(String dateString){
  DateTime dateTime = DateTime.parse(dateString);

  int day = dateTime.day;
  String month = _getMonthName(dateTime.month);
  int year = dateTime.year;

  debugPrint("day = $day, month = $month, year = $year");
  return {
    "day": day,
    "month": month,
    "year": year
  };
}

String _getMonthName(int month) {
  switch (month) {
    case 1:
      return "January";
    case 2:
      return "February";
    case 3:
      return "March";
    case 4:
      return "April";
    case 5:
      return "May";
    case 6:
      return "June";
    case 7:
      return "July";
    case 8:
      return "August";
    case 9:
      return "September";
    case 10:
      return "October";
    case 11:
      return "November";
    case 12:
      return "December";
    default:
      return "";
  }
}