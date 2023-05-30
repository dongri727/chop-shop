import 'package:chop_shop/menu_data.dart';
import 'package:flutter/material.dart';

typedef NavigateTo(MenuItemData item);

/// This widget displays the single menu section of the [MainMenuWidget].
///
/// There are main sections, as loaded from the menu.json file in the　assets folder.
/// Each section has a backgroundColor, an accentColor,
/// and a list of elements it needs to display when expanded.
///
/// Since this widget expands and contracts when tapped, it needs to maintain a [State].
class MenuSection extends StatefulWidget {
  final String title;
  final Color backgroundColor;
  final Color accentColor;
  final List<MenuItemData> menuOptions;
  final NavigateTo navigateTo;

  MenuSection(this.title, this.backgroundColor, this.accentColor,
      this.menuOptions, this.navigateTo,
      {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SectionState();
}

///削ってはいけない
/// This [State] uses the [SingleTickerProviderStateMixin] to add [vsync] to it.
/// This allows the animation to run smoothly and avoids consuming unnecessary resources.
class _SectionState extends State<MenuSection>
    with SingleTickerProviderStateMixin {
  /// The [AnimationController] is a Flutter Animation object that generates a new value
  /// whenever the hardware is ready to draw a new frame.
  late AnimationController _controller;

  /// Since the above object interpolates only between 0 and 1, but we'd rather apply a curve to the current
  /// animation, we're providing a custom [Tween] that allows to build more advanced animations, as seen in [initState()].
  static final Animatable<double> _sizeTween = Tween<double>(
    begin: 0.0,
    end: 1.0,
  );

  /// The [Animation] object itself, which is required by the [SizeTransition] widget in the [build()] method.
  late Animation<double> _sizeAnimation;

  /// Detects which state the widget is currently in, and triggers the animation upon change.
  bool _isExpanded = false;

  ///ChatGPTの追加したコード
  /// セクションのアイコンを切り替えるためのメソッド
  IconData _getSectionIcon() {
    return _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right;
  }

  /// Here we initialize the fields described above, and set up the widget to its initial state.
  @override
  initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    /// This curve is controlled by [_controller].
    final CurvedAnimation curve =
    CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);

    /// [_sizeAnimation] will interpolate using this curve - [Curves.fastOutSlowIn].
    _sizeAnimation = _sizeTween.animate(curve);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Whenever a tap is detected, toggle a change in the state and move the animation forward
  /// or backwards depending on the initial status.
  _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    switch (_sizeAnimation.status) {
      case AnimationStatus.completed:
        _controller.reverse();
        break;
      case AnimationStatus.dismissed:
        _controller.forward();
        break;
      case AnimationStatus.reverse:
      case AnimationStatus.forward:
        break;
    }
  }

  /// This method wraps the whole widget in a [GestureDetector] to handle taps appropriately.
  ///
  /// A custom [BoxDecoration] is used to render the rounded rectangle on the screen,
  ///
  /// The [SizeTransition] opens up the section and displays the list underneath the section title.
  ///
  /// Each section sub-element is wrapped into a [GestureDetector] too so that the Timeline can be displayed
  /// when that element is tapped.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _toggleExpand,
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: widget.backgroundColor),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Column(children: <Widget>[
                  Container(
                      height: 150.0,
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              height: 21.0,
                              width: 21.0,
                              margin: const EdgeInsets.all(18.0),
                              child: Icon(_getSectionIcon()),
                          ),
                          Text(
                            widget.title,
                            style: TextStyle(
                                fontSize: 20.0,
                                color: widget.accentColor),
                          )
                        ],
                      )),
                  ///カードが開いたり閉じたりする
                  SizeTransition(
                      axisAlignment: 0.0,
                      axis: Axis.vertical,
                      sizeFactor: _sizeAnimation,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 56.0, right: 20.0, top: 10.0),
                          child: Column(
                              children: widget.menuOptions.map((item) {
                                return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => widget.navigateTo(item),
                                    child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 20.0),
                                                  child: Text(
                                                    item.label,
                                                    style: TextStyle(
                                                        color: widget
                                                            .accentColor,
                                                        fontSize: 20.0,
                                                        ),
                                                  ))),
                                        ]));
                              }).toList())))
                ]))));
  }
}
