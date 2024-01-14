import 'package:flutter/widgets.dart';
import 'package:smartstock/core/pages/page_base.dart';
import 'package:smartstock/core/pages/sale_like.dart';
import 'package:smartstock/core/services/stocks.dart';
import 'package:smartstock/core/helpers/util.dart';
import 'package:smartstock/sales/models/cart.model.dart';
import 'package:smartstock/stocks/components/add_purchase_to_cart.dart';
import 'package:smartstock/stocks/components/create_supplier_content.dart';
import 'package:smartstock/stocks/services/purchase.dart';
import 'package:smartstock/stocks/services/supplier.dart';

class PurchaseCreatePage extends PageBase {
  final OnBackPage onBackPage;

  const PurchaseCreatePage({
    Key? key,
    required this.onBackPage,
  }) : super(key: key, pageName: 'PurchaseCreatePage');

  @override
  State<StatefulWidget> createState() => _State();

}


class _State extends State<PurchaseCreatePage>{
  @override
  Widget build(BuildContext context) => SaleLikePage(
      wholesale: false,
      showDiscountView: false,
      title: 'Create purchase',
      backLink: '/stock/purchases',
      onBack: widget.onBackPage,
      customerLikeLabel: 'Choose supplier',
      onSubmitCart: prepareOnSubmitPurchase(context),
      onGetPrice: (product) {
        return doubleOrZero('${product['purchase']}');
      },
      onAddToCartView: _onPrepareSalesAddToCartView(context, false),
      onCustomerLikeList: getSupplierFromCacheOrRemote,
      onCustomerLikeAddWidget: () => const CreateSupplierContent(),
      checkoutCompleteMessage: 'Purchase complete.',
      onGetProductsLike: getStockFromCacheOrRemote);

  _onPrepareSalesAddToCartView(context, wholesale) => (product, onAddToCart) {
    addPurchaseToCartView(
        onGetPrice: (product) {
          return doubleOrZero('${product['purchase']}');
        },
        cart: CartModel(product: product, quantity: 1),
        onAddToCart: onAddToCart,
        context: context);
  };
}