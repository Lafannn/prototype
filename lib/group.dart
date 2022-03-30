import 'package:flutter/material.dart';
import 'package:test/item.dart';

class Group extends StatefulWidget {
  final Item item;
  final double height;
  final Duration duration;
  final VoidCallback onDragStart;
  final void Function(double offset)? onDragUpdate;
  final VoidCallback onDragEnd;

  const Group({
    Key? key,
    required this.item,
    required this.height,
    required this.duration,
    required this.onDragStart,
    this.onDragUpdate,
    required this.onDragEnd,
  }) : super(key: key);

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.duration,
      height: widget.height,
      child: Container(
        color: widget.item.color,
        child: Column(
          children: [
            GestureDetector(
              onLongPressStart: (details) => widget.onDragStart(),
              onLongPressMoveUpdate: (details) =>
                  widget.onDragUpdate?.call(details.offsetFromOrigin.dy),
              onLongPressEnd: (details) => widget.onDragEnd(),
              child: Container(
                height: 60,
                alignment: Alignment.center,
                child: Text(
                  'Header',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            Expanded(
              child: ReorderableListView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 0; i < widget.item.subItems.length; i++)
                    Container(
                      key: ValueKey(widget.item.subItems[i]),
                      height: 50,
                      child: Text('Item ${widget.item.subItems[i]}'),
                    )
                ],
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final a = widget.item.subItems.removeAt(oldIndex);
                    widget.item.subItems.insert(newIndex, a);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
