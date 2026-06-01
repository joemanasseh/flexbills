// Maps a currency code to a reliable flagcdn.com URL.
// For most currencies, the first 2 chars of the code match the ISO country code.
String flagUrl(String currencyCode) {
  if (currencyCode.length < 2) return '';
  const overrides = <String, String>{
    'EUR': 'eu',
    'XAF': 'cm',
    'XOF': 'sn',
    'XCD': 'ag',
    'ANG': 'cw',
    'AWG': 'aw',
  };
  final cc = currencyCode.toUpperCase();
  final country = overrides[cc] ?? cc.substring(0, 2).toLowerCase();
  return 'https://flagcdn.com/w40/$country.png';
}
