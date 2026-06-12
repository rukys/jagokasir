import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/currency_display.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_provider.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  String _searchQuery = '';
  TransactionStatus? _selectedStatus;
  DateTimeRange? _dateRange;
  String _selectedRangeLabel = 'Hari Ini';

  @override
  void initState() {
    super.initState();
    _applyPresetRange('Hari Ini');
  }

  void _applyPresetRange(String label) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (label) {
      case 'Hari Ini':
        start = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);
        break;
      case 'Kemarin':
        final yesterday = now.subtract(const Duration(days: 1));
        start = DateTime(yesterday.year, yesterday.month, yesterday.day, 0, 0, 0, 0);
        end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59, 999);
        break;
      case '7 Hari':
        final sevenDaysAgo = now.subtract(const Duration(days: 6));
        start = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day, 0, 0, 0, 0);
        break;
      default:
        return;
    }

    setState(() {
      _selectedRangeLabel = label;
      _dateRange = DateTimeRange(start: start, end: end);
    });
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedRangeLabel = 'Custom';
        _dateRange = DateTimeRange(
          start: DateTime(picked.start.year, picked.start.month, picked.start.day, 0, 0, 0, 0),
          end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59, 999),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStaff = ref.watch(currentStaffProvider);

    final transactionsAsync = ref.watch(transactionListProvider(
      status: _selectedStatus,
      query: _searchQuery.isNotEmpty ? _searchQuery : null,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    ),);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: Column(
        children: [
          // Filter Panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Search field for invoice number
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Cari nomor invoice...',
                    prefixIcon: Icon(Icons.search_rounded),
                    contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Date Filter Presets
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Hari Ini', 'Kemarin', '7 Hari'].map((label) {
                            final isSelected = _selectedRangeLabel == label;
                            return Padding(
                              padding: const EdgeInsets.only(right: AppSpacing.xs),
                              child: ChoiceChip(
                                label: Text(label),
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) _applyPresetRange(label);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.date_range_rounded, color: AppColors.primary),
                      tooltip: 'Pilih rentang tanggal',
                      onPressed: () => _selectCustomDateRange(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Status segmented buttons
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<TransactionStatus?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('Semua')),
                      ButtonSegment(value: TransactionStatus.completed, label: Text('Berhasil')),
                      ButtonSegment(value: TransactionStatus.voided, label: Text('Batal (Void)')),
                    ],
                    selected: {_selectedStatus},
                    onSelectionChanged: (set) {
                      setState(() {
                        _selectedStatus = set.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Transactions List
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text('Gagal memuat transaksi: $e', style: const TextStyle(color: AppColors.danger)),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const EmptyState(
                    title: 'Tidak Ada Transaksi',
                    subtitle: 'Tidak ada data transaksi yang cocok dengan filter saat ini.',
                    icon: Icons.history_rounded,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final txn = transactions[index];
                    final isCompleted = txn.status == TransactionStatus.completed;

                    return Card(
                      child: InkWell(
                        onTap: () {
                          // Buka detail transaksi
                          context.push(AppRoutes.transactionDetail.replaceAll(':id', txn.id));
                        },
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Invoice & status badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    txn.invoiceNumber,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isCompleted ? AppColors.primary : AppColors.outline,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs / 2),
                                    decoration: BoxDecoration(
                                      color: isCompleted ? AppColors.successLight : AppColors.dangerLight,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                    ),
                                    child: Text(
                                      isCompleted ? 'COMPLETED' : 'VOIDED',
                                      style: TextStyle(
                                        color: isCompleted ? AppColors.success : AppColors.danger,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              // Date/Time
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 12, color: AppColors.outline),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    '${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year} ${txn.createdAt.hour.toString().padLeft(2, '0')}:${txn.createdAt.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.outline),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // Items summary & total price
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${txn.items.fold<double>(0, (sum, i) => sum + i.quantity).toStringAsFixed(0)} item belanja',
                                        style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                                      ),
                                      if (currentStaff?.role != StaffRole.kasir) ...[
                                        SizedBox(height: AppSpacing.xs / 2),
                                        Text(
                                          'Kasir: ${txn.staffName ?? "Staff"}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.outline),
                                        ),
                                      ],
                                    ],
                                  ),
                                  CurrencyDisplay(
                                    amount: txn.total,
                                    style: CurrencyDisplayStyle.normal,
                                    color: isCompleted ? AppColors.primary : AppColors.outline,
                                    strikethrough: !isCompleted,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
