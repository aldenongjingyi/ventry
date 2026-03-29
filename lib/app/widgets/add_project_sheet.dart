import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../modules/items/items_controller.dart';
import '../modules/projects/projects_controller.dart';

/// Project icon options.
const _projectIcons = <String, IconData>{
  'folder': Icons.folder_outlined,
  'construction': Icons.construction_outlined,
  'apartment': Icons.apartment_outlined,
  'home': Icons.home_work_outlined,
  'warehouse': Icons.warehouse_outlined,
  'factory': Icons.factory_outlined,
  'store': Icons.store_outlined,
  'engineering': Icons.engineering_outlined,
  'electrical': Icons.electrical_services_outlined,
  'plumbing': Icons.plumbing_outlined,
  'landscape': Icons.landscape_outlined,
  'solar': Icons.solar_power_outlined,
  'event': Icons.event_outlined,
  'local_shipping': Icons.local_shipping_outlined,
  'handyman': Icons.handyman_outlined,
  'build': Icons.build_outlined,
};

/// Shows the Add Project bottom sheet. Call from anywhere.
void showAddProjectSheet(BuildContext context, {VoidCallback? onCreated}) {
  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final isSubmitting = false.obs;
  final selectedIcon = Rxn<String>();
  final startDate = Rxn<DateTime>();
  final dueDate = Rxn<DateTime>();
  final assignedItemIds = <String>{}.obs;
  final nameError = ''.obs;
  final projectsCtrl = Get.find<ProjectsController>();

  // Debounce name validation
  nameCtrl.addListener(() {
    final name = nameCtrl.text.trim();
    if (name.isNotEmpty &&
        projectsCtrl.projects.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      nameError.value = 'A project with this name already exists';
    } else {
      nameError.value = '';
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
            // Handle
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
            Text('New Project', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text('Create a project to organize items',
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 24),

            // Name with inline error
            _buildTextField(nameCtrl, 'Project Name', 'e.g. Building A Renovation',
                autofocus: true),
            if (nameError.value.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(nameError.value,
                  style: AppTextStyles.micro.copyWith(color: AppColors.reText)),
            ],
            const SizedBox(height: 16),

            // Location
            _buildTextField(locationCtrl, 'Location (optional)', 'e.g. 123 Main St'),
            const SizedBox(height: 16),

            // Icon picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Project Icon',
                    style: AppTextStyles.caption.copyWith(color: AppColors.t2)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // None
                    _IconOption(
                      icon: Icons.close,
                      isSelected: selectedIcon.value == null,
                      onTap: () => selectedIcon.value = null,
                      isEmpty: true,
                    ),
                    ..._projectIcons.entries.map((e) => _IconOption(
                      icon: e.value,
                      isSelected: selectedIcon.value == e.key,
                      onTap: () => selectedIcon.value = e.key,
                    )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dates row
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Start Date',
                    date: startDate.value,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: startDate.value ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        builder: (context, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.acc,
                              surface: AppColors.surface1,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) startDate.value = picked;
                    },
                    onClear: () => startDate.value = null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Due Date',
                    date: dueDate.value,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: dueDate.value ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        builder: (context, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.acc,
                              surface: AppColors.surface1,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) dueDate.value = picked;
                    },
                    onClear: () => dueDate.value = null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            _buildTextField(descCtrl, 'Description (optional)', 'Project scope or notes',
                maxLines: 3),
            const SizedBox(height: 16),

            // Assign items
            _AssignItemsSection(assignedItemIds: assignedItemIds),
            const SizedBox(height: 24),

            // Submit
            _buildSubmitButton(
              label: 'Create Project',
              isSubmitting: isSubmitting.value,
              onTap: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty || nameError.value.isNotEmpty) return;
                isSubmitting.value = true;
                final success = await projectsCtrl.createProject(
                  name,
                  location: locationCtrl.text.trim().isEmpty
                      ? null : locationCtrl.text.trim(),
                  icon: selectedIcon.value,
                  description: descCtrl.text.trim().isEmpty
                      ? null : descCtrl.text.trim(),
                  startDate: startDate.value,
                  dueDate: dueDate.value,
                  assignItemIds: assignedItemIds.toList(),
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

// ─── Helpers ───────────────────────────────────────────────────────────

Widget _buildTextField(
  TextEditingController ctrl,
  String label,
  String? hint, {
  bool autofocus = false,
  int maxLines = 1,
}) {
  return TextField(
    controller: ctrl,
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
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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

// ─── Widgets ───────────────────────────────────────────────────────────

class _IconOption extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isEmpty;

  const _IconOption({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accBg : AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.acc : AppColors.border1,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: isEmpty ? 16 : 20,
          color: isSelected ? AppColors.acc : (isEmpty ? AppColors.t5 : AppColors.t3),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.t2)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border2, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: date != null ? AppColors.acc : AppColors.t5,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? DateFormat.yMMMd().format(date!) : 'Not set',
                    style: AppTextStyles.caption.copyWith(
                      color: date != null ? AppColors.t1 : AppColors.t5,
                    ),
                  ),
                ),
                if (date != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(Icons.close, size: 14, color: AppColors.t4),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AssignItemsSection extends StatelessWidget {
  final RxSet<String> assignedItemIds;

  const _AssignItemsSection({required this.assignedItemIds});

  @override
  Widget build(BuildContext context) {
    final itemsCtrl = Get.find<ItemsController>();
    // Only show items in storage (available to assign)
    final available = itemsCtrl.items.where((i) => i.isInStorage).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Assign Items', style: AppTextStyles.caption.copyWith(color: AppColors.t2)),
            const Spacer(),
            Obx(() => assignedItemIds.isNotEmpty
                ? Text(
                    '${assignedItemIds.length} selected',
                    style: AppTextStyles.micro.copyWith(color: AppColors.accText),
                  )
                : const SizedBox.shrink()),
          ],
        ),
        const SizedBox(height: 8),
        if (available.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text('No items in storage to assign',
                style: AppTextStyles.caption.copyWith(color: AppColors.t5)),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 160),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border2, width: 0.5),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: available.length,
              itemBuilder: (context, index) {
                final item = available[index];
                return Obx(() {
                  final selected = assignedItemIds.contains(item.id);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (selected) {
                        assignedItemIds.remove(item.id);
                      } else {
                        assignedItemIds.add(item.id);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      color: selected
                          ? AppColors.accBg.withValues(alpha: 0.3)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: AppTextStyles.body.copyWith(fontSize: 13)),
                                if (item.sequentialId != null)
                                  Text(item.displayId,
                                      style: AppTextStyles.micro.copyWith(color: AppColors.t5)),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.em : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: selected ? AppColors.em : AppColors.border2,
                                width: selected ? 0 : 1.5,
                              ),
                            ),
                            child: selected
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
      ],
    );
  }
}
