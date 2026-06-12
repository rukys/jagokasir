import '../../domain/entities/date_range.dart';
import '../../domain/entities/sales_summary_entity.dart';

class SalesSummaryModel extends SalesSummaryEntity {
  const SalesSummaryModel({
    required super.totalRevenue,
    required super.totalTransactions,
    required super.totalItemsSold,
    required super.averageTransactionValue,
    required super.revenueByPaymentMethod,
    required super.period,
  });

  factory SalesSummaryModel.fromMap(
    Map<String, dynamic> map,
    Map<String, double> paymentMethods,
    DateRange period,
  ) {
    final revenue = (map['total_revenue'] as num?)?.toDouble() ?? 0.0;
    final txns = (map['total_transactions'] as num?)?.toInt() ?? 0;
    final items = (map['total_items'] as num?)?.toDouble() ?? 0.0;
    final avg = txns > 0 ? revenue / txns : 0.0;

    return SalesSummaryModel(
      totalRevenue: revenue,
      totalTransactions: txns,
      totalItemsSold: items,
      averageTransactionValue: avg,
      revenueByPaymentMethod: paymentMethods,
      period: period,
    );
  }
}
