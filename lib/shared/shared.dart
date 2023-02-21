import 'package:intl/intl.dart';

class Shared {
  emailValidator(text) {
    if (text == null || text.isEmpty) {
      return 'Bu alan gereklidir';
    } else if (!(text.contains('@')) && text.isNotEmpty) {
      return "Geçerli bir e-posta girin.";
    }
    return null;
  }

  textValidator(text) {
    if (text == null || text?.isEmpty) {
      return 'Bu alan gereklidir';
    }
    return null;
  }

  numberFormatter(double? number) {
    if (number == null) return "0,0000";
    var formatter = NumberFormat('#,###.0000');
    var result = formatter.format(number);
    var pureNumber =
        result.substring(0, result.indexOf('.')).replaceAll(',', '.');
    var decimal = result.toString().substring(result.indexOf('.') + 1);
    if (pureNumber == "") pureNumber = "0";
    return "$pureNumber,$decimal";
  }

  prePareNumberForRequest(String number) {
    return number.replaceAll(".", "").replaceAll(",", ".");
  }
}
