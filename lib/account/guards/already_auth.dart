import 'package:bfast/util.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:smartstock/core/services/cache_shop.dart';
import 'package:smartstock/core/services/cache_user.dart';
import 'package:smartstock/core/services/util.dart';

class AlreadyAuthGuard extends RouteGuard {
  @override
  Future<bool> canActivate(String path, var route) async {
    var user = await getLocalCurrentUser();
    return ifDoElse((y) => y == null, (_) => true, (_) {
      removeActiveShop();
      navigateTo('/shop');
      return false;
    })(user);
  }
}
