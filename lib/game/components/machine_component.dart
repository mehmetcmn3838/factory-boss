import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../models/machine_model.dart';
import '../../systems/factory_controller.dart';
import '../factory_game.dart';
import 'product_component.dart';

class MachineComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FactoryGame> {
  MachineComponent({required this.machine, required this.controller})
      : super(size: Vector2(112, 82), anchor: Anchor.center, priority: 4);

  final MachineModel machine;
  final FactoryController controller;
  final _namePaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
  );
  final _smallPaint = TextPaint(
    style: const TextStyle(color: Color(0xFFC9D5DA), fontSize: 9),
  );
  double _pulse = 0;

  @override
  void update(double dt) {
    final unlocked = controller.isUnlocked(machine);
    if (unlocked && !machine.isBroken && controller.warehouseHasSpace) {
      machine.productionProgress += dt * controller.productionSpeedMultiplier;
      _pulse += dt;
      if (machine.productionProgress >= machine.productionSeconds) {
        machine.productionProgress -= machine.productionSeconds;
        if (controller.completeProduction(machine)) {
          game.add(ProductComponent(
            start: Vector2(position.x + 38, game.conveyorY),
            end: game.warehouseTarget,
          ));
        }
      }
    }
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    controller.selectMachine(machine);
    super.onTapDown(event);
  }

  @override
  void render(Canvas canvas) {
    final unlocked = controller.isUnlocked(machine);
    final baseColor = machine.isBroken
        ? const Color(0xFF9B3C37)
        : unlocked
            ? const Color(0xFF3D6573)
            : const Color(0xFF30383C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.black.withAlpha(64),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -3, size.x, size.y),
        const Radius.circular(10),
      ),
      Paint()..color = baseColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(9, 22, size.x - 18, 35),
      Paint()..color = const Color(0xFF172328),
    );
    if (unlocked) {
      final motion = machine.isBroken ? 0.0 : ((_pulse * 30) % 60);
      canvas.drawCircle(
        Offset(29 + motion, 39),
        8,
        Paint()..color = const Color(0xFFC1D0D5),
      );
      canvas.drawCircle(
        Offset(29 + motion, 39),
        3,
        Paint()..color = const Color(0xFF516A74),
      );
    }
    _namePaint.render(canvas, machine.definition.name, Vector2(8, 4));
    final status = !unlocked
        ? 'UNLOCK: LV ${machine.definition.unlockLevel}'
        : machine.isBroken
            ? 'MACHINE FAILURE'
            : 'LV ${machine.level} • ${machine.partsPerMinute.toStringAsFixed(1)}/min';
    _smallPaint.render(canvas, status, Vector2(8, 63));
    if (unlocked && !machine.isBroken) {
      final progress =
          (machine.productionProgress / machine.productionSeconds)
              .clamp(0.0, 1.0)
              .toDouble();
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(8, size.y - 5, size.x - 16, 3),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF1D292E),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(8, size.y - 5, (size.x - 16) * progress, 3),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFFF0B43D),
      );
    }
    super.render(canvas);
  }
}
