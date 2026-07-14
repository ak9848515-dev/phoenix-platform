import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../models/entity_type.dart';
import '../models/memory_entity.dart';
import '../models/memory_graph.dart';
import '../models/memory_relation.dart';

/// A simple graph visualizer using CustomPaint.
///
/// Shows entities as nodes and relations as edges with a basic
/// force-directed layout approximation.
class GraphVisualizer extends StatefulWidget {
  const GraphVisualizer({
    super.key,
    required this.graph,
    this.focalEntityId,
    this.onEntityTap,
    this.width = double.infinity,
    this.height = 300,
  });

  final MemoryGraph graph;
  final String? focalEntityId;
  final void Function(MemoryEntity entity)? onEntityTap;
  final double width;
  final double height;

  @override
  State<GraphVisualizer> createState() => _GraphVisualizerState();
}

class _GraphVisualizerState extends State<GraphVisualizer> {
  late List<_Node> _nodes;
  late List<_Edge> _edges;

  @override
  void initState() {
    super.initState();
    _layoutGraph();
  }

  @override
  void didUpdateWidget(GraphVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graph != widget.graph) {
      _layoutGraph();
    }
  }

  void _layoutGraph() {
    final entityMap = {
      for (final e in widget.graph.entities) e.id: e
    };

    // Determine visible nodes (if focal entity, show that + connected)
    Set<String> visibleIds;
    if (widget.focalEntityId != null) {
      visibleIds = {widget.focalEntityId!};
      final focalEntity = entityMap[widget.focalEntityId];
      if (focalEntity != null) {
        final connected =
            widget.graph.connectedEntities(widget.focalEntityId!);
        visibleIds.addAll(connected.map((e) => e.id));
      }
    } else {
      visibleIds = widget.graph.entities
          .take(20)
          .map((e) => e.id)
          .toSet();
    }

    final visibleEntities =
        visibleIds.map((id) => entityMap[id]).whereType<MemoryEntity>().toList();
    final visibleIdSet = visibleEntities.map((e) => e.id).toSet();
    final visibleRelations = widget.graph.relations
        .where((r) =>
            visibleIdSet.contains(r.sourceEntityId) &&
            visibleIdSet.contains(r.targetEntityId))
        .toList();

    // Assign positions in a circle layout
    _nodes = [];
    _edges = [];

    final centerX = 150.0;
    final centerY = 150.0;
    final radius = 100.0;

    for (int i = 0; i < visibleEntities.length; i++) {
      final angle = (2 * math.pi * i / visibleEntities.length) -
          math.pi / 2;
      _nodes.add(_Node(
        entity: visibleEntities[i],
        x: centerX + radius * math.cos(angle),
        y: centerY + radius * math.sin(angle),
        radius: 20.0,
      ));
    }

    // Build edges
    final nodeMap = {for (final n in _nodes) n.entity.id: n};
    for (final rel in visibleRelations) {
      final source = nodeMap[rel.sourceEntityId];
      final target = nodeMap[rel.targetEntityId];
      if (source != null && target != null) {
        _edges.add(_Edge(source: source, target: target, relation: rel));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_nodes.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No graph data',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: widget.height,
          child: GestureDetector(
            onTapUp: (details) {
              if (widget.onEntityTap == null) return;
              final pos = details.localPosition;
              for (final node in _nodes) {
                final dx = pos.dx - node.x;
                final dy = pos.dy - node.y;
                if (dx * dx + dy * dy <= node.radius * node.radius) {
                  widget.onEntityTap!(node.entity);
                  return;
                }
              }
            },
            child: CustomPaint(
              painter: _GraphPainter(
                nodes: _nodes,
                edges: _edges,
                focalId: widget.focalEntityId,
                theme: theme,
              ),
              child: SizedBox(
                width: constraints.maxWidth,
                height: widget.height,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Node {
  _Node({
    required this.entity,
    required this.x,
    required this.y,
    required this.radius,
  });

  final MemoryEntity entity;
  double x;
  double y;
  final double radius;
}

class _Edge {
  _Edge({
    required this.source,
    required this.target,
    required this.relation,
  });

  final _Node source;
  final _Node target;
  final MemoryRelation relation;
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.nodes,
    required this.edges,
    this.focalId,
    required this.theme,
  });

  final List<_Node> nodes;
  final List<_Edge> edges;
  final String? focalId;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges
    for (final edge in edges) {
      final paint = Paint()
        ..color = theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(edge.source.x, edge.source.y),
        Offset(edge.target.x, edge.target.y),
        paint,
      );
    }

    // Draw nodes
    for (final node in nodes) {
      final isFocal = node.entity.id == focalId;
      final color = _nodeColor(node.entity.type);

      // Glow for focal
      if (isFocal) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(
          Offset(node.x, node.y),
          node.radius + 6,
          glowPaint,
        );
      }

      // Node circle
      canvas.drawCircle(
        Offset(node.x, node.y),
        node.radius,
        Paint()..color = color.withValues(alpha: isFocal ? 0.9 : 0.7),
      );

      // Border
      canvas.drawCircle(
        Offset(node.x, node.y),
        node.radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = isFocal ? 3 : 1.5,
      );

      // First letter label
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.entity.title.isNotEmpty
              ? node.entity.title[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          node.x - textPainter.width / 2,
          node.y - textPainter.height / 2,
        ),
      );
    }

    // Labels for focal and nearby nodes
    for (final node in nodes) {
      final isFocal = node.entity.id == focalId;
      if (!isFocal) continue;

      final textPainter = TextPainter(
        text: TextSpan(
          text: node.entity.title,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          node.x - textPainter.width / 2,
          node.y + node.radius + 4,
        ),
      );
    }
  }

  Color _nodeColor(EntityType type) {
    switch (type) {
      case EntityType.mission:
        return AppColors.primary;
      case EntityType.habit:
        return Colors.orange;
      case EntityType.decision:
        return const Color(0xFF0891B2);
      case EntityType.lesson:
        return Colors.indigo;
      case EntityType.skill:
        return const Color(0xFF7C3AED);
      case EntityType.goal:
        return AppColors.warning;
      case EntityType.project:
        return Colors.blue;
      case EntityType.person:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(_GraphPainter oldDelegate) => true;
}
