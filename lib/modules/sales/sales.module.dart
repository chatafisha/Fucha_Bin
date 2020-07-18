import 'package:bfastui/adapters/module.dart';
import 'package:bfastui/adapters/router.dart';
import 'package:bfastui/bfastui.dart';
import 'package:smartstock/modules/sales/pages/retail.page.dart';
import 'package:smartstock/modules/sales/pages/sales.page.dart';
import 'package:smartstock/modules/sales/pages/wholesale.page.dart';
import 'package:smartstock/modules/sales/states/sales.state.dart';
import 'package:smartstock/shared/guards/AuthGuard.dart';

class SalesModule extends BFastUIChildModule {
  @override
  void initRoutes(String moduleName) {
    BFastUI.navigation(moduleName: moduleName)
        .addRoute(
          BFastUIRouter(
            '/',
            guards: [AuthGuard()],
            page: (context, args) => SalesPage(),
          ),
        )
        .addRoute(BFastUIRouter(
          '/whole',
          guards: [AuthGuard()],
          page: (context, args) => WholesalePage(),
        ))
        .addRoute(BFastUIRouter(
          '/retail',
          guards: [AuthGuard()],
          page: (context, args) => RetailPage(),
        ));
  }

  @override
  void initStates(String moduleName) {
    BFastUI.states(moduleName: moduleName)
        .addState(BFastUIStateBinder((_) => SalesState()));

  }

  @override
  String moduleName() {
    return 'sales';
  }
}
