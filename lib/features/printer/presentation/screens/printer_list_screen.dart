// lib/features/printer/presentation/screens/printer_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/printer_entity.dart';
import '../providers/printer_provider.dart';
import 'add_printer_screen.dart';

class PrinterListScreen extends ConsumerWidget {
  const PrinterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(printerListProvider);
    final maintenanceState = ref.watch(printerMaintenanceNotifierProvider);
    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Printer'),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.onBackground,
          ),
          body: listAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text('Gagal memuat printer: $err', style: const TextStyle(color: AppColors.danger)),
              ),
            ),
            data: (list) {
              if (list.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final printer = list[index];
                  return _buildPrinterItem(context, ref, printer, theme);
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (context) => const AddPrinterScreen()),
              );
            },
            child: const Icon(Icons.add_rounded),
          ),
        ),
        if (maintenanceState is AsyncLoading)
          const LoadingOverlay(message: 'Memproses printer...'),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.print_disabled_rounded, size: 64, color: AppColors.outline),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Belum Ada Printer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.onSurface),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Tambah printer thermal (Bluetooth atau WiFi) untuk mencetak struk belanja Anda.',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Printer Baru'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => const AddPrinterScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrinterItem(BuildContext context, WidgetRef ref, PrinterEntity printer, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Dismissible(
          key: Key(printer.id),
          background: Container(
            color: AppColors.success,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: const Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.white),
                SizedBox(width: AppSpacing.sm),
                Text('Set Default', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          secondaryBackground: Container(
            color: AppColors.danger,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(width: AppSpacing.sm),
                Icon(Icons.delete_rounded, color: Colors.white),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Set Default
              final success = await ref.read(printerMaintenanceNotifierProvider.notifier).makeDefault(printer.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${printer.name} sekarang menjadi printer default')),
                );
              }
              return false; // Jangan hapus dari list visual secara permanen
            } else {
              // Hapus
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Printer'),
                  content: Text('Apakah Anda yakin ingin menghapus printer "${printer.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
            }
          },
          onDismissed: (direction) async {
            if (direction == DismissDirection.endToStart) {
              await ref.read(printerMaintenanceNotifierProvider.notifier).delete(printer.id);
            }
          },
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: printer.isDefault ? AppColors.primary : AppColors.outlineVariant,
                width: printer.isDefault ? 1.5 : 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => AddPrinterScreen(printer: printer)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    // Printer Icon with background
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: printer.isDefault ? AppColors.primaryContainer : AppColors.surfaceVariant.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        printer.type == PrinterType.bluetooth ? Icons.bluetooth_rounded : Icons.wifi_rounded,
                        color: printer.isDefault ? AppColors.primary : AppColors.onSurfaceVariant,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),

                    // Text Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  printer.name,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (printer.isDefault) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.roleOwnerBg,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                  ),
                                  child: const Text(
                                    'Default',
                                    style: TextStyle(
                                      color: AppColors.roleOwner,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            printer.address,
                            style: const TextStyle(fontSize: 12, color: AppColors.outline),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Type Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: printer.type == PrinterType.bluetooth ? AppColors.roleKasirBg : AppColors.roleAdminBg,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                ),
                                child: Text(
                                  printer.type.name.toUpperCase(),
                                  style: TextStyle(
                                    color: printer.type == PrinterType.bluetooth ? AppColors.roleKasir : AppColors.roleAdmin,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),

                              // Paper Width Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                ),
                                child: Text(
                                  '${printer.paperWidth} mm',
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
