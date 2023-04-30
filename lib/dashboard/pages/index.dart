import 'package:flutter/material.dart';
import 'package:smartstock/core/components/dialog_or_bottom_sheet.dart';
import 'package:smartstock/core/components/responsive_body.dart';
import 'package:smartstock/core/components/stock_app_bar.dart';
import 'package:smartstock/core/services/util.dart';
import 'package:smartstock/dashboard/components/summary.dart';

class DashboardIndexPage extends StatelessWidget {
  final OnGetModulesMenu onGetModulesMenu;

  const DashboardIndexPage({Key? key, required this.onGetModulesMenu})
      : super(key: key);

  @override
  Widget build(context) {
    return ResponsivePage(
      office: 'Menu',
      current: '/dashboard/',
      menus: onGetModulesMenu(context),
      sliverAppBar: getSliverSmartStockAppBar(
          title: "Dashboard", showBack: false, context: context),
      staticChildren: const [DashboardSummary()],
      fab: !hasEnoughWidth(context)
          ? FloatingActionButton(
              onPressed: () => _getQuickActions(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  _getQuickActions(context) {
    showDialogOrModalSheet(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Post Cash Sale'),
              leading: const Icon(Icons.receipt),
              onTap: () => navigateTo('/sales/cash'),
              subtitle: const Text(
                'Retail & Wholesale',
                style: TextStyle(fontSize: 12),
              ),
            ),
            ListTile(
              title: const Text('Post Invoice'),
              leading: const Icon(Icons.insert_invitation_outlined),
              onTap: () => navigateTo('/sales/invoice/create'),
              subtitle: const Text(
                'Prepare new invoice',
                style: TextStyle(fontSize: 12),
              ),
            ),
            ListTile(
              title: const Text('Post Product'),
              leading: const Icon(Icons.inventory_outlined),
              onTap: () => navigateTo('/stock/products/create'),
              subtitle: const Text(
                'Register new stock item',
                style: TextStyle(fontSize: 12),
              ),
            ),
            ListTile(
              title: const Text('Post Purchase'),
              leading: const Icon(Icons.receipt_long_rounded),
              onTap: () => navigateTo('/stock/purchases/create'),
              subtitle: const Text(
                'Register receipt or invoice',
                style: TextStyle(fontSize: 12),
              ),
            ),
            ListTile(
              title: const Text('Expense'),
              leading: const Icon(Icons.outbond_outlined),
              onTap: () => navigateTo('/expense'),
              subtitle: const Text(
                'View & add new',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        context);
  }
}
