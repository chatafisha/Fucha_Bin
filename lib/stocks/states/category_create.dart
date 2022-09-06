import 'package:bfast/util.dart';
import 'package:flutter/material.dart';
import 'package:smartstock/core/services/cache_shop.dart';
import 'package:smartstock/core/services/util.dart';
import 'package:smartstock/stocks/services/api_categories.dart';
import 'package:smartstock/stocks/states/categories_loading.dart';
import 'package:smartstock/stocks/states/product_create.dart';

class CategoryCreateState extends ChangeNotifier {
  var category = {};
  var err = {};
  var createProgress = false;
  var requestError = '';

  updateState(Map<String, String> map) {
    category.addAll(map);
  }

  _validateName() {
    var isString = ifDoElse((x) => x, (x) => x, (x) {
      err['name'] = 'Name required';
      return x;
    });
    return isString(
        category['name'] is String && '${category['name']}'.isNotEmpty);
  }

  _validCategory() => and([_validateName]);

  create(context) async {
    err = {};
    requestError = '';
    createProgress = true;
    notifyListeners();
    var shop = await getActiveShop();
    var createIFValid = ifDoElse(
      (_) => _validCategory(),
      createCategory({...category, 'id': '${category['name']}'.toLowerCase()}),
      (_) async => 'nope',
    );
    createIFValid(shop).then((r) {
      if (r == 'nope') return;
      var productFormState = getState<ProductCreateState>();
      productFormState.product['category'] = category['name'];
      productFormState.refresh();
      navigator().maybePop();
      getState<CategoriesLoadingState>().update(true);
    }).catchError((err) {
      requestError = '$err, Please try again';
    }).whenComplete(() {
      createProgress = false;
      notifyListeners();
      // getCategoryFromCacheOrRemote(skipLocal: true);
    });
  }
}
