import 'package:smartstock/core/helpers/functional.dart';
import 'package:smartstock/core/helpers/util.dart';
import 'package:smartstock/core/types/OnGetPrice.dart';
import 'package:smartstock/sales/models/cart.model.dart';

appendToCarts(CartModel cart, List<CartModel> carts) {
  var index = carts.indexWhere((x) => x.product['id'] == cart.product['id']);
  var updateOrAppend = ifDoElse((i) => i == -1, (i) {
    carts.add(cart);
    return carts;
  }, (i) {
    var old = carts[i];
    carts.removeAt(i);
    old.quantity = old.quantity + cart.quantity;
    carts.add(old);
    return carts;
  });
  var allCarts = updateOrAppend(index);
  allCarts.sort(
      (a, b) => '${a.product['product']}'.compareTo('${b.product['product']}'));
  return allCarts;
}

removeCart(String id, List<CartModel> carts) =>
    carts.where((element) => element.product['id'] != id).toList();

updateCartQuantity(String id, double quantity, List<CartModel> carts) =>
    carts.map((e) {
      if (e.product['id'] == id) {
        e.quantity = (e.quantity + quantity) > 1 ? (e.quantity + quantity) : 1;
      }
      return e;
    }).toList();

cartTotalAmount(List<CartModel> carts, OnGetPrice onGetPrice) => carts.fold(
    0, (dynamic t, element) => t + getProductPrice(element, onGetPrice));

getProductPrice(CartModel cart, OnGetPrice onGetPrice) =>
    (onGetPrice(cart.product) ??
        propertyOr('amount', (p0) => 0)(cart.product)) *
    cart.quantity;

double? getCartItemSubAmount(
    {double quantity = 0.0,
    required Map product,
    double totalDiscount = 0.0,
    int totalItems = 0,}) {
  dynamic amount = (quantity * product['retailPrice']);
  return amount - (totalDiscount/totalItems);
}

// double? getCartItemDiscount(discount, items) => discount / items;

List cartItems(List<CartModel> carts, dis, Map customer) {
  return carts.map((value) {
    var discount = doubleOrZero('$dis');
    return {
      "amount": getCartItemSubAmount(
          totalItems: carts.length,
          totalDiscount: discount,
          product: value.product,
          quantity: value.quantity ?? 0,),
      "product": value.product['product'],
      'customer': '${customer['displayName'] ?? customer['name'] ?? ''}',
      'customerObject': {
        "id": '${customer['id'] ?? '0'}',
        'displayName': '${customer['displayName'] ?? customer['name'] ?? ''}'
      },
      "quantity": value.quantity,
      "stock": value.product,
      "discount": (discount/carts.length)
    };
  }).toList();
}

Future<String> cartItemsToPrinterData(
    List<dynamic> carts, Map customer, onGetPrice,
    {date}) async {
  String data = '-------------------------------\n';
  data = "$data${date ?? DateTime.now()}\n";
  data = '$data-------------------------------\n';
  data = '$data To ---> ${customer['displayName'] ?? customer['name'] ?? ''}\n';
  double totalBill = 0.0;
  int sn = 1;
  for (var cart in carts) {
    var price = doubleOrZero(onGetPrice(cart));
    var p = cart['product'];
    var q = doubleOrZero(cart['quantity']);
    var t = q * price;
    totalBill += doubleOrZero(t);
    data = [
      data,
      '-------------------------------\n',
      '$sn. $p\n',
      '\t$q @ $price = TZS $t\n',
    ].join('');
    sn++;
  }
  data = [
    '$data\n',
    '--------------------------------\n',
    'Total Bill : $totalBill\n',
    '--------------------------------\n',
  ].join('');
  return data;
}
