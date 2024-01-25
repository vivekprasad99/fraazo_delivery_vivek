extension NumX on num? {
  String trimTo2Digits() {
    if (this != null) {
      final int number = this!.truncate();
      if (this == number) {
        return number.toString();
      }
      return this!.toStringAsFixed(2);
    } else {
      return "0";
    }
  }
}
