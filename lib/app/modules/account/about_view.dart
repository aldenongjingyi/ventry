import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.canvas,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.t1),
              onPressed: () => Get.back(),
            ),
            title: Text('About', style: AppTextStyles.cardTitle),
            centerTitle: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // App icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.acc,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(Icons.inventory_2_rounded,
                          color: AppColors.textOnPrimary, size: 36),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ventry',
                    style: AppTextStyles.screenTitle.copyWith(color: AppColors.t1),
                  ),
                  const SizedBox(height: 4),
                  Text('Version 1.0.0',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 32),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Ventry is an equipment tracking app designed for field teams. '
                      'Manage your inventory with QR codes, track item locations across projects, '
                      'and keep your team in sync with real-time updates.',
                      style: AppTextStyles.bodySecondary.copyWith(height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Platform', value: 'Flutter'),
                        _InfoRow(label: 'Backend', value: 'Supabase'),
                        _InfoRow(label: 'License', value: 'Proprietary'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(value,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.t2)),
        ],
      ),
    );
  }
}
