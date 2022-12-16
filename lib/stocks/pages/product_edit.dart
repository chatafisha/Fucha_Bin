import 'package:flutter/material.dart';
import 'package:smartstock/app.dart';
import 'package:smartstock/core/components/responsive_body.dart';
import 'package:smartstock/core/components/stock_app_bar.dart';
import 'package:smartstock/stocks/components/product_edit_form.dart';

class ProductEditPage extends StatelessWidget {
  final String productName;

  const ProductEditPage(this.productName, {Key? key}) : super(key: key);

  _appBar(context) {
    return StockAppBar(
      title: "Update $productName detail",
      showBack: true,
      backLink: '/stock/products',
      showSearch: false,
      context: context,
    );
  }

  @override
  Widget build(context) {
    return ResponsivePage(
      menus: moduleMenus(),
      current: '/stock/',
      sliverAppBar: _appBar(context),
      onBody: (d) => SingleChildScrollView(
        child: Center(
          child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: const ProductUpdateForm()),
        ),
      ),
    );
  }
}
