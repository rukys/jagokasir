// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cashier/presentation/providers/cart_provider.dart';
import '../../../cashier/presentation/screens/cashier_screen.dart';
import '../../../products/presentation/screens/product_list_screen.dart';
import '../../../reports/presentation/screens/dashboard_screen.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../../stock/presentation/screens/stock_overview_screen.dart';
import 'settings_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(currentStaffProvider);
    if (staff == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final isKasir = staff.role == StaffRole.kasir;
    final lowStockCountAsync = ref.watch(lowStockCountProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final int cartItemsCount = cartState.items.length;

    // Define pages and navigation destinations dynamically based on user role
    final List<Widget> pages = isKasir
        ? [
            const CashierScreen(),
            const SettingsTab(),
          ]
        : [
            const DashboardScreen(),
            const ProductListScreen(),
            const CashierScreen(),
            const StockOverviewScreen(),
            const SettingsTab(),
          ];

    final List<NavigationDestination> destinations = isKasir
        ? [
            NavigationDestination(
              icon: cartItemsCount > 0
                  ? Badge(
                      label: Text('$cartItemsCount'),
                      child: const Icon(Icons.point_of_sale_rounded),
                    )
                  : const Icon(Icons.point_of_sale_rounded),
              label: 'Kasir',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              label: 'Pengaturan',
            ),
          ]
        : [
            const NavigationDestination(
              icon: Icon(Icons.pie_chart_rounded),
              label: 'Dashboard',
            ),
            const NavigationDestination(
              icon: Icon(Icons.inventory_2_rounded),
              label: 'Produk',
            ),
            NavigationDestination(
              icon: cartItemsCount > 0
                  ? Badge(
                      label: Text('$cartItemsCount'),
                      child: const Icon(Icons.point_of_sale_rounded),
                    )
                  : const Icon(Icons.point_of_sale_rounded),
              label: 'Kasir',
            ),
            NavigationDestination(
              icon: lowStockCountAsync.maybeWhen(
                data: (count) => count > 0
                    ? Badge(
                        label: Text('$count'),
                        child: const Icon(Icons.bar_chart_rounded),
                      )
                    : const Icon(Icons.bar_chart_rounded),
                orElse: () => const Icon(Icons.bar_chart_rounded),
              ),
              label: 'Stok',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              label: 'Pengaturan',
            ),
          ];

    // Safe fallback if index gets out of bounds during runtime role changes
    final safeIndex = _currentIndex < pages.length ? _currentIndex : 0;

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: destinations,
      ),
    );
  }
}
