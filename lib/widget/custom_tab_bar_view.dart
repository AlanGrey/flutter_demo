import 'package:flutter/material.dart';

/// Created  on 2019/7/8.
/// @author grey
/// Function : 选项卡

typedef Widget TabItemBuilder<T>(T data);
typedef Widget TabContentBuilder<T>(T data);

class CustomTabBarView<T> extends StatefulWidget {
  CustomTabBarView({
    @required this.itemList,
    @required this.contentBuilder,
    this.itemBuilder,
    tabHeight,
    tabBgColor,
    tabSelectColor,
    tabUnselectedColor,
    tabSelectSize,
    tabUnselectedSize,
    tabSelectFont,
    tabUnselectedFont,
  })  : assert(itemList != null, "itemList is not null"),
        assert(contentBuilder != null, "contentBuilder is not null"),
        this.tabHeight = tabHeight ?? 42.0,
        this.tabBgColor = tabBgColor ?? const Color(0xffffffff),
        this.tabSelectColor = tabSelectColor ?? const Color(0xff222222),
        this.tabUnselectedColor = tabUnselectedColor ?? const Color(0xff333333),
        this.tabSelectSize = tabSelectSize ?? 16.0,
        this.tabUnselectedSize = tabUnselectedSize ?? 14.0,
        this.tabSelectFont = tabSelectFont ?? FontWeight.bold,
        this.tabUnselectedFont = tabUnselectedFont ?? FontWeight.normal;

  ///列表数据
  final List<T> itemList;

  ///选项卡内容View
  final TabContentBuilder contentBuilder;

  ///选项卡标题View
  final TabItemBuilder itemBuilder;

  ///选项卡高度
  final double tabHeight;

  ///选项卡背景颜色
  final Color tabBgColor;

  ///选中颜色
  final Color tabSelectColor;

  ///未选中颜色
  final Color tabUnselectedColor;

  ///选中字体大小
  final double tabSelectSize;

  ///未选中字体大小
  final double tabUnselectedSize;

  final FontWeight tabSelectFont;

  final FontWeight tabUnselectedFont;

  @override
  State<StatefulWidget> createState() {
    return _CustomTabBarState();
  }
}

class _CustomTabBarState extends State<CustomTabBarView> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.itemList?.length ?? 0, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _createTabBarView(),
          _createTabContentView(),
        ],
      ),
    );
  }

  Widget _createTabBarView() {
    return Container(
      color: widget.tabBgColor,
      height: widget.tabHeight,
      child: TabBar(
        isScrollable: true,
        controller: _tabController,
        labelStyle: TextStyle(fontSize: widget.tabSelectSize, fontWeight: widget.tabSelectFont),
        unselectedLabelStyle: TextStyle(fontSize: widget.tabUnselectedSize, fontWeight: widget.tabUnselectedFont),
        labelColor: widget.tabSelectColor,
        unselectedLabelColor: widget.tabUnselectedColor,
        indicator: TabIndicatorUnderline(
            strokeCap: StrokeCap.round,
            insets: EdgeInsets.only(left: 15.0, right: 15.0),
            borderSide: BorderSide(width: 4.0, color: widget.tabSelectColor)),
        tabs: widget.itemList.map((item) {
          return widget.itemBuilder != null ? widget.itemBuilder(item) : Tab(text: item as String);
        }).toList(),
      ),
    );
  }

  Widget _createTabContentView() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: widget.itemList.map((item) {
          return widget.contentBuilder(item);
        }).toList(),
      ),
      flex: 1,
    );
  }
}

///Tab下划线
class TabIndicatorUnderline extends Decoration {
  final BorderSide borderSide;
  final EdgeInsetsGeometry insets;
  final StrokeCap strokeCap;

  const TabIndicatorUnderline({
    this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
    this.insets = EdgeInsets.zero,
    this.strokeCap = StrokeCap.square,
  })  : assert(borderSide != null),
        assert(insets != null),
        assert(strokeCap != null);

  @override
  Decoration lerpTo(Decoration b, double t) {
    if (b is UnderlineTabIndicator) {
      return UnderlineTabIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  Decoration lerpFrom(Decoration a, double t) {
    if (a is UnderlineTabIndicator) {
      return UnderlineTabIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  _UnderlinePainter createBoxPainter([onChanged]) {
    return _UnderlinePainter(this, onChanged);
  }
}

class _UnderlinePainter extends BoxPainter {
  _UnderlinePainter(this.decoration, VoidCallback onChanged)
      : assert(decoration != null),
        super(onChanged);

  final TabIndicatorUnderline decoration;

  BorderSide get borderSide => decoration.borderSide;

  EdgeInsetsGeometry get insets => decoration.insets;

  StrokeCap get strokeCap => decoration.strokeCap;

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    assert(rect != null);
    assert(textDirection != null);
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    return Rect.fromLTWH(
      indicator.left,
      indicator.bottom - borderSide.width,
      indicator.width,
      borderSide.width,
    );
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size;
    final TextDirection textDirection = configuration.textDirection;
    final Rect indicator = _indicatorRectFor(rect, textDirection).deflate(borderSide.width / 2.0);
    final Paint paint = borderSide.toPaint()..strokeCap = strokeCap;
    canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
  }
}
