import 'package:flutter/foundation.dart';
import 'package:smartstock/core/services/stocks.dart';
import 'package:smartstock/core/services/util.dart';

Future<List<dynamic>> getProductsFromCacheOrRemote(
    {skipLocal = false, stringLike = ''}) async {
  var stocks = await getStockFromCacheOrRemote(
    skipLocal: skipLocal,
    stringLike: stringLike,
  );
  return compute(_productsOnly, stocks);
}

Future<List<dynamic>> _productsOnly(stocks) async {
  return itOrEmptyArray(stocks).where((e) => e['saleable'] == true).toList();
}
