import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../modules/items/items_controller.dart';

/// Shows the Add Item bottom sheet. Call from anywhere.
///
/// [onCreated] is called after items are successfully created.
void showAddItemSheet(BuildContext context, {VoidCallback? onCreated}) {
  final nameCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final newGroupCtrl = TextEditingController();
  final isSubmitting = false.obs;
  final quantity = 1.obs;
  final selectedColor = Rxn<String>();
  final selectedGroupId = Rxn<String>();
  final isCreatingGroup = false.obs;
  final itemsCtrl = Get.find<ItemsController>();

  // Visual state: 'none', 'icon', 'photo'
  final visualType = 'none'.obs;
  final selectedIcon = Rxn<String>();
  final photoBytes = Rxn<Uint8List>();
  final existingPhotoUrl = Rxn<String>();
  final autoPopulated = false.obs;

  // Auto-populate visual when name changes
  nameCtrl.addListener(() {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      if (autoPopulated.value) {
        visualType.value = 'none';
        selectedIcon.value = null;
        photoBytes.value = null;
        existingPhotoUrl.value = null;
        autoPopulated.value = false;
      }
      return;
    }
    final visual = itemsCtrl.getVisual(name);
    if (visual != null && !autoPopulated.value) {
      autoPopulated.value = true;
      if (visual.isIcon) {
        visualType.value = 'icon';
        selectedIcon.value = visual.visualValue;
      } else {
        visualType.value = 'photo';
        existingPhotoUrl.value = visual.visualValue;
      }
    }
  });

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Obx(() => SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Add Item', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text('Create items to track', style: AppTextStyles.bodySecondary),
            const SizedBox(height: 24),

            // Name
            _buildTextField(nameCtrl, 'Item Name', 'e.g. Drill, Safety Harness',
                autofocus: true),
            const SizedBox(height: 16),

            // Visual picker
            _VisualPicker(
              visualType: visualType,
              selectedIcon: selectedIcon,
              photoBytes: photoBytes,
              existingPhotoUrl: existingPhotoUrl,
            ),
            const SizedBox(height: 16),

            // Quantity
            Row(
              children: [
                Text('Quantity', style: AppTextStyles.caption.copyWith(color: AppColors.t2)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showQuantityPicker(ctx, quantity),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border2, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${quantity.value}',
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.unfold_more_rounded, size: 16, color: AppColors.t4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Label color
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Label Color', style: AppTextStyles.caption.copyWith(color: AppColors.t2)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ColorDot(
                      color: AppColors.surface2,
                      isSelected: selectedColor.value == null,
                      onTap: () => selectedColor.value = null,
                      borderColor: AppColors.border2,
                      child: const Icon(Icons.close, size: 14, color: AppColors.t4),
                    ),
                    ..._labelColors.entries.map((entry) =>
                      _ColorDot(
                        color: entry.value,
                        isSelected: selectedColor.value == entry.key,
                        onTap: () => selectedColor.value = entry.key,
                        borderColor: entry.key == 'black'
                            ? AppColors.border3
                            : Colors.transparent,
                      ),
                    ),
                    _ColorDot(
                      color: selectedColor.value != null &&
                              !_labelColors.containsKey(selectedColor.value)
                          ? _parseHexColor(selectedColor.value!)
                          : AppColors.surface2,
                      isSelected: selectedColor.value != null &&
                          !_labelColors.containsKey(selectedColor.value),
                      onTap: () => _showColorWheelPicker(ctx, selectedColor),
                      borderColor: AppColors.border2,
                      child: selectedColor.value != null &&
                              !_labelColors.containsKey(selectedColor.value)
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : ShaderMask(
                              shaderCallback: (bounds) => const SweepGradient(
                                colors: [
                                  Colors.red, Colors.yellow, Colors.green,
                                  Colors.cyan, Colors.blue, Colors.purple, Colors.red,
                                ],
                              ).createShader(bounds),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Item group (inline)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Group', style: AppTextStyles.caption.copyWith(color: AppColors.t2)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => isCreatingGroup.value = !isCreatingGroup.value,
                      child: Text(
                        isCreatingGroup.value ? 'Cancel' : '+ New',
                        style: AppTextStyles.caption.copyWith(color: AppColors.accText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isCreatingGroup.value) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(newGroupCtrl, 'Group name', 'e.g. Power Tools'),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: AppColors.acc,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () async {
                            final name = newGroupCtrl.text.trim();
                            if (name.isEmpty) return;
                            final group = await itemsCtrl.createItemGroup(name);
                            selectedGroupId.value = group.id;
                            newGroupCtrl.clear();
                            isCreatingGroup.value = false;
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            child: Text('Add', style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _GroupChip(
                      label: 'None',
                      isSelected: selectedGroupId.value == null,
                      onTap: () => selectedGroupId.value = null,
                    ),
                    ...itemsCtrl.itemGroups.map((group) =>
                      _GroupChip(
                        label: group.name,
                        isSelected: selectedGroupId.value == group.id,
                        onTap: () => selectedGroupId.value = group.id,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes
            _buildTextField(notesCtrl, 'Notes (optional)', null, maxLines: 2),
            const SizedBox(height: 24),

            _buildSubmitButton(
              label: quantity.value > 1
                  ? 'Create ${quantity.value} Items'
                  : 'Create Item',
              isSubmitting: isSubmitting.value,
              onTap: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                isSubmitting.value = true;

                // Save visual if set
                try {
                  if (visualType.value == 'icon' && selectedIcon.value != null) {
                    await itemsCtrl.setItemIcon(name, selectedIcon.value!);
                  } else if (visualType.value == 'photo' && photoBytes.value != null) {
                    await itemsCtrl.setItemPhoto(name, photoBytes.value!);
                  }
                } catch (_) {
                  // Visual save failure shouldn't block item creation
                }

                final success = await itemsCtrl.createItems(
                  name: name,
                  quantity: quantity.value,
                  labelColor: selectedColor.value,
                  itemGroupId: selectedGroupId.value,
                  notes: notesCtrl.text.trim().isEmpty
                      ? null
                      : notesCtrl.text.trim(),
                );
                isSubmitting.value = false;
                if (success) {
                  onCreated?.call();
                  if (ctx.mounted) Navigator.of(ctx).pop();
                }
              },
            ),
          ],
        ),
      ),
    )),
  );
}

// ─── Constants ─────────────────────────────────────────────────────────

const _labelColors = <String, Color>{
  'red': Color(0xFFEF4444),
  'green': Color(0xFF22C55E),
  'blue': Color(0xFF3B82F6),
  'yellow': Color(0xFFEAB308),
  'pink': Color(0xFFEC4899),
  'cyan': Color(0xFF06B6D4),
  'white': Color(0xFFFFFFFF),
  'black': Color(0xFF000000),
};

/// Icons available for item visuals. Organized by common equipment categories.
const _availableIcons = <String, IconData>{
  // Tools
  'build': Icons.build_outlined,
  'handyman': Icons.handyman_outlined,
  'hardware': Icons.hardware_outlined,
  'construction': Icons.construction_outlined,
  'carpenter': Icons.carpenter_outlined,
  'plumbing': Icons.plumbing_outlined,

  // Electrical
  'electrical': Icons.electrical_services_outlined,
  'power': Icons.power_outlined,
  'cable': Icons.cable_outlined,
  'bolt': Icons.bolt_outlined,
  'flashlight': Icons.flashlight_on_outlined,

  // Safety
  'safety': Icons.health_and_safety_outlined,
  'shield': Icons.shield_outlined,
  'hard_hat': Icons.engineering_outlined,
  'fire_extinguisher': Icons.fire_extinguisher_outlined,
  'warning': Icons.warning_amber_outlined,

  // Measurement
  'straighten': Icons.straighten_outlined,
  'square_foot': Icons.square_foot_outlined,
  'speed': Icons.speed_outlined,
  'thermostat': Icons.thermostat_outlined,
  'scale': Icons.scale_outlined,

  // Transport / Heavy
  'local_shipping': Icons.local_shipping_outlined,
  'precision_manufacturing': Icons.precision_manufacturing_outlined,
  'agriculture': Icons.agriculture_outlined,
  'rv_hookup': Icons.rv_hookup_outlined,

  // Tech / Electronics
  'computer': Icons.computer_outlined,
  'phone': Icons.phone_android_outlined,
  'tablet': Icons.tablet_android_outlined,
  'camera': Icons.camera_alt_outlined,
  'router': Icons.router_outlined,
  'print': Icons.print_outlined,
  'headset': Icons.headset_outlined,
  'speaker': Icons.speaker_outlined,

  // Office / General
  'inventory': Icons.inventory_2_outlined,
  'chair': Icons.chair_outlined,
  'desk': Icons.desk_outlined,
  'light': Icons.light_outlined,
  'key': Icons.key_outlined,
  'lock': Icons.lock_outlined,
  'cleaning': Icons.cleaning_services_outlined,

  // Medical
  'medical': Icons.medical_services_outlined,
  'medication': Icons.medication_outlined,
  'monitor_heart': Icons.monitor_heart_outlined,

  // Outdoor
  'park': Icons.park_outlined,
  'water': Icons.water_drop_outlined,
  'solar': Icons.solar_power_outlined,
  'air': Icons.air_outlined,
};

// ─── Helpers ───────────────────────────────────────────────────────────

Color _parseHexColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}

Widget _buildTextField(
  TextEditingController textController,
  String label,
  String? hint, {
  bool autofocus = false,
  int maxLines = 1,
}) {
  return TextField(
    controller: textController,
    style: AppTextStyles.body,
    autofocus: autofocus,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppTextStyles.caption,
      hintStyle: AppTextStyles.caption.copyWith(color: AppColors.t5),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border2, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.acc, width: 1),
      ),
      filled: true,
      fillColor: AppColors.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

Widget _buildSubmitButton({
  required String label,
  required bool isSubmitting,
  required VoidCallback onTap,
}) {
  return Material(
    color: AppColors.acc,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: isSubmitting
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap();
            },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  )),
        ),
      ),
    ),
  );
}

