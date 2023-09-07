import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug, // Set the log level to display.
  // In this example, the debug level is used.
);

class draggableFloatingActionButton extends StatefulWidget {
  final Widget child;
  final Offset initialOffset;
  final VoidCallback onPressed;
  final Function(Offset) onDragEnd;
  final bool isDraggable;

  draggableFloatingActionButton({
    required this.child,
    required this.initialOffset,
    required this.onPressed,
    required this.onDragEnd,
    this.isDraggable = true, // Default to true, if not specified.
    required GlobalKey<State<StatefulWidget>> parentKey,
  });

  @override
  State<StatefulWidget> createState() => _DraggableFloatingActionButtonState();
}

class _DraggableFloatingActionButtonState
    extends State<draggableFloatingActionButton> {
  bool _isDragging = false;
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent) {
    if (!widget.isDraggable) {
      return; // Do not update position if dragging is not allowed.
    }

    double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
    double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;

    setState(() {
      _offset = Offset(newOffsetX, newOffsetY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Listener(
        onPointerMove: (PointerMoveEvent pointerMoveEvent) {
          _updatePosition(pointerMoveEvent);

          logger.i('initState offset: $_offset');
          // Logging the position change

          setState(() {
            _isDragging = true;
          });
        },
        onPointerUp: (PointerUpEvent pointerUpEvent) {
          if (_isDragging) {
            widget.onDragEnd(_offset); // Send the position when dragging ends.
            logger.i('onDragEnd offset: $_offset');
            setState(() {
              _isDragging = false;
            });
          } else {
            widget.onPressed();
          }
        },
        child: widget.child,
      ),
    );
  }
}
