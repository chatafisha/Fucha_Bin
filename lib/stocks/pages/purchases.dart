import 'package:flutter/material.dart';
import 'package:smartstock/app.dart';
import 'package:smartstock/core/components/dialog_or_bottom_sheet.dart';
import 'package:smartstock/core/components/responsive_body.dart';
import 'package:smartstock/core/components/table_context_menu.dart';
import 'package:smartstock/core/components/table_like_list.dart';
import 'package:smartstock/core/components/stock_app_bar.dart';
import 'package:smartstock/core/models/menu.dart';
import 'package:smartstock/core/services/util.dart';
import 'package:smartstock/stocks/components/purchase_details.dart';
import 'package:smartstock/stocks/services/purchase.dart';

class PurchasesPage extends StatefulWidget {
  final args;

  const PurchasesPage(this.args, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PurchasesPage();
}

class _PurchasesPage extends State<PurchasesPage> {
  bool _loading = false;
  String _query = '';
  List? _purchases = [];

  _appBar(context) => StockAppBar(
      title: "Purchases",
      showBack: true,
      backLink: '/stock/',
      showSearch: true,
      onSearch: (d) {
        setState(() {
          _query = d;
        });
        _refresh(skip: false);
      },
      searchHint: 'Search...', context: context);

  _contextPurchases(context) => [
        ContextMenu(
          name: 'Create',
          pressed: () => navigateTo('/stock/purchases/create'),
        ),
        ContextMenu(name: 'Reload', pressed: () => _refresh(skip: true))
      ];

  _tableHeader() => SizedBox(
        height: 38,
        child: tableLikeListRow([
          tableLikeListTextHeader('Reference'),
          tableLikeListTextHeader('Type'),
          tableLikeListTextHeader('Cost ( TZS )'),
          tableLikeListTextHeader('Paid ( TZS )'),
        ]),
      );

  _fields() => ['refNumber', 'type', 'amount', 'payments'];

  _loadingView(bool show) =>
      show ? const LinearProgressIndicator(minHeight: 4) : Container();

  @override
  void initState() {
    _refresh();
    super.initState();
  }

  @override
  Widget build(context) => ResponsivePage(
        menus: moduleMenus(),
        current: '/stock/',
        sliverAppBar: _appBar(context),
        onBody: (d) => Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tableContextMenu(_contextPurchases(context)),
              _loadingView(_loading),
              _tableHeader(),
              Expanded(
                child: TableLikeList(
                    onFuture: () async => _purchases,
                    keys: _fields(),
                    onCell: (a, b, c) {
                      // if (a == 'refNumber') {
                      //   return Text('${c['type']} : ${c['refNumber']}');
                      // }
                      if (a == 'payments' && c['type'] == 'cash') {
                        return Text('${c['amount']}');
                      }
                      if (a == 'payments' && c['type'] == 'receipt') {
                        return Text('${c['amount']}');
                      }
                      if (a == 'payments' && c['type'] == 'invoice') {
                        return Text('${_getInvPayment(b)}');
                      }
                      return Text('$b');
                    },
                    onItemPressed: (item) => showDialogOrModalSheet(
                        purchaseDetails(context, item), context)),
              ), // _tableFooter()
            ],
          ),
        ),
      );

  _refresh({skip = false}) {
    setState(() {
      _loading = true;
    });
    getPurchaseFromCacheOrRemote(
      stringLike: _query,
      skipLocal: widget.args.queryParams.containsKey('reload') || skip,
    ).then((value) {
      setState(() {
        _purchases = value;
      });
    }).whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getInvPayment(b) {
    if (b is List) {
      return b.fold(
          0, (dynamic a, element) => a + doubleOrZero('${element['amount']}'));
    }
    return 0;
  }
}
