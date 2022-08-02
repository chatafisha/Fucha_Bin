import 'package:builders/builders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

navigateTo(String route) => Modular.to.navigate(route);

navigator() => Modular.to;

navigateToAndReplace(String route) => Modular.to.pushReplacementNamed(route);

getState<T>() => Modular.get<T>();

consumerComponent<T extends ChangeNotifier>({
  Widget Function(BuildContext context, T state) builder,
}) =>
    Consumer<T>(builder: builder);

selectorComponent<T extends ChangeNotifier, D>({
  Function(T state) selector,
  Widget Function(BuildContext context, D value) builder,
}) =>
    Selector<T, D>(builder: builder, selector: selector);
