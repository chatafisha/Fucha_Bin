import 'package:bfast/util.dart';
import 'package:flutter/material.dart';
import 'package:smartstock_pos/stocks/services/api_suppliers.dart';
import 'package:smartstock_pos/stocks/states/product_create.dart';

import '../../core/services/cache_shop.dart';
import '../../core/services/util.dart';

class SupplierCreateState extends ChangeNotifier {
  var supplier = {};
  var err = {};
  var createProgress = false;
  var requestError = '';

  updateState(Map<String, String> map) {
    supplier.addAll(map);
  }

  _validateName() {
    var isString = ifDoElse((x) => x, (x) => x, (x) {
      err['name'] = 'Name required';
      return x;
    });
    return isString(
        supplier['name'] is String && '${supplier['name']}'.isNotEmpty);
  }

  _validSupplier() => and([_validateName]);

  create(context) async {
    err = {};
    requestError = '';
    createProgress = true;
    notifyListeners();
    var shop = await getActiveShop();
    var createIFValid = ifDoElse(
      (_) => _validSupplier(),
      createSupplier({...supplier, 'id': '${supplier['name']}'.toLowerCase()}),
      (_) async => 'nope',
    );
    createIFValid(shop).then((r) {
      if (r == 'nope') return;
      var productFormState = getState<ProductFormState>();
      productFormState.product['supplier'] = supplier['name'];
      productFormState.refresh();
      navigator().maybePop();
    }).catchError((err) {
      requestError = '$err, Please try again';
    }).whenComplete(() {
      createProgress = false;
      notifyListeners();
      // getSupplierFromCacheOrRemote(skipLocal: true);
    });
  }
}
