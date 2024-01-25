extension StringX on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullAndNotEmpty => this != null && this!.isNotEmpty;

  // Assets
  String get pngIconAsset => "assets/icons/$this.png";
  String get pngImageAsset => "assets/images/png/$this.png";
  String get svgIconAsset => "assets/icons/$this.svg";
  String get svgImageAsset => "assets/images/svg/$this.svg";

  String get capitalizeOnlyFirstLater =>
      "${this![0].toUpperCase()}${this!.substring(1)}";

  String reverse([String pattern = ""]) =>
      this?.split(pattern).reversed.join(pattern) ?? "";

  String assetProductType() {
    String value = '';
    switch (this) {
      case 'Regular Bag':
        return value = 'ic_bag';
      case 'Bag':
        return value = 'ic_bag';
      case 'bag':
        return value = 'ic_bag';
      case 'regular bag':
        return value = 'ic_bag';
      case 'regular Bag':
        value = 'ic_bag';
        break;
      case 'helmet':
        return value = 'ic_helmet';
      case 'Helmet':
        value = 'ic_helmet';
        break;
      default:
        value = 'ic_shirt';
        break;
    }

    return value;
  }
}
