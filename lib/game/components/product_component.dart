import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ProductComponent extends PositionComponent {
  ProductComponent({required this.start, required this.end})
      : super(
          position: start.clone(),
          size: Vector2.all(18),
          anchor: Anchor.center,
          priority: 5,
        );

  final Vector2 start;
  final Vector2 end;
  double _elapsed = 0;
  static const _duration = 2.2;

  @override
  void update(double dt) {
    _elapsed += dt;
    final t = (_elapsed / _duration).clamp(0.0, 1.0).toDouble();
    final eased = 1 - ((1 - t) * (1 - t));
    position
      ..x = start.x + ((end.x - start.x) * eased)
      ..y = start.y + ((end.y - start.y) * eased);
    angle += dt * 1.4;
    if (t >= 1) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final shadow = Paint()..color = Colors.black.withAlpha(64);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 3, size.x, size.y),
        const Radius.circular(3),
      ),
      shadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFB8C6CC),
    );
    canvas.drawRect(
      Rect.fromLTWH(4, 4, size.x - 8, size.y - 8),
      Paint()..color = const Color(0xFF6F858F),
    );
    super.render(canvas);
  }
}
