import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartstock/account/pages/LoginPage.dart';
import 'package:smartstock/account/pages/payment.dart';
import 'package:smartstock/core/components/BodyLarge.dart';
import 'package:smartstock/core/components/BodyMedium.dart';
import 'package:smartstock/core/components/LabelLarge.dart';
import 'package:smartstock/core/components/WhiteSpacer.dart';
import 'package:smartstock/core/components/headline_large.dart';
import 'package:smartstock/core/components/responsive_page_container.dart';
import 'package:smartstock/core/pages/page_base.dart';
import 'package:smartstock/core/plugins/sync.dart';
import 'package:smartstock/core/services/cache_shop.dart';
import 'package:smartstock/core/services/cache_user.dart';
import 'package:smartstock/core/services/util.dart';
import 'package:smartstock/dashboard/pages/index.dart';
import 'package:smartstock/page_history.dart';
import 'package:smartstock/sales/pages/index.dart';

// import 'package:socket_io_client/socket_io_client.dart' as io_client;

import 'core/plugins/sync_common.dart';

class SmartStockApp extends StatefulWidget {
  final OnGetModulesMenu onGetModulesMenu;
  final OnGetInitialPage onGetInitialModule;

  const SmartStockApp({
    Key? key,
    required this.onGetModulesMenu,
    required this.onGetInitialModule,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SmartStockApp> {
  int i = 0;
  PageBase? child = const DashboardIndexPage();
  bool loading = false;
  bool initialized = false;
  Map? user;
  var _shouldSubsRun = true;
  var _shouldProductsSyncsRun = true;
  var _shouldShowSubsDialog = true;
  var _payNowClicked = false;
  Timer? _subscriptionTimer;
  Timer? _productRefreshTimer;

  // io_client.Socket? _socket;

  @override
  void initState() {
    _getLoginUser();
    _periodicSubscriptionCheck();
    _periodProductsSync();
    _listeningForStockChanges();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading == true) {
      return Container();
    }
    if (user is Map && propertyOrNull('username')(user) != null) {
      return WillPopScope(
        child: ResponsivePageContainer(
          onGetModulesMenu: widget.onGetModulesMenu,
          onGetInitialModule: widget.onGetInitialModule,
          menus: widget.onGetModulesMenu(
            context: context,
            onChangePage: _onChangePage,
            onBackPage: _onBackPage,
          ),
          onChangePage: _onChangePage,
          child: child ?? Container(),
        ),
        onWillPop: () async {
          if (kDebugMode) {
            print('------');
            print('Back pressed');
            print('------');
          }
          if (PageHistory().getLength() == 1) {
            return true;
          }
          _onBackPage();
          return false;
        },
      );
    } else {
      return LoginPage(
        onGetModulesMenu: widget.onGetModulesMenu,
        onGetInitialModule: widget.onGetInitialModule,
      );
    }
  }

  _onChangePage(PageBase page) {
    _updateState(() {
      child = page;
      if (PageHistory().getIsNotEmpty()) {
        PageBase lastWidget = PageHistory().getLast();
        if (lastWidget.pageName == page.pageName) {
          if (kDebugMode) {
            print('---- ${lastWidget.pageName} ----');
            print('---- ${page.pageName} ----');
            print('---- SAME PAGE ----');
          }
        } else {
          PageHistory().add(page);
        }
      } else {
        PageHistory().add(page);
      }
    });
  }

  _onBackPage() {
    var length = PageHistory().getLength();
    if (kDebugMode) {
      print('Length ---> $length');
    }
    goBack(int offset) {
      var last = PageHistory().getAt(length - offset);
      if (last != null) {
        _updateState(() {
          child = last;
          PageHistory().removeAt(length - 1);
        });
      }
    }

    if (length == 1) {
      goBack(1);
    }
    if (length > 1) {
      goBack(2);
    }
  }

  _updateState(Function() fn) {
    if (mounted) {
      setState(fn);
    }
  }

  _getLoginUser() {
    _updateState(() {
      loading = true;
      user = null;
      initialized = false;
    });
    getLocalCurrentUser().then((value) async {
      var shop = await getActiveShop();
      if (shop == null) {
        return;
      }
      user = value is Map && value['username'] != null ? value : null;
      if (user == null) {
        return;
      }
      var initialPage = widget.onGetInitialModule(
          onBackPage: _onBackPage, onChangePage: _onChangePage);
      if (initialPage != null) {
        child = initialPage;
      } else {
        var role = propertyOrNull('role')(user);
        if (role != 'admin' && initialized == false) {
          child = SalesPage(
            onChangePage: _onChangePage,
            onBackPage: _onBackPage,
          );
        }
      }
      if (child != null) {
        PageHistory().add(child!);
      }
      initialized = true;
    }).catchError((err) {
      if (kDebugMode) {
        print(err);
      }
      user = null;
    }).whenComplete(() {
      _updateState(() {
        loading = false;
      });
    });
  }

  void _periodicSubscriptionCheck() {
    _subscriptionTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_shouldSubsRun) {
        try {
          _shouldSubsRun = false;
          dynamic value = {};
          if (isNativeMobilePlatform() == true) {
            final resultPort = ReceivePort();
            await Isolate.spawn(checkSubscription,
                [resultPort.sendPort, ServicesBinding.rootIsolateToken]);
            value = await (resultPort.first);
          } else {
            value = await compute(checkSubscription, [1]);
          }
          if (kDebugMode) {
            print('Subscription: $value');
          }
          var getSubscription = propertyOrNull('subscription');
          if (getSubscription(value) == false && _shouldShowSubsDialog) {
            _shouldShowSubsDialog = false;
            _showD(value);
          }
        } catch (e) {
          if (kDebugMode) {
            print(_);
          }
        } finally {
          _shouldSubsRun = true;
        }
      } else {
        if (kDebugMode) {
          print('another subscription sync running');
        }
      }
    });
  }

  void _periodProductsSync() {
    _productRefreshTimer =
        Timer.periodic(const Duration(minutes: 5), (_) async {
      if (_shouldProductsSyncsRun) {
        try {
          _shouldProductsSyncsRun = false;
          dynamic value = {};
          if (isNativeMobilePlatform() == true) {
            final resultPort = ReceivePort();
            await Isolate.spawn(updateLocalProducts,
                [resultPort.sendPort, ServicesBinding.rootIsolateToken]);
            value = await (resultPort.first);
          } else {
            value = await compute(updateLocalProducts, [1]);
          }
          if (kDebugMode) {
            print('Products sync: $value');
          }
        } catch (e) {
          if (kDebugMode) {
            print(_);
          }
        } finally {
          _shouldProductsSyncsRun = true;
        }
      } else {
        if (kDebugMode) {
          print('Another products sync running');
        }
      }
    });
  }

  void _listeningForStockChanges() {
    // _socket = io_client.io('$baseUrl/changes/stock/products', io_client.OptionBuilder()
    // .enableReconnection()
    // .enableAutoConnect()
    // .setTransports(['websocket'])
    // .build());
    // getActiveShop().then((value) {
    //   if (value is Map && value['projectId'] != null) {
    //     var projectId = value['projectId'];
    //     _socket?.onConnect((_) {
    //       if (kDebugMode) {
    //         print('connected stock socket');
    //       }
    //       _socket?.emit('${projectId}_stocks', {
    //         'auth': {'projectId': projectId}
    //       });
    //     });
    //     _socket?.on('${projectId}_stocks', (data) => print(data));
    //     _socket?.onDisconnect((_) => print('disconnect from stock changes'));
    //     // socket.on('fromServer', (_) => print(_));
    //   }
    // }).catchError((error) {
    //   if (kDebugMode) {
    //     print(error);
    //   }
    // });
  }

  @override
  void dispose() {
    _subscriptionTimer?.cancel();
    _productRefreshTimer?.cancel();
    // _socket?.close();
    super.dispose();
  }

  void _showD(dynamic value) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async {
            if (_payNowClicked == true) {
              return true;
            }
            var noGrace = value is Map && value['force'] == true;
            return noGrace == true ? false : true;
          },
          child: Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  constraints:
                      const BoxConstraints(minHeight: 210, maxWidth: 400),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(4)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LabelLarge(text: 'You have unpaid invoice'),
                      const WhiteSpacer(height: 8),
                      HeadlineLarge(
                          text: 'TZ ${formatNumber(value['balance'])}'),
                      const WhiteSpacer(height: 16),
                      const BodyLarge(
                          text:
                              'For all your shops, to continue using the service you must pay'),
                      const WhiteSpacer(height: 24),
                      Row(
                        children: [
                          value is Map && value['force'] == true
                              ? Container()
                              : Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .maybePop()
                                          .whenComplete(() {
                                        _shouldShowSubsDialog = true;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                      ),
                                      child: const BodyMedium(text: 'CANCEL'),
                                    ),
                                  ),
                                ),
                          const WhiteSpacer(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _payNowClicked = true;
                                Navigator.of(context)
                                    .maybePop()
                                    .whenComplete(() {
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      fullscreenDialog: true,
                                      builder: (context) {
                                        return PaymentPage(subscription: value);
                                      },
                                    ),
                                  )
                                      .whenComplete(() {
                                    _shouldShowSubsDialog = true;
                                  });
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                child: const BodyMedium(text: 'PAY NOW'),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
