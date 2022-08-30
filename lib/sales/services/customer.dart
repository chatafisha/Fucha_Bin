import 'package:bfast/util.dart';
import 'package:flutter/foundation.dart';

import '../../core/services/cache_shop.dart';
import '../../core/services/util.dart';
import 'api_customer.dart';
import 'customer_cache.dart';

Future<List<dynamic>> getCustomerFromCacheOrRemote({
  skipLocal = false,
  stringLike = '',
}) async {
  var shop = await getActiveShop();
  var customers = skipLocal ? [] : await getLocalCustomers(shopToApp(shop));
  var getItOrRemoteAndSave = ifDoElse(
    (x) => x == null || (x is List && x.isEmpty),
    (_) async {
      List rCustomers = await getAllRemoteCustomers(shop);
      rCustomers = await compute(
          _filterAndSort, {"customers": rCustomers, "query": stringLike});
      await saveLocalCustomers(shopToApp(shop), rCustomers);
      return rCustomers;
    },
    (x) => compute(_filterAndSort, {"customers": x, "query": stringLike}),
  );
  return getItOrRemoteAndSave(customers);
}

Future<List> _filterAndSort(Map data) async {
  var customers = data['customers'];
  String stringLike = data['query'];
  print(stringLike);
  _where(x) =>
      '${x['displayName']}'.toLowerCase().contains(stringLike.toLowerCase());

  customers = customers.where(_where).toList();
  customers.sort((a, b) => '${a['displayName']}'
      .toLowerCase()
      .compareTo('${b['displayName']}'.toLowerCase()));
  return customers;
}
