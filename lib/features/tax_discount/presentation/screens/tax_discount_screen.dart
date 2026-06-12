// lib/features/tax_discount/presentation/screens/tax_discount_screen.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/permission_guard.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import 'discount_presets_screen.dart';
import 'tax_settings_screen.dart';

class TaxDiscountScreen extends StatelessWidget {
  const TaxDiscountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      allowedRoles: const [StaffRole.owner, StaffRole.admin],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Pajak & Diskon'),
            bottom: const TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              tabs: [
                Tab(
                  icon: Icon(Icons.receipt_long_rounded),
                  text: 'Pajak',
                ),
                Tab(
                  icon: Icon(Icons.percent_rounded),
                  text: 'Preset Diskon',
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              TaxSettingsScreen(),
              DiscountPresetsScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
