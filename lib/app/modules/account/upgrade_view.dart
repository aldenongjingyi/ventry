import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_background.dart';
import '../../data/services/supabase_service.dart';

class UpgradeView extends StatelessWidget {
  const UpgradeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlassBackground(
        style: GlassBackgroundStyle.minimal,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary),
                      onPressed: () => Get.back(),
                    ),
                    Text('Upgrade', style: AppTextStyles.h3),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Current plan
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Plan',
                                style: AppTextStyles.captionMedium),
                            const SizedBox(height: 8),
                            Obx(() => ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.goldShimmer.createShader(bounds),
                              child: Text(
                                SupabaseService.to.activePlan.value
                                        .capitalizeFirst ??
                                    'Free',
                                style: AppTextStyles.h2
                                    .copyWith(color: Colors.white),
                              ),
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
                                Icon(Icons.info_outline,
                                    color: AppColors.textTertiary, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text('Usage data unavailable',
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textTertiary)),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      SupabaseService.to.loadOrgUsage(),
                                  child: Text('Retry',
                                      style: AppTextStyles.captionMedium
                                          .copyWith(color: AppColors.primary)),
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
                              Text('Usage', style: AppTextStyles.captionMedium),
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
                                style: AppTextStyles.subtitle),
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
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: AppColors.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              Get.snackbar(
                                'Coming Soon',
                                'Contact us at hello@ventry.app to upgrade',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.surfaceElevated,
                                colorText: AppColors.textPrimary,
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: Text(
                                  'Contact Us to Upgrade',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textOnPrimary,
                                  ),
                                ),
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
        Text(label, style: AppTextStyles.bodyMedium),
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
          Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
