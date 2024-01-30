import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartstock/core/components/BodyLarge.dart';
import 'package:smartstock/core/components/LabelMedium.dart';
import 'package:smartstock/core/components/ResponsivePage.dart';
import 'package:smartstock/core/components/WhiteSpacer.dart';
import 'package:smartstock/core/components/debounce.dart';
import 'package:smartstock/core/helpers/dialog_or_bottom_sheet.dart';
import 'package:smartstock/core/components/horizontal_line.dart';
import 'package:smartstock/core/components/search_by_container.dart';
import 'package:smartstock/core/components/sliver_smartstock_appbar.dart';
import 'package:smartstock/core/components/table_context_menu.dart';
import 'package:smartstock/core/components/table_like_list_data_cell.dart';
import 'package:smartstock/core/components/table_like_list_row.dart';
import 'package:smartstock/core/components/table_like_list_header_cell.dart';
import 'package:smartstock/core/helpers/functional.dart';
import 'package:smartstock/core/models/menu.dart';
import 'package:smartstock/core/pages/PageBase.dart';
import 'package:smartstock/core/helpers/util.dart';
import 'package:smartstock/sales/components/sale_cash_details.dart';
import 'package:smartstock/sales/pages/sales_cash_retail.dart';
import 'package:smartstock/sales/pages/sales_cash_whole.dart';
import 'package:smartstock/sales/services/sales.dart';

class SalesCashPage extends PageBase {
  final OnBackPage onBackPage;
  final OnChangePage onChangePage;

