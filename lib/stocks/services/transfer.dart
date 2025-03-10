import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:smartstock/core/helpers/functional.dart';
import 'package:smartstock/core/helpers/util.dart';
import 'package:smartstock/core/services/cache_shop.dart';
import 'package:smartstock/core/services/cache_user.dart';
import 'package:smartstock/core/services/date.dart';
import 'package:smartstock/core/services/printer.dart';
import 'package:smartstock/stocks/services/api_transfer.dart';

Future<List<dynamic>> transfersGetRemote(String? startAt) async {
  var shop = await getActiveShop();
  List rTransfers = await productTransfersFindAPI(
      startAt: startAt ?? toSqlDate(DateTime.now()), shop: shop);
  // rTransfers = await compute(
  //     _filterAndSort, {"transfers": rTransfers, "query": stringLike});
  return rTransfers;
}

Future printPreviousReceiveTransfer(transfer) async {
  var getShopName = propertyOrNull('otherShop')??'';
  // var getBatchId = propertyOrNull('batchId');
  var getCarts = compose([itOrEmptyArray, propertyOrNull('items')]);
  String data = '-------------------------------\n';
  data = "$data${DateTime.now().toUtc()}\n";
  data = '$data-------------------------------\n';
  data = '${data}TRANSFER RECEIVED\n';
  data = '$data-------------------------------\n';
  data = '$data To ---> ${getShopName(transfer)}\n';
  double totalBill = 0.0;
  int sn = 1;
  for (var cart in getCarts(transfer)) {
    var price = propertyOr('purchase', (x) => 0)(cart);
    var p = cart['product'];
    var q = doubleOrZero(cart['quantity']);
    var t = q * price;
    totalBill += doubleOrZero(t);
    data = [
      data,
      '-------------------------------\n',
      '$sn. $p\n',
      '\t$q @ ${formatNumber(price)} = ${formatNumber(t)}\n',
    ].join('');
    sn++;
  }
  data = [
    '$data\n',
    '--------------------------------\n',
    'Total Bill : ${formatNumber(totalBill)}\n',
    '--------------------------------\n',
  ].join('');
  await posPrint(data: data);
}

Future printPreviousSendTransfer(transfer) async {
  // print(transfer);
  var getShopName = propertyOrNull('otherShop')??'';
  var getCarts = compose([itOrEmptyArray, propertyOrNull('items')]);
  String data = '-------------------------------\n';
  data = "$data${DateTime.now().toUtc()}\n";
  data = '$data-------------------------------\n';
  data = '${data}TRANSFER SENT\n';
  data = '$data-------------------------------\n';
  data = '$data To ---> ${getShopName(transfer)}\n';
  double totalBill = 0.0;
  int sn = 1;
  for (var cart in getCarts(transfer)) {
    var price = propertyOr('purchase', (x) => 0)(cart);
    var p = cart['product'];
    var q = doubleOrZero(cart['quantity']);
    var t = q * price;
    totalBill += doubleOrZero(t);
    data = [
      data,
      '-------------------------------\n',
      '$sn. $p\n',
      '\t$q @ ${formatNumber(price)} = ${formatNumber(t)}\n',
    ].join('');
    sn++;
  }
  data = [
    '$data\n',
    '--------------------------------\n',
    'Total Bill : ${formatNumber(totalBill)}\n',
    '--------------------------------\n',
  ].join('');
  await posPrint(data: data);
}

// Future _printTransferItems(
//     List<CartModel> carts, discount, Map customer, batchId) async {
//   var items = cartItems(carts, discount, false, customer);
//   var data = await cartItemsToPrinterData(
//       items, customer, (cart) => cart['stock']['purchase']);
//   await posPrint(data: data, qr: batchId);
// }

