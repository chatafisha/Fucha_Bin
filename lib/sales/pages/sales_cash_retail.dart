import 'package:flutter/material.dart';
import 'package:smartstock/core/components/add_sale_to_cart.dart';
import 'package:smartstock/core/pages/page_base.dart';
import 'package:smartstock/core/pages/sale_like.dart';
import 'package:smartstock/core/services/util.dart';
import 'package:smartstock/sales/components/create_customer_content.dart';
import 'package:smartstock/sales/models/cart.model.dart';
import 'package:smartstock/sales/services/customer.dart';
import 'package:smartstock/sales/services/products.dart';
import 'package:smartstock/sales/services/sales.dart';

class SalesCashRetail extends PageBase {
  final OnBackPage onBackPage;
  final TextEditingController searchTextController = TextEditingController();

  SalesCashRetail({Key? key, required this.onBackPage})
      : super(key: key, pageName: 'SalesCashRetail');

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SalesCashRetail> {
  @override
  Widget build(BuildContext context) {
    return SaleLikePage(
      wholesale: false,
      searchTextController: widget.searchTextController,
      title: 'Retail',
      backLink: '/sales/cash',
      onSubmitCart: onSubmitRetailSale,
      onBack: widget.onBackPage,
      customerLikeLabel: 'Select customer',
      onGetPrice: _getPrice,
      onAddToCartView: _onPrepareSalesAddToCartView(context),
      onCustomerLikeList: getCustomerFromCacheOrRemote,
      onCustomerLikeAddWidget: () => const CreateCustomerContent(),
      checkoutCompleteMessage: 'Checkout completed.',
      onGetProductsLike: getProductsFromCacheOrRemote,
    );
  }

  _onPrepareSalesAddToCartView(context) {
    return (product, onAddToCart) {
      return salesAddToCart(
        onGetPrice: _getPrice,
        cart: CartModel(product: product, quantity: 1),
        onAddToCart: onAddToCart,
        context: context,
      );
    };
  }

  dynamic _getPrice(product) => doubleOrZero(product['retailPrice']);
}
