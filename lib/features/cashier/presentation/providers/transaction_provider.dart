import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../data/datasources/transaction_local_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_item_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../domain/usecases/get_daily_invoice_count_usecase.dart';
import '../../domain/usecases/get_transaction_by_id_usecase.dart';
import '../../domain/usecases/get_transaction_list_usecase.dart';
import '../../domain/usecases/void_transaction_usecase.dart';
import 'cart_provider.dart';

part 'transaction_provider.g.dart';

// ── Dependency Providers ────────────────────────────────────────────────────

@riverpod
TransactionLocalDatasource transactionLocalDatasource(Ref ref) =>
    const TransactionLocalDatasource();

@riverpod
TransactionRepository transactionRepository(Ref ref) =>
    TransactionRepositoryImpl(ref.watch(transactionLocalDatasourceProvider));

@riverpod
GetDailyInvoiceCountUsecase getDailyInvoiceCountUsecase(Ref ref) =>
    GetDailyInvoiceCountUsecase(ref.watch(transactionRepositoryProvider));

@riverpod
CheckoutUsecase checkoutUsecase(Ref ref) =>
    CheckoutUsecase(
      ref.watch(transactionRepositoryProvider),
      ref.watch(stockRepositoryProvider),
    );

@riverpod
VoidTransactionUsecase voidTransactionUsecase(Ref ref) =>
    VoidTransactionUsecase(
      ref.watch(transactionRepositoryProvider),
      ref.watch(staffRepositoryProvider),
    );

@riverpod
GetTransactionByIdUsecase getTransactionByIdUsecase(Ref ref) =>
    GetTransactionByIdUsecase(ref.watch(transactionRepositoryProvider));

@riverpod
GetTransactionListUsecase getTransactionListUsecase(Ref ref) =>
    GetTransactionListUsecase(ref.watch(transactionRepositoryProvider));

// ── Data Providers ──────────────────────────────────────────────────────────

/// Provider untuk mengambil riwayat transaksi terfilter
@riverpod
Future<List<TransactionEntity>> transactionList(
  Ref ref, {
  TransactionStatus? status,
  String? query,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final staff = ref.watch(currentStaffProvider);
  if (staff == null) throw const PermissionFailure('Staff belum login');

  final usecase = ref.watch(getTransactionListUsecaseProvider);
  final result = await usecase(
    currentStaff: staff,
    status: status,
    query: query,
    startDate: startDate,
    endDate: endDate,
  );

  return result.fold(
    (failure) => throw failure,
    (list) => list,
  );
}

/// Provider untuk mengambil single transaksi berdasarkan ID
@riverpod
Future<TransactionEntity> transactionDetail(Ref ref, String id) async {
  final usecase = ref.watch(getTransactionByIdUsecaseProvider);
  final result = await usecase(id);
  return result.fold(
    (failure) => throw failure,
    (txn) => txn,
  );
}

// ── Checkout Notifier ────────────────────────────────────────────────────────

@riverpod
class CheckoutNotifier extends _$CheckoutNotifier {
  @override
  AsyncValue<TransactionEntity?> build() => const AsyncData(null);

  Future<TransactionEntity?> executeCheckout({
    required List<CartItemEntity> cartItems,
    required double subtotal,
    required DiscountType? discountType,
    required double? discountValue,
    required double discountAmount,
    required double taxRate,
    required bool taxIsInclusive,
    required double taxAmount,
    required double total,
    required PaymentMethod paymentMethod,
    double? paymentReceived,
    double? changeAmount,
    String? note,
  }) async {
    state = const AsyncLoading();

    final staff = ref.read(currentStaffProvider);
    if (staff == null) {
      state = AsyncError(const PermissionFailure('Staff belum login'), StackTrace.current);
      return null;
    }

    final transactionId = UuidGenerator.generate();
    final List<TransactionItemEntity> items = cartItems.map((e) {
      return TransactionItemEntity(
        id: UuidGenerator.generate(),
        transactionId: transactionId,
        productId: e.productId,
        productName: e.productName,
        productSku: e.productSku,
        sellingPrice: e.sellingPrice,
        costPrice: e.costPrice,
        quantity: e.quantity,
        itemDiscountType: e.discountType,
        itemDiscountValue: e.discountValue,
        itemDiscountAmount: e.itemDiscountAmount,
        lineTotal: e.lineTotal,
      );
    }).toList();

    final transaction = TransactionEntity(
      id: transactionId,
      invoiceNumber: '', // Diisi di data layer oleh Generator secara atomik
      staffId: staff.id,
      staffName: staff.name,
      subtotal: subtotal,
      discountType: discountType,
      discountValue: discountValue,
      discountAmount: discountAmount,
      taxRate: taxRate,
      taxIsInclusive: taxIsInclusive,
      taxAmount: taxAmount,
      total: total,
      paymentMethod: paymentMethod,
      paymentReceived: paymentReceived,
      changeAmount: changeAmount,
      status: TransactionStatus.completed,
      note: note,
      createdAt: DateTime.now(),
      items: items,
    );

    final usecase = ref.read(checkoutUsecaseProvider);
    final result = await usecase(transaction);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
      (txn) {
        state = AsyncData(txn);
        // Invalidate status stok di UI
        ref.invalidate(stockListProvider);
        ref.invalidate(lowStockListProvider);
        ref.invalidate(lowStockCountProvider);
        // Bersihkan keranjang
        ref.read(cartNotifierProvider.notifier).clearCart();
        return txn;
      },
    );
  }
}

// ── Void Notifier ────────────────────────────────────────────────────────────

@riverpod
class VoidNotifier extends _$VoidNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> executeVoid({
    required String transactionId,
    required String reason,
  }) async {
    state = const AsyncLoading();

    final staff = ref.read(currentStaffProvider);
    if (staff == null) {
      state = AsyncError(const PermissionFailure('Staff belum login'), StackTrace.current);
      return false;
    }

    final usecase = ref.read(voidTransactionUsecaseProvider);
    final result = await usecase(
      transactionId: transactionId,
      staffId: staff.id,
      reason: reason,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (success) {
        state = const AsyncData(null);
        // Invalidate stok & daftar transaksi setelah dibatalkan
        ref.invalidate(stockListProvider);
        ref.invalidate(lowStockListProvider);
        ref.invalidate(lowStockCountProvider);
        ref.invalidate(transactionListProvider);
        return success;
      },
    );
  }
}
