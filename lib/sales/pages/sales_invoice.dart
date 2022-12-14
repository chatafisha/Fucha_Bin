import 'package:bfast/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartstock/app.dart';
import 'package:smartstock/core/components/dialog_or_bottom_sheet.dart';
import 'package:smartstock/core/components/responsive_body.dart';
import 'package:smartstock/core/components/stock_app_bar.dart';
import 'package:smartstock/core/components/table_context_menu.dart';
import 'package:smartstock/core/components/table_like_list.dart';
import 'package:smartstock/core/models/menu.dart';
import 'package:smartstock/core/services/util.dart';
import 'package:smartstock/sales/components/sale_invoice_details.dart';
import 'package:smartstock/sales/services/invoice.dart';

class InvoicesPage extends StatefulWidget {
  final args;

  const InvoicesPage(this.args, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InvoicesPage();
}

class _InvoicesPage extends State<InvoicesPage> {
  bool _loading = false;
  String _query = '';
  int size = 20;
  List _invoices = [];

  _appBar(context) {
    return StockAppBar(
      title: "Invoices",
      showBack: true,
      backLink: '/sales/',
      showSearch: false,
      onSearch: (d) {
        setState(() {
          _query = d;
        });
        _refresh();
      },
      searchHint: 'Search by date...', context: context,
    );
  }

  _contextInvoices(context) {
    return [
      ContextMenu(
        name: 'Create',
        pressed: () => navigateTo('/sales/invoice/create'),
      ),
      ContextMenu(name: 'Reload', pressed: () => _refresh())
    ];
  }

  _tableHeader() {
    var height = 38.0;
    var smallView = SizedBox(
      height: height,
      child: tableLikeListRow([
        tableLikeListTextHeader('Date'),
        tableLikeListTextHeader('Amount ( TZS )'),
        tableLikeListTextHeader('Customer'),
      ]),
    );
    var largeView = SizedBox(
      height: height,
      child: tableLikeListRow([
        tableLikeListTextHeader('Date'),
        tableLikeListTextHeader('Amount ( TZS )'),
        tableLikeListTextHeader('Paid ( TZS )'),
        tableLikeListTextHeader('Customer'),
      ]),
    );
    return isSmallScreen(context) ? smallView : largeView;
  }

  _fields() => isSmallScreen(context)
      ? ['date', 'amount', 'customer']
      : ['date', 'amount', 'payment', 'customer'];

  _loadingView(bool show) =>
      show ? const LinearProgressIndicator(minHeight: 4) : Container();

  @override
  void initState() {
    _refresh();
    super.initState();
  }

  @override
  Widget build(context) {
    return ResponsivePage(
      menus: moduleMenus(),
      current: '/sales/',
      sliverAppBar: _appBar(context),
      onBody: (d) {
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              tableContextMenu(_contextInvoices(context)),
              _loadingView(_loading),
              _tableHeader(),
              Expanded(
                child: TableLikeList(
                  onFuture: () async => _invoices,
                  keys: _fields(),
                  onLoadMore: () async => _loadMore(),
                  loading: _loading,
                  onCell: (a, b, c) {
                    if (a == 'date') {
                      return _dateView(c);
                    }
                    if (a == 'customer') {
                      return Text('${b['displayName']}');
                    }
                    if (a == 'payment') {
                      return Text('${_getInvPayment(b)}');
                    }
                    return Text('$b');
                  },
                  onItemPressed: (item) {
                    showDialogOrModalSheet(
                      SaleInvoiceDetail(sale: item, pageContext: context),
                      context,
                    );
                    // showDialogOrModalSheet(
                    //   invoiceDetails(context, item),
                    //   context,
                    // );
                  },
                ),
              ), // _tableFooter()
            ],
          ),
        );
      },
    );
  }

  Widget _dateView(c) {
    // var date = DateTime.tryParse(c['timer']) ?? DateTime.now();
    // var textStyle = const TextStyle(
    //     fontWeight: FontWeight.w300,
    //     color: Colors.grey,
    //     height: 2.0,
    //     overflow: TextOverflow.ellipsis);
    var mainTextStyle = const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis);
    // var subText = timeago.format(date);
    //'${c['channel'] == 'whole' ? '| Wholesale' : '| Retail'}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_getTimer(c), style: mainTextStyle),
        // Text(subText, style: textStyle)
      ]),
    );
  }

  _getTimer(c) {
    var getTimer = propertyOr('timer', (p0) => '');
    var date = DateTime.tryParse(getTimer(c)) ?? DateTime.now();
    var dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return dateFormat.format(date);
  }

  // _refresh({skip = false}) {
  //   setState(() {
  //     _loading = true;
  //   });
  //   getInvoiceFromCacheOrRemote(
  //     stringLike: _query,
  //     skipLocal: widget.args.queryParams.containsKey('reload') || skip,
  //   ).then((value) {
  //     setState(() {
  //       _invoices = value;
  //     });
  //   }).whenComplete(() {
  //     setState(() {
  //       _loading = false;
  //     });
  //   });
  // }

  _getInvPayment(b) {
    if (b is Map) {
      return b.values
          .fold(0, (dynamic a, element) => a + doubleOrZero('$element'));
    }
    return 0;
  }

  _loadMore() {
    setState(() {
      _loading = true;
    });
    var getInvoices = _prepareGetInvoices(_query, size, true);
    getInvoices(_invoices).then((value) {
      if (value is List) {
        _invoices.addAll(value);
        _invoices = _invoices.toSet().toList();
        setState(() {});
      }
    }).whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  _prepareGetInvoices(String product, size, bool more) {
    return ifDoElse(
      (sales) => sales is List && sales.isNotEmpty,
      (sales) {
        var last = more ? sales.last['timer'] : _defaultLast();
        return getInvoiceSalesFromCacheOrRemote(last, size, product);
      },
      (sales) =>
          getInvoiceSalesFromCacheOrRemote(_defaultLast(), size, product),
    );
  }

  _refresh() {
    setState(() {
      _loading = true;
    });
    var getInvoices = _prepareGetInvoices(_query, size, false);
    getInvoices(_invoices).then((value) {
      if (value is List) {
        _invoices = value;
      }
    }).whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  _defaultLast() {
    var dF = DateFormat('yyyy-MM-ddTHH:mm');
    var date = DateTime.now().add(const Duration(days: 1));
    return dF.format(date);
  }
}