  const SalesCashPage({
    Key? key,
    required this.onBackPage,
    required this.onChangePage,
  }) : super(key: key, pageName: 'SalesCashPage');

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SalesCashPage> {
  final _debounce = Debounce(milliseconds: 500);
  bool _loading = false;
  String _query = '';
  int size = 20;
  List _sales = [];
  Map<String, String> _searchByMap = {'name': "Receipt Date", 'value': 'date'};

  _onItemPressed(item) {
    showDialogOrModalSheet(
        CashSaleDetail(sale: item, pageContext: context), context);
  }

  _itemsSize(c) {
    var getItems = compose([
      (x) => x.fold(
            0,
            (a, element) => doubleOrZero(a) + doubleOrZero(element['quantity']),
          ),
      itOrEmptyArray,
      propertyOrNull('items')
    ]);
    return getItems(c);
  }

  _getTimer(c) {
    var getTimer = propertyOr('timer', (p0) => '');
    var date = DateTime.tryParse(getTimer(c)) ?? DateTime.now();
    var dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return dateFormat.format(date);
  }

  _appBar(context) {
    return SliverSmartStockAppBar(
      title: "Cash sales",
      showBack: true,
      backLink: '/sales/',
      showSearch: true,
      onBack: widget.onBackPage,
      context: context,
      searchByView: SearchByContainer(
        filters: [
          SearchByFilter(
              child: const BodyLarge(text: "Customer name"),
              value: {'name': "Customer", 'value': 'customer'}),
          SearchByFilter(
              child: const BodyLarge(text: "Invoice date"),
              value: {'name': "Invoice date", 'value': 'date'}),
        ],
        currentValue: _searchByMap['name'] ?? '',
        onUpdate: (searchMap) {
          _updateState(() {
            _searchByMap = searchMap;
          });
          _refresh();
        },
      ),
      onSearch: (d) {
        _debounce.run(() {
          if (kDebugMode) {
            print(d);
          }
          _query = d;
          _refresh();
        });
      },
    );
  }

  _updateState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  _contextSales(context) {
    return [
      ContextMenu(
        name: 'Add Retail',
        pressed: () =>
            widget.onChangePage(SalesCashRetail(onBackPage: widget.onBackPage)),
      ),
      ContextMenu(
        name: 'Add Wholesale',
        pressed: () =>
            widget.onChangePage(SalesCashWhole(onBackPage: widget.onBackPage)),
      ),
      ContextMenu(name: 'Reload', pressed: () => _refresh())
    ];
  }

  _tableHeader() {
    return const SizedBox(
      height: 38,
      child: TableLikeListRow([
        TableLikeListHeaderCell('Customer'),
        TableLikeListHeaderCell('Amount ( TZS )'),
        TableLikeListHeaderCell('Items'),
        TableLikeListHeaderCell('Date'),
      ]),
    );
  }

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      current: '/sales/',
      sliverAppBar: _appBar(context),
      staticChildren: [
        _loadingView(_loading),
        getIsSmallScreen(context)
            ? Container()
            : getTableContextMenu(_contextSales(context)),
        getIsSmallScreen(context) ? Container() : _tableHeader(),
      ],
      loading: _loading,
      onLoadMore: () async => _loadMore(),
      fab: FloatingActionButton(
        onPressed: () => _showMobileContextMenu(context),
        child: const Icon(Icons.unfold_more_outlined),
      ),
      totalDynamicChildren: _sales.length,
      dynamicChildBuilder: getIsSmallScreen(context)
          ? _smallScreenChildBuilder
          : _largerScreenChildBuilder,
    );
  }

  _loadMore() {
    _updateState(() {
      _loading = true;
    });
    var getSales = _prepareGetSales(
        filterBy: _searchByMap['value'] ?? 'date',
        filterValue: _query,
        size: size,
        more: true);
    getSales(_sales).then((value) {
      if (value is List) {
        _sales.addAll(value);
        _sales = _sales.toSet().toList();
      }
    }).whenComplete(() {
      _updateState(() {
        _loading = false;
      });
    });
  }

  _refresh() {
    _updateState(() {
      _loading = true;
    });
    var getSales = _prepareGetSales(
        filterBy: _searchByMap['value'] ?? 'date',
        filterValue: _query,
        size: size,
        more: false);
    getSales(_sales).then((value) {
      if (value is List) {
        _sales = value;
      }
    }).whenComplete(() {
      _updateState(() {
        _loading = false;
      });
    });
  }

  _defaultLast() {
    var dF = DateFormat('yyyy-MM-ddTHH:mm');
    var date = DateTime.now().add(const Duration(days: 1));
    return dF.format(date);
  }

  _prepareGetSales(
      {required size,
      required bool more,
      required String filterBy,
      required String filterValue}) {
    return ifDoElse(
      (sales) => sales is List && sales.isNotEmpty,
      (sales) {
        var last = more ? sales.last['timer'] : _defaultLast();
        return getCashSalesFromCacheOrRemote(
            startAt: last,
            size: size,
            filterBy: filterBy,
            filterValue: filterValue);
      },
      (sales) => getCashSalesFromCacheOrRemote(
          startAt: _defaultLast(),
          size: size,
          filterBy: filterBy,
          filterValue: filterValue),
    );
  }

  Widget _customerView(c) {
    var getCustomerV2 = compose([
      (x) => '${x ?? ''}'.trim(),
      propertyOrNull('displayName'),
      propertyOrNull('customer')
    ]);
    var getCustomerV1 =
        compose([(x) => '${x ?? ''}'.trim(), propertyOrNull('customer')]);
    var subText = c['channel'] == 'whole' ? 'Wholesale' : 'Retail';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BodyLarge(
            text:
                '${getCustomerV2(c).isEmpty ? (getCustomerV1(c).isEmpty ? 'Walk in customer' : getCustomerV1(c)) : getCustomerV2(c)}'),
        LabelMedium(text: subText)
      ]),
    );
  }

  Widget _smallScreenChildBuilder(context, index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          onTap: () => _onItemPressed(_sales[index]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 2),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _customerView(_sales[index])),
              const WhiteSpacer(width: 16),
              Text('${compactNumber(_sales[index]['amount'])}')
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getTimer(_sales[index])}',
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis, fontSize: 14),
              ),
              Text(
                'Items ${doubleOrZero(_itemsSize(_sales[index]))}',
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        const HorizontalLine(),
      ],
    );
  }

  Widget _largerScreenChildBuilder(context, index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => _onItemPressed(_sales[index]),
          child: TableLikeListRow([
            _customerView(_sales[index]),
            TableLikeListTextDataCell(
                '${formatNumber(_sales[index]['amount'])}'),
            TableLikeListTextDataCell(
                '${doubleOrZero(_itemsSize(_sales[index]))}'),
            TableLikeListTextDataCell('${_getTimer(_sales[index])}'),
          ]),
        ),
        const HorizontalLine()
      ],
    );
  }

  void _showMobileContextMenu(context) {
    showDialogOrModalSheet(
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add retail'),
                onTap: () {
                  Navigator.of(context).maybePop();
                  widget.onChangePage(
                      SalesCashRetail(onBackPage: widget.onBackPage));
                },
              ),
              const HorizontalLine(),
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Add wholesale'),
                onTap: () {
                  Navigator.of(context).maybePop();
                  widget.onChangePage(
                      SalesCashWhole(onBackPage: widget.onBackPage));
                },
              ),
              const HorizontalLine(),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Reload sales'),
                onTap: () {
                  Navigator.of(context).maybePop();
                  _refresh();
                },
              ),
            ],
          ),
        ),
        context);
  }
}
