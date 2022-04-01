import 'package:flutter/material.dart';
import 'package:test/group.dart';
import 'package:test/item.dart';

class GroupsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<GroupsList> with SingleTickerProviderStateMixin {
  static const headerSize = 60.0;
  static const duration = Duration(milliseconds: 500);

  var beforeOffset = 0.0;
  var afterOffset = 0.0;
  var scrollPosition = 0.0;
  var selectedItemOffset = 0.0;
  var scrollOffset = 0.0;
  var tapped = false;
  var selectedItem = -1;
  var collapsed = false;
  var a = false;
  double get fullSelectedItemOffset => selectedItemOffset + scrollOffset;

  final scrollController = ScrollController();
  final items = List.generate(17, (index) => Item(Colors.primaries[index]));

  double calculateItemTopPadding(int i) {
    var topPadding = tapped
        ? headerSize * i + beforeOffset
        : items.take(i).fold<double>(0.0, (a, b) => a + b.height);

    return topPadding;
  }

  int calculateShift(int i) {
    if (selectedItem == -1) return 0;

    var shift = 0;

    final sign = (selectedItem - i).sign;
    if (i - selectedItem < 0 &&
        fullSelectedItemOffset < (i - selectedItem) * headerSize + 30 * sign) {
      shift = 1 * sign;
    }

    if (i - selectedItem > 0 &&
        fullSelectedItemOffset > (i - selectedItem) * headerSize + 30 * sign) {
      shift = 1 * sign;
    }

    return shift;
  }

  void onDragStart(int i) {
    scrollPosition = scrollController.offset;
    beforeOffset = 0;
    afterOffset = 0;

    final previousItemsHeight =
        items.take(i).fold<double>(0.0, (a, b) => a + b.height);
    final previousHeadersHeight = i * headerSize;
    final afterHeadersHeight = (items.length - i) * headerSize;
    final topDistance =
        previousItemsHeight - scrollController.position.extentBefore;
    final bottomDistance = scrollController.position.extentInside - topDistance;

    setState(() {
      tapped = true;
      selectedItem = i;
      if (topDistance > previousHeadersHeight) {
        beforeOffset = topDistance - previousHeadersHeight;
      }

      if (bottomDistance > afterHeadersHeight) {
        afterOffset = bottomDistance - afterHeadersHeight;
      }
    });

    if (beforeOffset > 0) {
      scrollController.animateTo(
        0,
        duration: duration,
        curve: Curves.linear,
      );
    }

    if (beforeOffset == 0) {
      scrollController.animateTo(
        previousHeadersHeight - topDistance,
        duration: duration,
        curve: Curves.linear,
      );
    }
  }

  void onDragEnd() {
    var shift = fullSelectedItemOffset ~/ headerSize;
    var additionalShift =
        fullSelectedItemOffset.abs() % headerSize > headerSize / 2 ? 1 : 0;
    shift += (additionalShift * fullSelectedItemOffset.toInt().sign);

    final item = items.removeAt(selectedItem);
    items.insert(selectedItem + shift, item);

    scrollController.animateTo(
      scrollPosition + scrollOffset + (260 - headerSize) * shift,
      duration: duration,
      curve: Curves.linear,
    );

    setState(() {
      a = false;
      collapsed = false;
      tapped = false;
      selectedItem = -1;
      selectedItemOffset = 0;
      scrollOffset = 0;
    });
  }

  @override
  void initState() {
    final ticker = createTicker((elapsed) {
      if (a) {
        final topDistance = (selectedItem * headerSize + beforeOffset) -
            scrollController.position.extentBefore;
        final bottomDistance =
            scrollController.position.extentInside - topDistance - headerSize;

        if (selectedItemOffset + scrollOffset > bottomDistance &&
            scrollController.position.extentAfter > 0) {
          scrollController.jumpTo(scrollController.offset + 1);
          setState(() {
            scrollOffset += 1;
          });
        }

        if (-selectedItemOffset + -scrollOffset > topDistance &&
            scrollController.position.extentBefore > 0) {
          scrollController.jumpTo(scrollController.offset - 1);
          setState(() {
            scrollOffset -= 1;
          });
        }
      }
    });
    ticker.start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        return SingleChildScrollView(
          controller: scrollController,
          child: AnimatedContainer(
            duration: duration,
            height: tapped
                ? items.length * headerSize + beforeOffset + afterOffset
                : items
                    .take(items.length)
                    .fold<double>(0, (a, b) => a + b.height),
            onEnd: () {
              collapsed = true;
              if (tapped) {
                a = true;
              }
            },
            child: Stack(
              children: [
                for (var i = 0; i < items.length; i++)
                  if (i != selectedItem)
                    AnimatedPositioned(
                      key: ValueKey(i),
                      duration: duration,
                      top: calculateItemTopPadding(i),
                      left: 0,
                      right: 0,
                      child: Transform.translate(
                        offset: Offset.zero,
                        child: AnimatedSlide(
                          duration: collapsed
                              ? Duration(milliseconds: 300)
                              : Duration.zero,
                          offset: Offset(0, calculateShift(i).toDouble()),
                          child: Group(
                            onDragStart: () => onDragStart(i),
                            onDragEnd: () => onDragEnd(),
                            item: items[i],
                            height: tapped ? headerSize : items[i].height,
                            duration: duration,
                          ),
                        ),
                      ),
                    ),
                if (selectedItem != -1)
                  AnimatedPositioned(
                    key: ValueKey(selectedItem),
                    duration: duration,
                    top: calculateItemTopPadding(selectedItem),
                    left: 0,
                    right: 0,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        selectedItem == selectedItem
                            ? selectedItemOffset + scrollOffset
                            : 0,
                      ),
                      child: AnimatedSlide(
                        duration: duration,
                        offset: Offset(0, 0),
                        child: Group(
                          onDragStart: () => onDragStart(selectedItem),
                          onDragUpdate: (offset) {
                            setState(() {
                              selectedItemOffset = offset;
                            });
                          },
                          onDragEnd: () => onDragEnd(),
                          item: items[selectedItem],
                          height:
                              tapped ? headerSize : items[selectedItem].height,
                          duration: duration,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
