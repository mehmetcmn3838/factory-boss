import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../systems/factory_controller.dart';

class WarehouseComponent extends PositionComponent {
  WarehouseComponent(this.controller) : super(priority: 3);

  final FactoryController controller;
  final _label = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
  );

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF384B54),
    );
    canvas.drawRect(
      Rect.fromLTWH(7, 28, size.x - 14, size.y - 36),
      Paint()..color = const Color(0xFF1B252A),
    );
    final fill = controller.data.storedParts / controller.data.warehouseCapacity;
    canvas.drawRect(
      Rect.fromLTWH(7, size.y - 8 - ((size.y - 36) * fill),
          size.x - 14, (size.y - 36) * fill),
      Paint()..color = const Color(0xFFD8952E),
    );
    _label.render(canvas, 'WAREHOUSE', Vector2(8, 7));
    _label.render(
      canvas,
      '${controller.data.storedParts}/${controller.data.warehouseCapacity}',
      Vector2(8, size.y - 24),
    );
    super.render(canvas);
  }
}
