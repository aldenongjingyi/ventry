import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/item_model.dart';
import '../../data/repositories/item_repository.dart';
import '../../theme/app_colors.dart';

class ScanController extends GetxController {
  final _repo = ItemRepository();
  final scannedItem = Rxn<ItemModel>();
  final isProcessing = false.obs;
  final lookupFailed = false.obs;
  final scannerMode = 'smart'.obs; // quick, smart, manual

  @override
  void onInit() {
    super.onInit();
    ever(lookupFailed, (failed) {
      if (failed) {
        Get.snackbar(
          'Lookup failed',
          'Check your connection and try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.surface3,
          colorText: AppColors.reText,
          mainButton: TextButton(
            onPressed: () => Get.closeCurrentSnackbar(),
            child: Text('Dismiss',
                style: TextStyle(color: AppColors.t2)),
          ),
        );
      }
    });
  }

  Future<void> onBarcodeScanned(String code) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    lookupFailed.value = false;
    try {
      final item = await _repo.getByQrCode(code);
      scannedItem.value = item;
    } catch (_) {
      scannedItem.value = null;
      lookupFailed.value = true;
    } finally {
      isProcessing.value = false;
    }
  }

  void clearScannedItem() {
    scannedItem.value = null;
  }
}
