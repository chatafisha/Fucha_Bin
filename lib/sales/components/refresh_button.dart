import 'package:flutter/material.dart';

import '../../core/services/util.dart';
import '../models/cart.model.dart';
import '../states/cart.dart';
import '../states/sales.dart';

Widget get salesRefreshButton => selectorComponent<SalesState, bool>(
      selector: (state) => state.loadProductsProgress,
      builder: (context, value) =>
          !value ? _addToCartOrRefreshIcon() : const SizedBox(width: 0,height: 0,),
    );

Widget _addToCartOrRefreshIcon() => selectorComponent<CartState, CartModel>(
      selector: (state) => state.currentCartModel,
      builder: (context, value) =>
      // value != null
      //     ? FloatingActionButton(
      //         child: const Icon(Icons.close),
      //         onPressed: () {
      //           getState<CartState>().setCurrentCartToBeAdded(null);
      //           Navigator.pop(context);
      //         },
      //       )
      //     :
      _refreshStocks(),
    );

Widget _refreshStocks() => selectorComponent<CartState, List>(
      selector: (state) => state.cartProductsArray,
      builder: (context, value) => value.isEmpty
          ? FloatingActionButton(
              child: const Icon(Icons.refresh),
              onPressed: () => getState<SalesState>().getStockFromRemote(),
            )
          : const SizedBox(height: 0,width: 0,),
    );
