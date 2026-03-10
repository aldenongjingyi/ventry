import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/models/equipment_model.dart';
import '../../data/services/scanner_service.dart';
import '../../routes/app_routes.dart';

class ScanController extends GetxController {
  final _scannerService = ScannerService.to;

  late final MobileScannerController cameraController;

  final isProcessing = false.obs;
  final lastScannedBarcode = ''.obs;
  final scanResult = Rxn<EquipmentModel>();
  final errorMessage = ''.obs;

  // Modes: 'lookup', 'checkout-add', 'checkin-add'
  String get mode => Get.arguments?['mode'] as String? ?? 'lookup';

  @override
  void onInit() {
    super.onInit();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  Future<void> onBarcodeDetected(BarcodeCapture capture) async {
    if (isProcessing.value) return;

    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode == lastScannedBarcode.value) return;

    isProcessing.value = true;
    lastScannedBarcode.value = barcode;
    errorMessage.value = '';

    try {
      final equipment = await _scannerService.lookupBarcode(barcode);

      if (equipment != null) {
        switch (mode) {
          case 'lookup':
            scanResult.value = equipment;
            cameraController.stop();
            Get.toNamed(
              AppRoutes.equipmentDetail,
              arguments: {'id': equipment.id},
            );
            break;
          case 'checkout-add':
          case 'checkin-add':
            Get.back(result: equipment);
            break;
        }
      } else {
        errorMessage.value = 'No equipment found for barcode: $barcode';
        await Future.delayed(const Duration(seconds: 2));
        errorMessage.value = '';
        lastScannedBarcode.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Scan failed. Try again.';
      await Future.delayed(const Duration(seconds: 2));
      errorMessage.value = '';
      lastScannedBarcode.value = '';
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}
