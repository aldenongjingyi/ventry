import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/item_model.dart';

/// Renders a single QR label tile as a PNG image and shares it.
Future<void> shareQrLabel(ItemModel item) async {
  final bytes = await _renderSingleLabel(item);
  if (bytes == null) return;
  await _shareBytes(bytes, 'ventry_label_${item.itemNumber}.png');
}

/// Renders a grid of QR label tiles as a single PNG and shares it.
Future<void> shareBulkQrLabels(List<ItemModel> items) async {
  final bytes = await _renderBulkLabels(items);
  if (bytes == null) return;
  await _shareBytes(bytes, 'ventry_labels.png');
}

Future<void> _shareBytes(List<int> bytes, String filename) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes);
  await Share.shareXFiles([XFile(file.path)]);
}

Future<List<int>?> _renderSingleLabel(ItemModel item) async {
  const double size = 600;
  final widget = _SingleLabelWidget(item: item);
  return _renderWidgetToPng(widget, size, size);
}

Future<List<int>?> _renderBulkLabels(List<ItemModel> items) async {
  const double tileSize = 600;
  const int columns = 4;
  final rows = (items.length / columns).ceil();
  final width = tileSize * columns;
  final height = tileSize * rows;
  final widget = _BulkLabelGrid(items: items, columns: columns, tileSize: tileSize);
  return _renderWidgetToPng(widget, width, height);
}

Future<List<int>?> _renderWidgetToPng(
    Widget widget, double width, double height) async {
  final repaintBoundary = RenderRepaintBoundary();
  final view = ui.PlatformDispatcher.instance.implicitView!;
  final renderView = RenderView(
    view: view,
    child: RenderPositionedBox(
      alignment: Alignment.center,
      child: repaintBoundary,
    ),
    configuration: ViewConfiguration(
      logicalConstraints: BoxConstraints.tight(Size(width, height)),
      devicePixelRatio: 1.0,
    ),
  );

  final pipelineOwner = PipelineOwner();
  final buildOwner = BuildOwner(focusManager: FocusManager());

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: width,
          height: height,
          child: widget,
        ),
      ),
    ),
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);
  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final image = await repaintBoundary.toImage(pixelRatio: 1.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  buildOwner.finalizeTree();

  return byteData?.buffer.asUint8List();
}

class _SingleLabelWidget extends StatelessWidget {
  final ItemModel item;
  const _SingleLabelWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 600,
      color: Colors.white,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImageView(
            data: item.qrCode,
            version: QrVersions.auto,
            size: 380,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 24),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              decoration: TextDecoration.none,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            '#VT-${item.itemNumber.toString().padLeft(3, '0')}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
              decoration: TextDecoration.none,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Ventry',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: 0.3),
              decoration: TextDecoration.none,
              fontFamily: 'Inter',
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BulkLabelGrid extends StatelessWidget {
  final List<ItemModel> items;
  final int columns;
  final double tileSize;

  const _BulkLabelGrid({
    required this.items,
    required this.columns,
    required this.tileSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: List.generate(
          (items.length / columns).ceil(),
          (row) => Row(
            children: List.generate(
              columns,
              (col) {
                final index = row * columns + col;
                if (index >= items.length) {
                  return SizedBox(width: tileSize, height: tileSize);
                }
                return SizedBox(
                  width: tileSize,
                  height: tileSize,
                  child: _BulkTile(item: items[index]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BulkTile extends StatelessWidget {
  final ItemModel item;
  const _BulkTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImageView(
            data: item.qrCode,
            version: QrVersions.auto,
            size: 380,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              decoration: TextDecoration.none,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '#VT-${item.itemNumber.toString().padLeft(3, '0')}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
              decoration: TextDecoration.none,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Ventry',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: 0.3),
              decoration: TextDecoration.none,
              fontFamily: 'Inter',
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