// Future<Map> _carts2Transfer(
//     List<CartModel> carts, shop2Name, batchId, shop1, type) async {
//   // var shop2 = await shopName2Shop(shop2Name);
//   var currentUser = await getLocalCurrentUser();
//   var t = '${cartTotalAmount(carts, (product) => product['purchase'])}';
//   var totalAmount = doubleOrZero(t);
//   return {
//     "date": DateTime.now().toIso8601String(),
//     "transferred_by": {"username": currentUser['username']},
//     // "note": ".",
//     // "batchId": batchId,
//     "amount": totalAmount,
//     "other_shop": shop2Name,
//     // "to_shop": {
//     //   "name": type == 'send' ? shop2['businessName'] : shop1['businessName'],
//     //   "projectId": type == 'send' ? shop2['projectId'] : shop1['projectId'],
//     //   "applicationId":
//     //       type == 'send' ? shop2['applicationId'] : shop1['applicationId'],
//     // },
//     // "from_shop": {
//     //   "name": type == 'send' ? shop1['businessName'] : shop2['businessName'],
//     //   "projectId": type == 'send' ? shop1['projectId'] : shop2['projectId'],
//     //   "applicationId":
//     //       type == 'send' ? shop1['applicationId'] : shop2['applicationId'],
//     // },
//     "items": carts.map((e) {
//       return {
//         "from_id": e.product['id'],
//         // "from_product": e.product['product'],
//         // "to_product": e.product['product'],
//         // "to_id": e.product['id'],
//         // "to_purchase": e.product['purchase'],
//         "purchase": doubleOrZero(e.product['purchase']),
//         // "to_retail": e.product['retailPrice'],
//         // "to_whole": e.product['wholesalePrice'],
//         "product": e.product['product'],
//         "quantity": doubleOrZero(e.quantity),
//       };
//     }).toList()
//   };
// }

Future transferSend(Map transfer) async {
  var shop = await getActiveShop();
  return await productTransferSendCreateAPI(transfer: transfer, shop: shop);
}

Future transferReceive(Map transfer) async {
  var shop = await getActiveShop();
  return await productTransferReceiveCreateAPI(transfer: transfer, shop: shop);
}

// Future Function(List<CartModel>, Map shopName, dynamic) prepareOnSubmitTransfer(
//         context, String type) =>
//     (List<CartModel> carts, Map shopName, discount) async {
//       if ('${shopName['businessName']}'.isEmpty) {
//         throw "Shop you transfer to/from required";
//       }
//       String batchId = generateUUID();
//       var shop = await getActiveShop();
//       // var url = '${shopFunctionsURL(shopToApp(shop))}/transfer/$type';
//       if (type == 'send') {
//         await _printTransferItems(carts, discount, shopName, generateUUID());
//       }
//       var transfer =
//           await _carts2Transfer(carts, shopName, batchId, shop, type);
//       // print(transfer);
//       var saveTransfer = ifDoElse(
//         (_) => type == 'send',
//         composeAsync([productTransferSendCreateAPI(transfer)]),
//         composeAsync([productTransferReceiveCreateAPI(transfer)]),
//       );
//       return saveTransfer(shop);
//       // var createTransfer = prepareCreateTransfer(transfer);
//       // return createTransfer(shop);
//       // await saveLocalSync(batchId, url, transfer);
//       // oneTimeLocalSyncs();
//     };

Future getOtherShopsNames({skipLocal = false, stringLike = ''}) async {
  var shop = await getActiveShop();
  var getBusinessName = propertyOr('businessName', (p0) => 'No Shop');
  var user = await getLocalCurrentUser();
  var getShops = compose([
    (shops) => shops
        .where((element) => element['name'] != getBusinessName(shop))
        .toList(),
    // (shops) {
    //   shops.add({'name': user['businessName'] ?? ''});
    //   return shops;
    // },
    (shops) => shops.map((e) => {...e, 'name': e['businessName']}).toList(),
    // (shops) => shops.map(getBusinessName).toList(),
    propertyOr('shops', (p0) => []),
  ]);
  return getShops(user);
}
