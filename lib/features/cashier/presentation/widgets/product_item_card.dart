import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/currency_display.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../stock/domain/entities/stock_entity.dart';

class ProductItemCard extends StatelessWidget {
  const ProductItemCard({
    super.key,
    required this.product,
    required this.stock,
    required this.onTap,
    required this.onLongPress,
  });

  final ProductEntity product;
  final StockEntity stock;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  String _formatStock(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image / placeholder
            Expanded(
              child: Container(
                color: AppColors.primaryContainer.withValues(alpha: 0.15),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    product.sku,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  CurrencyDisplay(
                    amount: product.sellingPrice,
                    style: CurrencyDisplayStyle.small,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Stock alert badge
                  if (stock.trackStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm - 2,
                        vertical: AppSpacing.xs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: stock.isLowStock
                            ? AppColors.stockLowBg
                            : AppColors.stockOkBg,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        stock.isLowStock
                            ? 'Stok Rendah: ${_formatStock(stock.currentStock)}'
                            : 'Stok: ${_formatStock(stock.currentStock)}',
                        style: TextStyle(
                          color: stock.isLowStock
                              ? AppColors.stockLow
                              : AppColors.stockOk,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm - 2,
                        vertical: AppSpacing.xs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: const Text(
                        'Tanpa Stok',
                        style: TextStyle(
                          color: AppColors.outline,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
