import 'dart:async';

import 'package:flutter/material.dart';

import 'banner_indicator_view.dart';

/// Created  on 2019/7/9.
/// @author grey
/// Function : 默认的广告banner

const int ITEM_GROUP = 500;

typedef Widget BannerItemBuilder<T>(BuildContext context, int index, T data);

class BannerGalleryView<T> extends StatefulWidget {
  BannerGalleryView({
    @required this.data,
    @required this.itemBuilder,
    itemRatio,
    bannerMargin,
    bannerBorder,
    autoScrollDurationSeconds,
    scrollAnimateDuration,
    scrollAnimateCurve,
    indicatorAlignment,
    indicatorNormalColor,
    indicatorSelectedColor,
    indicatorSize,
    indicatorSpacing,
    indicatorStyle,
    indicatorAnimStyle,
    indicatorScaleSize,
  })  : this.itemRatio = itemRatio ?? 2.0,
        this.bannerMargin = bannerMargin ?? const EdgeInsets.all(0),
        this.bannerBorder = bannerBorder ?? BorderRadius.zero,
        this.autoScrollDurationSeconds = autoScrollDurationSeconds ?? 3,
        this.scrollAnimateDuration = scrollAnimateDuration ?? Duration(milliseconds: 250),
        this.scrollAnimateCurve = scrollAnimateCurve ?? Curves.linear,
        this.indicatorAlignment = indicatorAlignment ?? Alignment(0.0, 0.95),
        this.indicatorNormalColor = indicatorNormalColor ?? Colors.white,
        this.indicatorSelectedColor = indicatorSelectedColor ?? Colors.red.shade200,
        this.indicatorSize = indicatorSize ?? 8.0,
        this.indicatorSpacing = indicatorSpacing ?? 4.0,
        this.indicatorStyle = indicatorStyle ?? BannerIndicatorStyle.circle,
        this.indicatorAnimStyle = indicatorAnimStyle ?? BannerIndicatorAnimStyle.normal,
        this.indicatorScaleSize = indicatorScaleSize ?? 1.2;

  /// 数据源
  final List<T> data;

  /// Banner Item view
  final BannerItemBuilder itemBuilder;

  /// PageItem高度比例
  final double itemRatio;

  /// 间隙
  final EdgeInsetsGeometry bannerMargin;

  /// 圆角
  final BorderRadius bannerBorder;

  /// 自动滑动时间间隔[单位s],默认3秒
  final int autoScrollDurationSeconds;

  /// 滑动动画时间
  final Duration scrollAnimateDuration;

  /// 滑动动画效果
  final Curve scrollAnimateCurve;

  final Alignment indicatorAlignment;

  /// 非选中的颜色
  final Color indicatorNormalColor;

  /// 选中的颜色
  final Color indicatorSelectedColor;

  /// 点的大小
  final double indicatorSize;

  /// 点的间距
  final double indicatorSpacing;

  /// 点的样式
  final BannerIndicatorStyle indicatorStyle;

  /// 动画样式
  final BannerIndicatorAnimStyle indicatorAnimStyle;

  /// 选中放大的倍数
  final double indicatorScaleSize;

  @override
  State<StatefulWidget> createState() {
    return _BannerGalleryState();
  }
}

class _BannerGalleryState extends State<BannerGalleryView> {
  PageController _controller;

  /// 轮播控制器
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _initData();
    _startTimer();
  }

  @override
  void didUpdateWidget(BannerGalleryView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: widget.itemRatio,
        child: Stack(children: <Widget>[
          _createPageView(),
          _createPositionView(),
        ]),
      ),
    );
  }

  Widget _createPageView() {
    return PageView.builder(
        controller: _controller,
        pageSnapping: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return _createPageItemView(context, index);
        });
  }

  Widget _createPageItemView(BuildContext context, int index) {
    int currentIndex = index % _getReallyDataSize();
    dynamic dataItem = currentIndex < widget.data.length ? widget.data[currentIndex] : null;
    return Listener(
      onPointerUp: (_) {
        _startTimer();
      },
      onPointerDown: (_) {
        _stopTimer();
      },
      onPointerMove: (_) {
        _stopTimer();
      },
      child: dataItem == null
          ? Container()
          : Container(
              margin: widget.bannerMargin,
              child: ClipRRect(
                borderRadius: widget.bannerBorder,
                child: widget.itemBuilder == null
                    ? Container(color: Color(0xffE1E1E1))
                    : widget.itemBuilder(context, index, dataItem),
              ),
            ),
    );
  }

  Widget _createPositionView() {
    return Align(
      alignment: widget.indicatorAlignment,
      child: BannerIndicator(
        controller: _controller,
        itemCount: _getReallyDataSize(),
        normalColor: widget.indicatorNormalColor,
        selectedColor: widget.indicatorSelectedColor,
        size: widget.indicatorSize,
        spacing: widget.indicatorSpacing,
        scaleSize: widget.indicatorScaleSize,
        style: widget.indicatorStyle,
        animStyle: widget.indicatorAnimStyle,
      ),
    );
  }

  void _initData() {
    _controller = PageController(initialPage: _getCenterPosition());
  }

  ///获取当前真实数据长度
  int _getReallyDataSize() {
    return widget.data == null ? 0 : widget.data.length;
  }

  /// 获取Page中心起始点
  int _getCenterPosition() {
    return ITEM_GROUP ~/ 2 * _getReallyDataSize();
  }

  ///启动滑动控制器
  void _startTimer() {
    _timer?.cancel();

    _timer = new Timer.periodic(Duration(seconds: widget.autoScrollDurationSeconds), (Timer timer) {
      if (_controller.page != null) {
        var nextPageIndex = _controller.page.toInt() + 1;
        if (nextPageIndex > _getReallyDataSize() * ITEM_GROUP) {
          _controller.jumpToPage(_getCenterPosition());
        } else {
          _controller.animateToPage(
            nextPageIndex,
            duration: widget.scrollAnimateDuration,
            curve: widget.scrollAnimateCurve,
          );
        }
      }
    });
  }

  ///暂定滑动控制器
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
