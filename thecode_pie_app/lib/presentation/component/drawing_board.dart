import 'package:flutter/material.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/core/services/sound_effects_service.dart';

class DrawingPath {
  const DrawingPath({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.canvasSize,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final Size canvasSize;
}

class DrawingBoard extends StatefulWidget {
  const DrawingBoard({
    super.key,
    this.width,
    this.height,
    this.colors = const [Colors.black, Colors.white, Colors.blue],
    this.defaultColor = Colors.black,
    this.controller,
    this.showFloatingButton = true,
    this.topInset = 0,
    this.drawingBounds,
    this.controlsTop = 62,
    this.controlsRight = 20,
    this.strokeScale = 1,
  });

  final double? width;
  final double? height;
  final List<Color> colors;
  final Color defaultColor;
  final DrawingBoardController? controller;
  final bool showFloatingButton;
  final double topInset;
  final Rect? drawingBounds;
  final double controlsTop;
  final double controlsRight;
  final double strokeScale;

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class DrawingBoardController extends ChangeNotifier {
  bool _isActive = false;

  bool get isActive => _isActive;

  void toggle() {
    _isActive = !_isActive;
    notifyListeners();
  }

  void close() {
    if (!_isActive) return;
    _isActive = false;
    notifyListeners();
  }
}

class _DrawingBoardState extends State<DrawingBoard> {
  static const double _strokeWidth = 3.0;

  final List<DrawingPath> _paths = [];
  DrawingPath? _currentPath;
  late Color _currentColor;
  late DrawingBoardController _controller;
  Size _canvasSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.defaultColor;
    _controller = widget.controller ?? DrawingBoardController();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant DrawingBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    _controller.removeListener(_handleControllerChanged);
    _controller = widget.controller ?? DrawingBoardController();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onPanStart(DragStartDetails details) {
    if (!_controller.isActive) return;
    setState(() {
      _currentPath = DrawingPath(
        points: [details.localPosition],
        color: _currentColor,
        strokeWidth: _strokeWidth * widget.strokeScale,
        canvasSize: _canvasSize,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_controller.isActive || _currentPath == null) return;
    setState(() {
      _currentPath = DrawingPath(
        points: [..._currentPath!.points, details.localPosition],
        color: _currentPath!.color,
        strokeWidth: _currentPath!.strokeWidth,
        canvasSize: _currentPath!.canvasSize,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_controller.isActive || _currentPath == null) return;
    setState(() {
      _paths.add(_currentPath!);
      _currentPath = null;
    });
  }

  void _undo() {
    if (_paths.isEmpty) return;
    setState(() {
      _paths.removeLast();
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
    final safeTop = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        if (_controller.isActive)
          Positioned(
            left: widget.drawingBounds?.left ?? 0,
            top: widget.drawingBounds?.top ?? widget.topInset,
            width: widget.drawingBounds?.width,
            height: widget.drawingBounds?.height,
            right: widget.drawingBounds == null ? 0 : null,
            bottom: widget.drawingBounds == null ? 0 : null,
            child: LayoutBuilder(
              builder: (context, constraints) {
                _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: ClipRect(
                    child: CustomPaint(
                      painter: _DrawingPainter(
                        paths: _paths,
                        currentPath: _currentPath,
                      ),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    ),
                  ),
                );
              },
            ),
          ),
        if (_controller.isActive)
          Positioned(
            top: safeTop + widget.controlsTop,
            right: widget.controlsRight,
            child: _DrawingControls(
              colors: widget.colors,
              selectedColor: _currentColor,
              onColorSelected: (color) {
                setState(() {
                  _currentColor = color;
                });
              },
              onUndo: _paths.isNotEmpty ? _undo : null,
              onClear: _clearAll,
            ),
          ),
        if (widget.showFloatingButton)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: _controller.toggle,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _controller.isActive
                        ? Colors.red
                        : AppColors.accentOrange,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_controller.isActive
                                    ? Colors.red
                                    : AppColors.accentOrange)
                                .withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _controller.isActive ? Icons.close : Icons.brush,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DrawingControls extends StatelessWidget {
  const _DrawingControls({
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
    required this.onUndo,
    required this.onClear,
  });

  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback? onUndo;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceOverlay,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceOverlay),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final color in colors) ...[
            _ColorDot(
              color: color,
              isSelected: selectedColor == color,
              onTap: () => onColorSelected(color),
            ),
            const SizedBox(width: 6),
          ],
          Container(
            width: 1,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: AppColors.crust.withValues(alpha: 0.22),
          ),
          _ToolIcon(icon: Icons.undo_rounded, tooltip: '되돌리기', onTap: onUndo),
          _ToolIcon(
            icon: Icons.delete_outline_rounded,
            tooltip: '전체 지우기',
            onTap: onClear,
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppColors.crust
                : Colors.white.withValues(alpha: 0.55),
            width: isSelected ? 2.4 : 1,
          ),
        ),
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: IconButton(
        onPressed: SoundEffectsService().withSelect(onTap),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18),
        color: AppColors.crust,
        disabledColor: AppColors.crust.withValues(alpha: 0.34),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  const _DrawingPainter({required this.paths, this.currentPath});

  final List<DrawingPath> paths;
  final DrawingPath? currentPath;

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      _drawPath(canvas, path);
    }

    if (currentPath != null) {
      _drawPath(canvas, currentPath!);
    }
  }

  void _drawPath(Canvas canvas, DrawingPath path) {
    if (path.points.length < 2) return;

    final scaleX = path.canvasSize.width == 0
        ? 1.0
        : canvas.getLocalClipBounds().width / path.canvasSize.width;
    final scaleY = path.canvasSize.height == 0
        ? 1.0
        : canvas.getLocalClipBounds().height / path.canvasSize.height;

    final paint = Paint()
      ..color = path.color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = path.strokeWidth * ((scaleX + scaleY) / 2)
      ..style = PaintingStyle.stroke;

    final drawPath = Path()
      ..moveTo(path.points.first.dx * scaleX, path.points.first.dy * scaleY);
    for (var i = 1; i < path.points.length; i++) {
      drawPath.lineTo(path.points[i].dx * scaleX, path.points[i].dy * scaleY);
    }

    canvas.drawPath(drawPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return oldDelegate.paths != paths || oldDelegate.currentPath != currentPath;
  }
}
