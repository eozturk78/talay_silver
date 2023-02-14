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
}
