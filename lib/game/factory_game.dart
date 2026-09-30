import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../systems/factory_controller.dart';
import 'components/conveyor_component.dart';
import 'components/machine_component.dart';
import 'components/warehouse_component.dart';

class FactoryGame extends FlameGame {
  FactoryGame(this.controller);

  final FactoryController controller;
  final List<MachineComponent> _machines = <MachineComponent>[];
  late final ConveyorComponent conveyor;
  late final WarehouseComponent warehouse;

  double get conveyorY => size.y * .63;
  Vector2 get warehouseTarget =>
      Vector2(size.x - 48, conveyorY + 2);

  @override
  Color backgroundColor() => const Color(0xFF172126);

  @override
  Future<void> onLoad() async {
    conveyor = ConveyorComponent();
    warehouse = WarehouseComponent(controller);
    add(conveyor);
    add(warehouse);
    for (final machine in controller.data.machines) {
      final component = MachineComponent(machine: machine, controller: controller);
      _machines.add(component);
      add(component);
    }
    _layout(size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _layout(size);
    }
  }

  void _layout(Vector2 canvasSize) {
    if (canvasSize.x <= 0 || canvasSize.y <= 0) {
      return;
    }
    conveyor
      ..position = Vector2(16, canvasSize.y * .59)
      ..size = Vector2(canvasSize.x - 32, 50);
    warehouse
      ..position = Vector2(canvasSize.x - 92, canvasSize.y * .68)
      ..size = Vector2(76, 106);

    final left = canvasSize.x * .2;
    final right = canvasSize.x * .61;
    final top = canvasSize.y * .22;
    final secondRow = canvasSize.y * .43;
    final positions = <Vector2>[
      Vector2(left, top),
      Vector2(right, top),
      Vector2(left, secondRow),
      Vector2(right, secondRow),
    ];
    for (var i = 0; i < _machines.length; i++) {
      _machines[i].position = positions[i];
    }
  }

  @override
  void update(double dt) {
    if (_machines.isNotEmpty &&
        !identical(_machines.first.machine, controller.data.machines.first)) {
      _rebuildMachines();
    }
    controller.tick(dt.clamp(0.0, .1).toDouble());
    super.update(dt);
  }

  void _rebuildMachines() {
    removeAll(_machines);
    _machines.clear();
    for (final machine in controller.data.machines) {
      final component = MachineComponent(machine: machine, controller: controller);
      _machines.add(component);
      add(component);
    }
    _layout(size);
  }

  @override
  void render(Canvas canvas) {
    final gridPaint = Paint()
      ..color = const Color(0xFF26343A)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.x; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    }
    for (var y = 0.0; y < size.y; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
    }
    final safetyPaint = Paint()
      ..color = const Color(0xFFD39B2C)
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(8, size.y * .12),
      Offset(size.x - 8, size.y * .12),
      safetyPaint,
    );
    super.render(canvas);
  }
}
