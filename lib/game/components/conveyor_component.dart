import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ConveyorComponent extends PositionComponent {
  ConveyorComponent() : super(priority: 1);

  final _beltPaint = Paint()..color = const Color(0xFF28343B);
  final _edgePaint = Paint()..color = const Color(0xFF60727B);
  final _stripePaint = Paint()..color = const Color(0xFFE3A82B);
  double _offset = 0;

  @override
  void update(double dt) {
    _offset = (_offset + dt * 35) % 36;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      _edgePaint,
    );
    canvas.drawRect(Rect.fromLTWH(0, 7, size.x, size.y - 14), _beltPaint);
    for (var x = -36.0 + _offset; x < size.x; x += 36) {
      canvas.drawRect(Rect.fromLTWH(x, 7, 15, size.y - 14), _stripePaint);
    }
    super.render(canvas);
  }
}