// ─── Sub-sheets ────────────────────────────────────────────────────────

void _showQuantityPicker(BuildContext context, RxInt quantity) {
  final scrollCtrl = FixedExtentScrollController(
    initialItem: quantity.value - 1,
  );
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      height: 280,
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quantity', style: AppTextStyles.cardTitle),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Text('Done', style: AppTextStyles.body.copyWith(
                    color: AppColors.accText,
                    fontWeight: FontWeight.w600,
                  )),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border1, height: 1),
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: scrollCtrl,
              itemExtent: 44,
              physics: const FixedExtentScrollPhysics(),
              diameterRatio: 1.5,
              onSelectedItemChanged: (index) => quantity.value = index + 1,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 100,
                builder: (ctx, index) {
                  final val = index + 1;
                  return Center(
                    child: Obx(() => Text(
                      '$val',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 20,
                        fontWeight: val == quantity.value
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: val == quantity.value
                            ? AppColors.t1
                            : AppColors.t4,
                      ),
                    )),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showColorWheelPicker(BuildContext context, Rxn<String> selectedColor) {
  final currentColor = selectedColor.value != null &&
          !_labelColors.containsKey(selectedColor.value)
      ? _parseHexColor(selectedColor.value!)
      : AppColors.acc;
  var pickedColor = currentColor;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Custom Color', style: AppTextStyles.cardTitle),
              GestureDetector(
                onTap: () {
                  final hex = pickedColor.toARGB32().toRadixString(16).substring(2);
                  selectedColor.value = hex;
                  Navigator.of(ctx).pop();
                },
                child: Text('Done', style: AppTextStyles.body.copyWith(
                  color: AppColors.accText,
                  fontWeight: FontWeight.w600,
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ColorPicker(
            color: currentColor,
            onColorChanged: (color) => pickedColor = color,
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.wheel: true,
              ColorPickerType.primary: false,
              ColorPickerType.accent: false,
            },
            wheelDiameter: 220,
            wheelWidth: 20,
            enableShadesSelection: true,
            columnSpacing: 16,
            heading: null,
            subheading: Text('Shade', style: AppTextStyles.caption.copyWith(color: AppColors.t3)),
          ),
        ],
      ),
    ),
  );
}

