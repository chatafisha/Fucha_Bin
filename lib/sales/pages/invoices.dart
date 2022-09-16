import 'package:flutter/material.dart';
import 'package:smartstock/app.dart';
import 'package:smartstock/core/components/dialog_or_bottom_sheet.dart';
import 'package:smartstock/core/components/responsive_body.dart';
import 'package:smartstock/core/components/table_context_menu.dart';
import 'package:smartstock/core/components/table_like_list.dart';
import 'package:smartstock/core/components/top_bar.dart';
import 'package:smartstock/core/models/menu.dart';
import 'package:smartstock/core/services/util.dart';
import 'package:smartstock/sales/components/invoice_details.dart';
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
  List _invoices = [];

  _appBar(context) => StockAppBar(
      title: "Invoices",
      showBack: true,
      backLink: '/sales/',
      showSearch: true,
      onSearch: (d) {
        setState(() {
          _query = d;
        });
        _refresh(skip: false);
      },
      searchHint: 'Search by date...');

  _contextInvoices(context) => [
        ContextMenu(
          name: 'Create',
          pressed: () => navigateTo('/sales/invoice/create'),
        ),
        ContextMenu(name: 'Reload', pressed: () => _refresh(skip: true))
      ];

  _tableHeader() => SizedBox(
        height: 38,
        child: tableLikeListRow([
          tableLikeListTextHeader('Date'),
          tableLikeListTextHeader('Customer'),
          tableLikeListTextHeader('Amount ( TZS )'),
          tableLikeListTextHeader('Paid ( TZS )'),
        ]),
      );

  _fields() => ['date', 'customer', 'amount', 'payment'];

  _loadingView(bool show) =>
      show ? const LinearProgressIndicator(minHeight: 4) : Container();

  @override
  void initState() {
    _refresh();
    super.initState();
  }

  @override
  Widget build(context) => responsiveBody(
        menus: moduleMenus(),
        current: '/sales/',
        onBody: (d) => Scaffold(
          appBar: _appBar(context),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tableContextMenu(_contextInvoices(context)),
              _loadingView(_loading),
              _tableHeader(),
              Expanded(
                child: TableLikeList(
                    onFuture: () async => _invoices,
                    keys: _fields(),
                    onCell: (a, b, c) {
                      if (a == 'customer') {
                        return Text('${b['displayName']}');
                      }
                      if (a == 'payment') {
                        return Text('${_getInvPayment(b)}');
                      }
                      return Text('$b');
                    },
                    onItemPressed: (item) =>
                        showDialogOrModalSheet(invoiceDetails(context,item), context)),
              ), // _tableFooter()
            ],
          ),
        ),
      );

  _refresh({skip = false}) {
    setState(() {
      _loading = true;
    });
    getInvoiceFromCacheOrRemote(
      stringLike: _query,
      skipLocal: widget.args.queryParams.containsKey('reload') || skip,
    ).then((value) {
      setState(() {
        _invoices = value;
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
    if (b is Map) {
      return b.values
          .fold(0, (dynamic a, element) => a + doubleOrZero('$element'));
    }
    return 0;
  }
}
