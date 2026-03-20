import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/glass_card.dart';

class ScannerSettingsView extends StatefulWidget {
  const ScannerSettingsView({super.key});

  @override
  State<ScannerSettingsView> createState() => _ScannerSettingsViewState();
}

class _ScannerSettingsViewState extends State<ScannerSettingsView> {
  final soundEnabled = true.obs;
  final vibrationEnabled = true.obs;
  final autoMode = false.obs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    soundEnabled.value = prefs.getBool('scanner_sound') ?? true;
    vibrationEnabled.value = prefs.getBool('scanner_vibration') ?? true;
    autoMode.value = prefs.getBool('scanner_auto_mode') ?? false;
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

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
            title: Text('Scanner Settings', style: AppTextStyles.cardTitle),
            centerTitle: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('FEEDBACK', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 12),
                  Obx(() => GlassCard(
                    child: SwitchListTile(
                      title: Text('Sound', style: AppTextStyles.body),
                      subtitle: Text('Play a beep on successful scan',
                          style: AppTextStyles.caption),
                      value: soundEnabled.value,
                      onChanged: (v) {
                        soundEnabled.value = v;
                        _saveBool('scanner_sound', v);
                      },
                      activeThumbColor: AppColors.acc,
                      inactiveTrackColor: AppColors.surface3,
                    ),
                  )),
                  const SizedBox(height: 10),
                  Obx(() => GlassCard(
                    child: SwitchListTile(
                      title: Text('Vibration', style: AppTextStyles.body),
                      subtitle: Text('Vibrate on successful scan',
                          style: AppTextStyles.caption),
                      value: vibrationEnabled.value,
                      onChanged: (v) {
                        vibrationEnabled.value = v;
                        _saveBool('scanner_vibration', v);
                      },
                      activeThumbColor: AppColors.acc,
                      inactiveTrackColor: AppColors.surface3,
                    ),
                  )),
                  const SizedBox(height: 24),
                  Text('BEHAVIOUR', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 12),
                  Obx(() => GlassCard(
                    child: SwitchListTile(
                      title: Text('Auto Mode', style: AppTextStyles.body),
                      subtitle: Text(
                          'Automatically process scans without confirmation',
                          style: AppTextStyles.caption),
                      value: autoMode.value,
                      onChanged: (v) {
                        autoMode.value = v;
                        _saveBool('scanner_auto_mode', v);
                      },
                      activeThumbColor: AppColors.acc,
                      inactiveTrackColor: AppColors.surface3,
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
