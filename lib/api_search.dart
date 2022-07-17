import 'package:openfoodfacts/openfoodfacts.dart';

class APISearch {
  static Future<Product?> searchBarcode(String barcode) async {
    ProductQueryConfiguration configuration = ProductQueryConfiguration(barcode,
        language: OpenFoodFactsLanguage.ENGLISH, fields: [ProductField.ALL]);

    try {
      ProductResult result = await OpenFoodAPIClient.getProduct(configuration);
      if (result.status == 1) {
        return result.product;
      } else {
        return null;
      }
    } on Exception catch (e) {
      // may be exceptions e.g. SocketException
      return null;
    }
  }
}
