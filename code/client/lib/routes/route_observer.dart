import 'package:client/utils/storage_helper.dart';
import 'package:flutter/widgets.dart';

class RotaObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route route, Route? previousRoute) {
    _salvarRota(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _salvarRota(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _salvarRota(Route? route) async {
  if (route is PageRoute) {
    final nome = route.settings.name ?? '/';
    await StorageHelper.instance.setItem('rotaAtual', nome);
  }
}
}
