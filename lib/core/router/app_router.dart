// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/change_pin_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/pin_login_screen.dart';
import '../../features/auth/presentation/screens/staff_form_screen.dart';
import '../../features/auth/presentation/screens/staff_list_screen.dart';
import '../../features/backup/presentation/screens/backup_screen.dart';
import '../../features/backup/presentation/screens/backup_settings_screen.dart';
import '../../features/cashier/presentation/screens/cashier_screen.dart';
import '../../features/cashier/presentation/screens/payment_screen.dart';
import '../../features/cashier/presentation/screens/receipt_screen.dart';
import '../../features/cashier/presentation/screens/transaction_detail_screen.dart';
import '../../features/cashier/presentation/screens/transaction_history_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/others/presentation/screens/about_app_screen.dart';
import '../../features/others/presentation/screens/help_faq_screen.dart';
import '../../features/others/presentation/screens/privacy_policy_screen.dart';
import '../../features/others/presentation/screens/terms_conditions_screen.dart';
import '../../features/printer/presentation/screens/printer_list_screen.dart';
import '../../features/printer/presentation/screens/receipt_settings_screen.dart';
import '../../features/products/domain/entities/product_entity.dart';
import '../../features/products/presentation/screens/category_manager_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/reports/presentation/screens/category_report_screen.dart';
import '../../features/reports/presentation/screens/dashboard_screen.dart';
import '../../features/reports/presentation/screens/product_performance_screen.dart';
import '../../features/reports/presentation/screens/profit_report_screen.dart';
import '../../features/reports/presentation/screens/transaction_report_screen.dart';
import '../../features/stock/presentation/screens/stock_adjustment_screen.dart';
import '../../features/stock/presentation/screens/stock_history_screen.dart';
import '../../features/stock/presentation/screens/stock_overview_screen.dart';
import '../../features/tax_discount/presentation/screens/tax_discount_screen.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

