import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e, isDragging) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                constraints: const BoxConstraints(minWidth: 48),
                height: isDragging ? 56 : 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length]
                      .withOpacity(isDragging ? 0.5 : 1.0),
                  boxShadow: isDragging
                      ? [
                          const BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T, bool isDragging) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  /// Tracks the currently dragging item.
  T? _draggingItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          return DragTarget<Object>(
            onWillAccept: (incoming) => incoming != item,
            onAccept: (incoming) {
              setState(() {
                final oldIndex = _items.indexOf(incoming! as T);
                final newIndex = _items.indexOf(item);
                _items.removeAt(oldIndex);
                _items.insert(newIndex, incoming as T);
              });
            },
            builder: (context, candidateData, rejectedData) {
              final isTarget = candidateData.isNotEmpty;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(horizontal: isTarget ? 24.0 : 0.0),
                child: LongPressDraggable<Object>(
                  data: item,
                  feedback: Material(
                    color: Colors.transparent,
                    child: widget.builder(item, true),
                  ),
                  onDragStarted: () {
                    setState(() {
                      _draggingItem = item;
                    });
                  },
                  onDragEnd: (details) {
                    setState(() {
                      _draggingItem = null;
                    });
                  },
                  childWhenDragging: const SizedBox.shrink(),
                  child: widget.builder(item, _draggingItem == item),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
