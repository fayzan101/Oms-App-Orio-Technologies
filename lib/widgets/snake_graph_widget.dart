import 'package:flutter/material.dart';
import '../models/snake_graph_model.dart';
import 'dart:math';

class SnakeGraphWidget extends StatelessWidget {
  final SnakeGraphModel snakeGraphData;
  final double height;
  final double cellWidth;
  final double cellHeight;

  const SnakeGraphWidget({
    Key? key,
    required this.snakeGraphData,
    this.height = 340,
    this.cellWidth = 48,
    this.cellHeight = 50,
  }) : super(key: key);

  static const List<String> statuses = [
    'Booked',
    'Arrival',
    'InTransit',
    'Delivered',
    'Return',
  ];

  static const List<String> statusLabels = [
    'Booked',
    'Arrival',
    'In Transit',
    'Delivered',
    'Return',
  ];

  @override
  Widget build(BuildContext context) {
    final days = snakeGraphData.days;
    if (days.isEmpty) {
      return Container(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No data available for this period',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: cellWidth * days.length + 80,
          height: cellHeight * statuses.length + 24 + (statuses.length - 1) * 8,
          child: Stack(
            children: [
              // Dotted lines
              CustomPaint(
                size: Size(cellWidth * days.length + 80, cellHeight * statuses.length + 24 + (statuses.length - 1) * 8),
                painter: _SnakeDottedLinePainter(
                  snakeGraphData: snakeGraphData,
                  days: days,
                  statuses: statuses,
                  cellWidth: cellWidth,
                  cellHeight: cellHeight + 8, // account for spacing
                ),
              ),
              // Numbers and labels
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(statuses.length * 2 - 1, (i) {
                  if (i.isOdd) {
                    return const SizedBox(height: 8);
                  }
                  final rowIdx = i ~/ 2;
                  final status = statuses[rowIdx];
                  return SizedBox(
                    height: cellHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            statusLabels[rowIdx],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        ...List.generate(days.length, (colIdx) {
                          final day = days[colIdx];
                          final dayData = snakeGraphData.getDayData(day);
                          int value = 0;
                          if (dayData != null) {
                            value = dayData.getValueForStatus(status);
                          }
                          return SizedBox(
                            width: cellWidth,
                            child: Center(
                              child: Text(
                                value.toString(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ),
              // Day labels (top)
              Positioned(
                left: 60,
                top: 0,
                right: 0,
                child: Row(
                  children: List.generate(days.length, (colIdx) {
                    final day = days[colIdx];
                    return SizedBox(
                      width: cellWidth,
                      child: Center(
                        child: Text(
                          _getDayShortName(day),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayShortName(String day) {
    switch (day) {
      case 'Sunday':
        return 'Sun';
      case 'Monday':
        return 'Mon';
      case 'Tuesday':
        return 'Tue';
      case 'Wednesday':
        return 'Wed';
      case 'Thursday':
        return 'Thu';
      case 'Friday':
        return 'Fri';
      case 'Saturday':
        return 'Sat';
      default:
        return day;
    }
  }
}

class _SnakeDottedLinePainter extends CustomPainter {
  final SnakeGraphModel snakeGraphData;
  final List<String> days;
  final List<String> statuses;
  final double cellWidth;
  final double cellHeight;

  _SnakeDottedLinePainter({
    required this.snakeGraphData,
    required this.days,
    required this.statuses,
    required this.cellWidth,
    required this.cellHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int rowIdx = 0; rowIdx < statuses.length; rowIdx++) {
      final status = statuses[rowIdx];
      Offset? prev;
      for (int colIdx = 0; colIdx < days.length; colIdx++) {
        final x = 60 + colIdx * cellWidth + cellWidth / 2;
        final y = rowIdx * cellHeight + cellHeight / 2 + 18 + rowIdx * 8;
        if (prev != null) {
          _drawDottedLine(canvas, prev, Offset(x, y), paint);
        }
        prev = Offset(x, y);
      }
    }
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashWidth = 3;
    const double dashSpace = 3;
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double distance = sqrt(dx * dx + dy * dy);
    final double steps = distance / (dashWidth + dashSpace);
    for (int i = 0; i < steps; i++) {
      final double t1 = i / steps;
      final double t2 = (i + 0.5) / steps;
      final double x1 = start.dx + dx * t1;
      final double y1 = start.dy + dy * t1;
      final double x2 = start.dx + dx * t2;
      final double y2 = start.dy + dy * t2;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 