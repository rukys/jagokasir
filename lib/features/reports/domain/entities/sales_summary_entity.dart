import 'date_range.dart';

class SalesSummaryEntity {
  final double totalRevenue;
  final int totalTransactions;
  final double totalItemsSold; // REAL type in database for stock/qty supports decimal
  final double averageTransactionValue;
  final Map<String, double> revenueByPaymentMethod;
  final DateRange period;

  const SalesSummaryEntity({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.totalItemsSold,
    required this.averageTransactionValue,
    required this.revenueByPaymentMethod,
    required this.period,
  });
}