/// Helper: slide dari kanan + fade ringan, durasi 220ms.
/// Jauh lebih responsif dibanding default Material (300ms + heavy curve).
Page<T> _slidePage<T extends Object?>(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurveTween(curve: Curves.easeOutCubic);
      final slide = Tween<Offset>(
        begin: const Offset(0.06, 0),
        end: Offset.zero,
      ).chain(curve);
      final fade = Tween<double>(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
      );
      return SlideTransition(
        position: animation.drive(slide),
        child: FadeTransition(
          opacity: animation.drive(fade),
          child: child,
        ),
      );
    },
  );
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      // 1. Cek onboarding
      final checkOnboarding = ref.read(checkOnboardingUsecaseProvider);
      final onboardingRes = await checkOnboarding();
      final isOnboarded = onboardingRes.fold((_) => false, (v) => v);

      if (!isOnboarded) {
        // Jika belum onboarding, hanya izinkan masuk ke /onboarding
        if (state.matchedLocation != AppRoutes.onboarding) {
          return AppRoutes.onboarding;
        }
        return null;
      }

      // 2. Cek login
      if (!isLoggedIn) {
        // Jika belum login, hanya izinkan masuk ke /login
        if (state.matchedLocation != AppRoutes.login) {
          return AppRoutes.login;
        }
        return null;
      }

      // 3. Jika sudah login tetapi mencoba mengakses /onboarding atau /login -> redirect ke home
      if (state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.login) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // ── Onboarding & Login ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            _slidePage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            _slidePage(state, const PinLoginScreen()),
      ),

      // ── Main shell / Home ───────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _slidePage(state, const HomeScreen()),
      ),

      // ── Products ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.products,
        pageBuilder: (context, state) =>
            _slidePage(state, const ProductListScreen()),
      ),
      GoRoute(
        path: AppRoutes.categories,
        pageBuilder: (context, state) =>
            _slidePage(state, const CategoryManagerScreen()),
      ),
      GoRoute(
        path: AppRoutes.productAdd,
        pageBuilder: (context, state) =>
            _slidePage(state, const ProductFormScreen()),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slidePage(state, ProductDetailScreen(productId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.productEdit,
        pageBuilder: (context, state) {
          final product = state.extra as ProductEntity?;
          return _slidePage(state, ProductFormScreen(product: product));
        },
      ),

      // ── Stock ───────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.stockList,
        pageBuilder: (context, state) =>
            _slidePage(state, const StockOverviewScreen()),
      ),
      GoRoute(
        path: AppRoutes.stockAdjustment,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _slidePage(
            state,
            StockAdjustmentScreen(
              productId: extra?['productId'] as String?,
              productName: extra?['productName'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.stockLedger,
        pageBuilder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return _slidePage(state, StockHistoryScreen(productId: productId));
        },
      ),

      // ── Staff Management ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.staffList,
        pageBuilder: (context, state) =>
            _slidePage(state, const StaffListScreen()),
      ),
      GoRoute(
        path: AppRoutes.staffAdd,
        pageBuilder: (context, state) =>
            _slidePage(state, const StaffFormScreen()),
      ),
      GoRoute(
        path: AppRoutes.staffEdit,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slidePage(state, StaffFormScreen(staffId: id));
        },
      ),

      // ── Settings ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.taxDiscount,
        pageBuilder: (context, state) =>
            _slidePage(state, const TaxDiscountScreen()),
      ),
      GoRoute(
        path: AppRoutes.printerConfig,
        pageBuilder: (context, state) =>
            _slidePage(state, const PrinterListScreen()),
      ),
      GoRoute(
        path: AppRoutes.storeConfig,
        pageBuilder: (context, state) =>
            _slidePage(state, const ReceiptSettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.backup,
        pageBuilder: (context, state) =>
            _slidePage(state, const BackupScreen()),
      ),
      GoRoute(
        path: AppRoutes.backupSettings,
        pageBuilder: (context, state) =>
            _slidePage(state, const BackupSettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.changePin,
        pageBuilder: (context, state) =>
            _slidePage(state, const ChangePinScreen()),
      ),
      GoRoute(
        path: AppRoutes.helpFaq,
        pageBuilder: (context, state) =>
            _slidePage(state, const HelpFaqScreen()),
      ),
      GoRoute(
        path: AppRoutes.terms,
        pageBuilder: (context, state) =>
            _slidePage(state, const TermsConditionsScreen()),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        pageBuilder: (context, state) =>
            _slidePage(state, const PrivacyPolicyScreen()),
      ),
      GoRoute(
        path: AppRoutes.about,
        pageBuilder: (context, state) =>
            _slidePage(state, const AboutAppScreen()),
      ),

      // ── Cashier / POS ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.cashier,
        pageBuilder: (context, state) =>
            _slidePage(state, const CashierScreen()),
      ),
      GoRoute(
        path: AppRoutes.payment,
        pageBuilder: (context, state) =>
            _slidePage(state, const PaymentScreen()),
      ),
      GoRoute(
        path: AppRoutes.receipt,
        pageBuilder: (context, state) {
          final id = state.pathParameters['transactionId']!;
          return _slidePage(state, ReceiptScreen(transactionId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.transactions,
        pageBuilder: (context, state) =>
            _slidePage(state, const TransactionHistoryScreen()),
      ),
      GoRoute(
        path: AppRoutes.transactionDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slidePage(state, TransactionDetailScreen(transactionId: id));
        },
      ),

      // ── Reports ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.reports,
        pageBuilder: (context, state) =>
            _slidePage(state, const DashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.reportSales,
        pageBuilder: (context, state) =>
            _slidePage(state, const TransactionReportScreen()),
      ),
      GoRoute(
        path: AppRoutes.reportProducts,
        pageBuilder: (context, state) =>
            _slidePage(state, const ProductPerformanceScreen()),
      ),
      GoRoute(
        path: AppRoutes.reportCategories,
        pageBuilder: (context, state) =>
            _slidePage(state, const CategoryReportScreen()),
      ),
      GoRoute(
        path: AppRoutes.reportProfit,
        pageBuilder: (context, state) =>
            _slidePage(state, const ProfitReportScreen()),
      ),
    ],
  );
}
