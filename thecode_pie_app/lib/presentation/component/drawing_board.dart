import 'package:flutter/material.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';

// 각 경로의 색상과 굵기를 저장하는 클래스
class DrawingPath {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser; // 지우개 여부

  DrawingPath({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
  });
}

class DrawingBoard extends StatefulWidget {
  final double? width;
  final double? height;
  final List<Color> colors;
  final Color defaultColor;

  const DrawingBoard({
    super.key,
    this.width,
    this.height,
    this.colors = const [
      AppColors.accentOrange,
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
    ],
    this.defaultColor = AppColors.accentOrange,
  });

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  // 그림 경로들을 저장 (각 경로마다 색상과 굵기 포함)
  final List<DrawingPath> _paths = [];
  DrawingPath? _currentPath;
  late Color _currentColor;
  double _strokeWidth = 4.0;
  bool _isDrawingActive = false;
  bool _showColorPicker = false;
  bool _isEraserMode = false;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.defaultColor;
  }

  void _onPanStart(DragStartDetails details) {
    if (!_isDrawingActive) return;
    setState(() {
      _currentPath = DrawingPath(
        points: [details.localPosition],
        color: _isEraserMode ? Colors.transparent : _currentColor,
        strokeWidth: _strokeWidth,
        isEraser: _isEraserMode,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawingActive || _currentPath == null) return;
    setState(() {
      _currentPath = DrawingPath(
        points: [..._currentPath!.points, details.localPosition],
        color: _currentPath!.color,
        strokeWidth: _currentPath!.strokeWidth,
        isEraser: _currentPath!.isEraser,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDrawingActive || _currentPath == null) return;
    setState(() {
      // 현재 경로를 완성된 경로 목록에 추가
      _paths.add(_currentPath!);
      _currentPath = null;
    });
  }

  void _undo() {
    setState(() {
      if (_paths.isNotEmpty) {
        _paths.removeLast();
      }
    });
  }

  void _clearAll() {
    setState(() {
      _paths.clear();
      _currentPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 그림 그리기 영역 (전체 화면, 활성화 시에만 터치 가능)
        if (_isDrawingActive)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    painter: MyPainter(
                      paths: _paths,
                      currentPath: _currentPath,
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                );
              },
            ),
          ),
        // 컨트롤 UI (그림 그리기 영역 위에 배치, 터치 이벤트 차단)
        Align(
          alignment: .bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: IgnorePointer(
              ignoring: false,
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .end,
                children: [
                  // 색상 선택 UI
                  if (_isDrawingActive && _showColorPicker)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // 색상 선택 버튼들
                          ...widget.colors.map((color) {
                            final isSelected =
                                !_isEraserMode && _currentColor == color;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isEraserMode = false;
                                  _currentColor = color;
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.grey,
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                              ),
                            );
                          }),
                          // 지우개 버튼 (맨 오른쪽)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEraserMode = true;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _isEraserMode
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isEraserMode
                                      ? Colors.red
                                      : Colors.grey,
                                  width: _isEraserMode ? 3 : 1,
                                ),
                              ),
                              child: Icon(
                                Icons.auto_fix_high,
                                size: 18,
                                color: _isEraserMode
                                    ? Colors.red
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // 컨트롤 패널
                  if (_isDrawingActive)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: .min,
                        children: [
                          // 색상 선택 버튼
                          IconButton(
                            icon: const Icon(Icons.palette),
                            onPressed: () {
                              setState(() {
                                _showColorPicker = !_showColorPicker;
                              });
                            },
                            tooltip: '색상 선택',
                          ),
                          // 선 두께 조절
                          SizedBox(
                            width: 100,
                            child: Column(
                              mainAxisSize: .min,
                              children: [
                                Text(
                                  '${_strokeWidth.toInt()}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Slider(
                                  value: _strokeWidth,
                                  min: 1,
                                  max: 20,
                                  onChanged: (value) {
                                    setState(() {
                                      _strokeWidth = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          // 되돌리기와 전체 지우기 버튼 (한 줄로)
                          Row(
                            mainAxisSize: .min,
                            children: [
                              // 되돌리기 버튼
                              IconButton(
                                icon: const Icon(Icons.undo),
                                onPressed: _paths.isNotEmpty ? _undo : null,
                                tooltip: '되돌리기',
                              ),
                              // 전체 지우기 버튼
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearAll,
                                tooltip: '전체 지우기',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  // 메인 네모난 버튼
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDrawingActive = !_isDrawingActive;
                        if (!_isDrawingActive) {
                          _showColorPicker = false;
                        }
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _isDrawingActive
                            ? Colors.red
                            : AppColors.accentOrange,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isDrawingActive
                                        ? Colors.red
                                        : AppColors.accentOrange)
                                    .withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isDrawingActive ? Icons.close : Icons.brush,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// CustomPainter 구현
class MyPainter extends CustomPainter {
  final List<DrawingPath> paths;
  final DrawingPath? currentPath;

  MyPainter({required this.paths, this.currentPath});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 새로운 레이어 생성 (지우개 효과를 위해 필수)
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 2. 저장된 모든 경로 그리기
    for (final path in paths) {
      _drawSinglePath(canvas, path);
    }

    // 3. 현재 그리고 있는 경로 실시간 반영
    if (currentPath != null) {
      _drawSinglePath(canvas, currentPath!);
    }

    canvas.restore();
  }

  void _drawSinglePath(Canvas canvas, DrawingPath path) {
    if (path.points.length < 2) return;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = path.strokeWidth
      ..style = PaintingStyle.stroke;

    if (path.isEraser) {
      // 지우개 모드: 그린 부분을 투명하게 파냄
      paint.blendMode = .clear;
      paint.color = Colors.black; // blendMode.clear 시 색상은 의미 없지만 할당
    } else {
      // 일반 모드
      paint.blendMode = .srcOver;
      paint.color = path.color;
    }

    // 성능을 위해 drawLine 대신 Path 객체 권장 (여기서는 기존 로직 유지)
    for (int i = 0; i < path.points.length - 1; i++) {
      canvas.drawLine(path.points[i], path.points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    // 경로의 개수가 다르거나, 현재 그리는 경로의 점 개수가 다를 때 다시 그림
    return oldDelegate.paths.length != paths.length ||
        oldDelegate.currentPath?.points.length != currentPath?.points.length;
  }
}
