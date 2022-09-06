import 'package:smartstock/core/services/sync.dart';

import '../../core/services/cache_shop.dart';
import '../../core/services/cache_sync.dart';
import '../../core/services/cache_user.dart';
import '../../core/services/date.dart';
import '../../core/services/printer.dart';
import '../../core/services/security.dart';
import '../../core/services/util.dart';
import 'cart.dart';

Future<List> _carts2Sales(List carts, dis, wholesale, customer, cartId) async {
  var currentUser = await getLocalCurrentUser();
  var discount = int.tryParse('$dis') ?? 0;
  String stringDate = toSqlDate(DateTime.now());
  String stringTime = DateTime.now().toIso8601String();
  String channel = wholesale ? 'whole' : 'retail';
  return carts
      .map((value) => ({
            "amount": getCartItemSubAmount(
                totalItems: carts.length,
                totalDiscount: discount,
                product: value.product,
                quantity: value.quantity ?? 0,
                wholesale: wholesale),
            "discount": getCartItemDiscount(discount, carts.length),
            "quantity": wholesale
                ? (value.quantity ?? 0 * value.product['wholesaleQuantity'])
                : value.quantity,
            "product": value.product['product'],
            "category": value.product['category'] ?? 'general',
            "unit": value.product['unit'] ?? 'general',
            "channel": channel,
            "date": stringDate,
            // "time": stringTime,
            "timer": stringTime,
            "customer": customer,
            "customerObject": {'displayName': customer},
            "user": currentUser['username'] ?? 'null',
            "sellerObject": {
              "username": currentUser['username'] ?? '',
              "lastname": currentUser['lastname'] ?? '',
              "firstname": currentUser['firstname'] ?? '',
              "email": currentUser['email'] ?? ''
            },
            "stock": value.product,
            "cartId": cartId,
            "batch": generateUUID(),
            "stockId": value.product['id']
          }))
      .toList();
}

Future _printSaleItems(
    List carts, discount, customer, wholesale, batchId) async {
  var items = cartItems(carts, discount, wholesale, '$customer');
  var data = await cartItemsToPrinterData(items, '$customer', wholesale);
  await posPrint(data: data, qr: batchId);
}

Future onSubmitRetailSale(List carts, String customer, discount) async {
  String cartId = generateUUID();
  String batchId = generateUUID();
  var shop = await getActiveShop();
  var url = '${shopFunctionsURL(shopToApp(shop))}/sale/cash';
  await _printSaleItems(carts, discount, customer, false, cartId);
  var sales = await _carts2Sales(carts, discount, false, customer, cartId);
  await saveLocalSync(batchId, url, sales);
  oneTimeLocalSyncs();
}

Future onSubmitWholeSale(List carts, String customer, discount) async {
  if (customer == null || customer.isEmpty) throw "Customer required";
  String cartId = generateUUID();
  String batchId = generateUUID();
  var shop = await getActiveShop();
  var url = '${shopFunctionsURL(shopToApp(shop))}/sale/cash';
  await _printSaleItems(carts, discount, customer, true, cartId);
  var sales = await _carts2Sales(carts, discount, true, customer, cartId);
  await saveLocalSync(batchId, url, sales);
  oneTimeLocalSyncs();
}
