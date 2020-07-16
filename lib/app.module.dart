import 'package:bfastui/adapters/module.dart';
import 'package:bfastui/adapters/router.dart';
import 'package:bfastui/bfastui.dart';
import 'package:smartstock/modules/account/account.module.dart';
import 'package:smartstock/modules/dashboard/dashboard.module.dart';
import 'package:smartstock/modules/sales/sales.module.dart';

class SmartStock extends BFastUIMainModule {
  @override
  void initRoutes(String moduleName) {
    BFastUI.navigation(moduleName: moduleName)
        .addRoute(BFastUIRouter(
          '/dashboard',
          module: BFastUI.childModule(DashboardModule()),
        ))
        .addRoute(BFastUIRouter(
          '/account',
          module: BFastUI.childModule(AccountModule()),
        ))
        .addRoute(BFastUIRouter(
          '/sales',
          module: BFastUI.childModule(SalesModule()),
        ));
    ;
  }

  @override
  void initStates(String moduleName) {
    // TODO: implement initStates
  }
}