void _showIconPicker(BuildContext context, Rxn<String> selectedIcon, RxString visualType) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      height: MediaQuery.of(ctx).size.height * 0.55,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Choose Icon', style: AppTextStyles.cardTitle),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Text('Done', style: AppTextStyles.body.copyWith(
                  color: AppColors.accText,
                  fontWeight: FontWeight.w600,
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (_, index) {
                final entry = _availableIcons.entries.elementAt(index);
                return Obx(() {
                  final isSelected = selectedIcon.value == entry.key;
                  return GestureDetector(
                    onTap: () {
                      selectedIcon.value = entry.key;
                      visualType.value = 'icon';
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accBg : AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.acc : AppColors.border1,
                          width: isSelected ? 2 : 0.5,
                        ),
                      ),
                      child: Icon(
                        entry.value,
                        size: 24,
                        color: isSelected ? AppColors.acc : AppColors.t3,
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Widgets ───────────────────────────────────────────────────────────

class _VisualPicker extends StatelessWidget {
  final RxString visualType;
  final Rxn<String> selectedIcon;
  final Rxn<Uint8List> photoBytes;
  final Rxn<String> existingPhotoUrl;

  const _VisualPicker({
    required this.visualType,
    required this.selectedIcon,
    required this.photoBytes,
    required this.existingPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item Visual', style: AppTextStyles.caption.copyWith(color: AppColors.t2)),
        const SizedBox(height: 8),
        Row(
          children: [
            // Preview
            Obx(() => _buildPreview()),
            const SizedBox(width: 12),
            // Actions
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _VisualOptionChip(
                    icon: Icons.grid_view_rounded,
                    label: 'Icon',
                    onTap: () => _showIconPicker(context, selectedIcon, visualType),
                  ),
                  _VisualOptionChip(
                    icon: Icons.camera_alt_rounded,
                    label: 'Photo',
                    onTap: () => _pickPhoto(ImageSource.camera),
                  ),
                  _VisualOptionChip(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () => _pickPhoto(ImageSource.gallery),
                  ),
                  Obx(() => visualType.value != 'none'
                    ? _VisualOptionChip(
                        icon: Icons.close,
                        label: 'Clear',
                        onTap: () {
                          visualType.value = 'none';
                          selectedIcon.value = null;
                          photoBytes.value = null;
                          existingPhotoUrl.value = null;
                        },
                      )
                    : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    Widget content;
    if (visualType.value == 'icon' && selectedIcon.value != null) {
      final iconData = _availableIcons[selectedIcon.value];
      content = Icon(iconData ?? Icons.inventory_2_outlined, size: 28, color: AppColors.acc);
    } else if (visualType.value == 'photo' && photoBytes.value != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(photoBytes.value!, fit: BoxFit.cover, width: 56, height: 56),
      );
    } else if (visualType.value == 'photo' && existingPhotoUrl.value != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: existingPhotoUrl.value!,
          fit: BoxFit.cover,
          width: 56,
          height: 56,
          placeholder: (context, url) => const Center(
            child: SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.t4)),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: AppColors.t4),
        ),
      );
    } else {
      content = const Icon(Icons.inventory_2_outlined, size: 28, color: AppColors.t4);
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Center(child: content),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, maxWidth: 512, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    photoBytes.value = bytes;
    existingPhotoUrl.value = null;
    visualType.value = 'photo';
  }
}

class _VisualOptionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _VisualOptionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.t3),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.t2)),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? child;
  final Color borderColor;

  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.child,
    this.borderColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? AppColors.acc : borderColor,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: isSelected && child == null
            ? Icon(Icons.check, size: 14,
                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white)
            : child != null
                ? Center(child: child)
                : null,
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accBg : AppColors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.acc : AppColors.border1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? AppColors.accText : AppColors.t2,
          ),
        ),
      ),
    );
  }
}
