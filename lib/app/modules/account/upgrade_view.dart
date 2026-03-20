import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../data/services/supabase_service.dart';

class UpgradeView extends StatelessWidget {
  const UpgradeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.t1),
                    onPressed: () => Get.back(),
                  ),
                  Text('Upgrade', style: AppTextStyles.cardTitle),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Current plan
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CURRENT PLAN',
                              style: AppTextStyles.sectionLabel),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                            SupabaseService.to.activePlan.value
                                    .capitalizeFirst ??
                                'Free',
                            style: AppTextStyles.screenTitle
                                .copyWith(color: AppColors.accText),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Usage stats
                    Obx(() {
                      final usage = SupabaseService.to.orgUsage.value;
                      if (usage == null) {
                        return GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: AppColors.t4, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('Usage data unavailable',
                                    style: AppTextStyles.bodySecondary.copyWith(
                                        color: AppColors.t4)),
                              ),
                              TextButton(
                                onPressed: () =>
                                    SupabaseService.to.loadOrgUsage(),
                                child: Text('Retry',
                                    style: AppTextStyles.caption
                                        .copyWith(color: AppColors.accText)),
                              ),
                            ],
                          ),
                        );
                      }
                      return GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('USAGE', style: AppTextStyles.sectionLabel),
                            const SizedBox(height: 16),
                            _UsageStat(
                                label: 'Members',
                                usage:
                                    usage['members'] as Map<String, dynamic>?),
                            const SizedBox(height: 12),
                            _UsageStat(
                                label: 'Items',
                                usage:
                                    usage['items'] as Map<String, dynamic>?),
                            const SizedBox(height: 12),
                            _UsageStat(
                                label: 'Projects',
                                usage: usage['projects']
                                    as Map<String, dynamic>?),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Plan comparison
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pro Plan includes',
                              style: AppTextStyles.itemName),
                          const SizedBox(height: 16),
                          _PlanFeature(label: 'Unlimited items'),
                          _PlanFeature(label: 'Unlimited projects'),
                          _PlanFeature(label: 'Up to 50 members'),
                          _PlanFeature(label: 'Multi-org support'),
                          _PlanFeature(label: 'Priority support'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CTA
                    Material(
                      color: AppColors.acc,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          Get.snackbar(
                            'Coming Soon',
                            'Contact us at hello@ventry.app to upgrade',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.surface3,
                            colorText: AppColors.t1,
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          child: Center(
                            child: Text(
                              'Contact Us to Upgrade',
                              style: AppTextStyles.button,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageStat extends StatelessWidget {
  final String label;
  final Map<String, dynamic>? usage;

  const _UsageStat({required this.label, this.usage});

  @override
  Widget build(BuildContext context) {
    if (usage == null) return const SizedBox.shrink();
    final current = usage!['current'] as int? ?? 0;
    final limit = usage!['limit'] as int?;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Text(
          limit != null ? '$current / $limit' : '$current',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

class _PlanFeature extends StatelessWidget {
  final String label;
  const _PlanFeature({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.em, size: 18),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
