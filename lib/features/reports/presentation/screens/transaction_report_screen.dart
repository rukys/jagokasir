// lib/features/reports/presentation/screens/transaction_report_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/staff_provider.dart';
import '../../../cashier/domain/entities/transaction_entity.dart';
import '../../../cashier/presentation/providers/transaction_provider.dart';
import '../providers/report_provider.dart';
import '../widgets/report_period_selector.dart';

class TransactionReportScreen extends ConsumerStatefulWidget {
  const TransactionReportScreen({super.key});

  @override
  ConsumerState<TransactionReportScreen> createState() => _TransactionReportScreenState();
}

class _TransactionReportScreenState extends ConsumerState<TransactionReportScreen> {
  String? _selectedStaffId;
  TransactionStatus? _selectedStatus;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  String _formatIdr(double val) {
    final str = val.toStringAsFixed(0);
    final sb = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      sb.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        sb.write('.');
      }
    }
    return 'Rp ${sb.toString().split('').reversed.join('')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(currentStaffProvider);
    final dateRange = ref.watch(currentReportDateRangeProvider);
    final staffsAsync = ref.watch(staffListProvider);

    final transactionsAsync = ref.watch(
      transactionListProvider(
        status: _selectedStatus,
        query: _searchQuery.isEmpty ? null : _searchQuery,
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
    );

    final isOwnerOrAdmin = staff?.role == StaffRole.owner || staff?.role == StaffRole.admin;

    // Filter staff in Dart side if needed
    final List<TransactionEntity> displayedTransactions = transactionsAsync.maybeWhen(
      data: (list) {
        if (!isOwnerOrAdmin) {
          // Kasir can only see their own transactions (already handled in Usecase, but filter here for safety)
          return list.where((t) => t.staffId == staff?.id).toList();
        }
        if (_selectedStaffId != null) {
          return list.where((t) => t.staffId == _selectedStaffId).toList();
        }
        return list;
      },
      orElse: () => [],
    );

    final exportState = ref.watch(exportReportNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.onBackground,
        actions: [
          if (exportState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Export CSV',
              onPressed: () async {
                if (displayedTransactions.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tidak ada transaksi untuk diekspor')),
                  );
                  return;
                }
                final dateStr = DateTime.now().toIso8601String().split('T').first;
                await ref.read(exportReportNotifierProvider.notifier).exportTransactionsCsv(
                      transactions: displayedTransactions,
                      fileName: 'laporan_transaksi_$dateStr.csv',
                    );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.pagePadding,
                right: AppSpacing.pagePadding,
                top: AppSpacing.md,
              ),
              child: ReportPeriodSelector(),
            ),
            // Filter section card
            _buildFilterCard(isOwnerOrAdmin, staffsAsync),

            // Search bar input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.xs),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nomor invoice...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppSpacing.md),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const Gap(AppSpacing.sm),

            // List area
            Expanded(
              child: transactionsAsync.when(
                data: (_) {
                  if (displayedTransactions.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                    itemCount: displayedTransactions.length,
                    itemBuilder: (context, index) {
                      final txn = displayedTransactions[index];
                      return _buildTransactionItem(txn);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => Center(child: Text('Gagal memuat transaksi: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard(bool isOwnerOrAdmin, AsyncValue<List<StaffEntity>> staffsAsync) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.pagePadding),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Status Filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status Transaksi', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    const Gap(AppSpacing.xs),
                    DropdownButtonFormField<TransactionStatus?>(
                      initialValue: _selectedStatus,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Semua Status')),
                        DropdownMenuItem(value: TransactionStatus.completed, child: Text('Selesai')),
                        DropdownMenuItem(value: TransactionStatus.voided, child: Text('Void / Batal')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedStatus = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.md),

              // Staff Filter (Only enabled for owner/admin)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Staf Kasir', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    const Gap(AppSpacing.xs),
                    staffsAsync.when(
                      data: (staffs) {
                        return DropdownButtonFormField<String?>(
                          initialValue: _selectedStaffId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                            border: const OutlineInputBorder(),
                            enabled: isOwnerOrAdmin,
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Semua Staf')),
                            ...staffs.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                          ],
                          onChanged: isOwnerOrAdmin
                              ? (val) {
                                  setState(() {
                                    _selectedStaffId = val;
                                  });
                                }
                              : null,
                        );
                      },
                      loading: () => DropdownButtonFormField<String?>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: const [DropdownMenuItem(value: null, child: Text('Memuat...'))],
                        onChanged: null,
                      ),
                      error: (_, __) => DropdownButtonFormField<String?>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: const [DropdownMenuItem(value: null, child: Text('Gagal memuat'))],
                        onChanged: null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionEntity txn) {
    final isVoided = txn.status == TransactionStatus.voided;
    final dateStr = '${txn.createdAt.day.toString().padLeft(2, '0')}/${txn.createdAt.month.toString().padLeft(2, '0')}/${txn.createdAt.year} ${txn.createdAt.hour.toString().padLeft(2, '0')}:${txn.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5), width: 0.8),
      ),
      child: ListTile(
        onTap: () {
          // Go to transaction detail
          context.push(AppRoutes.transactionDetail.replaceAll(':id', txn.id));
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        title: Row(
          children: [
            Expanded(
              child: Text(
                txn.invoiceNumber,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
            ),
            _buildStatusBadge(txn.status),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
              const Gap(AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 12, color: AppColors.onSurfaceVariant),
                  const Gap(AppSpacing.xs),
                  Text(
                    txn.staffName ?? 'Staff',
                    style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                  const Gap(AppSpacing.md),
                  const Icon(Icons.payment_rounded, size: 12, color: AppColors.onSurfaceVariant),
                  const Gap(AppSpacing.xs),
                  Text(
                    txn.paymentMethod.name.toUpperCase(),
                    style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatIdr(txn.total),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isVoided ? AppColors.error : AppColors.primary,
                decoration: isVoided ? TextDecoration.lineThrough : null,
              ),
            ),
            const Gap(AppSpacing.xs),
            Text(
              '${txn.items.length} item',
              style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    final isVoided = status == TransactionStatus.voided;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: isVoided ? AppColors.errorContainer : AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        isVoided ? 'VOID' : 'SELESAI',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isVoided ? AppColors.onErrorContainer : AppColors.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.outlineVariant),
          Gap(AppSpacing.md),
          Text(
            'Tidak ada transaksi',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
          ),
          Gap(AppSpacing.xs),
          Text(
            'Ubah filter atau buat transaksi baru di mesin kasir.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
