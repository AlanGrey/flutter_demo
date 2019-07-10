import 'dart:math';

import 'package:flutter/material.dart';

/// Created  on 2019/7/9.
/// @author grey
/// Function : 轮询播放器

enum BannerIndicatorStyle { circle, square }
enum BannerIndicatorAnimStyle { normal, scaled }

class BannerIndicator extends AnimatedWidget {
  BannerIndicator({
    this.controller,
    this.itemCount,
    this.normalColor,
    this.selectedColor,
    this.size,
    this.spacing,
    this.scaleSize,
    this.style,
    this.animStyle,
  })  : assert(controller != null),
        super(listenable: controller);

  /// PageView的控制器
  final PageController controller;

  /// 指示器的个数
  final int itemCount;

  /// 非选中的颜色
  final Color normalColor;

  /// 选中的颜色
  final Color selectedColor;

  /// 点的大小
  final double size;

  /// 点的间距
  final double spacing;

  /// 点的样式
  final BannerIndicatorStyle style;

  /// 动画样式
  final BannerIndicatorAnimStyle animStyle;

  /// 选中放大的倍数
  final double scaleSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(itemCount, (int index) {
        return _buildIndicator(index);
      }),
    );
  }

  Widget _buildIndicator(int index) {
    double maxZoom = animStyle == BannerIndicatorAnimStyle.scaled ? scaleSize : 1.0;
    // 当前未知
    double currentPosition = ((controller.page ?? controller.initialPage.toDouble()) % itemCount.toDouble());

    double selectedNess = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - (currentPosition - index).abs(),
      ),
    );
    // 是否是当前页面被选中
    // bool isCurrentPageSelected = index == (controller.page != null ? controller.page.round() % itemCount : 0);

    // 修复从0跳到最后一个时状态错误
    if (currentPosition > itemCount - 1 && index == 0) {
      selectedNess = 1 - (itemCount.toDouble() - currentPosition);
    }

    // 计算缩放大小
    double zoom = 1.0 + (maxZoom - 1.0) * selectedNess;

    // 取中间色
    final ColorTween selectedColorTween = ColorTween(begin: normalColor, end: selectedColor);
    return Container(
      width: size + (2 * spacing),
      height: size + (2 * spacing),
      child: Center(
        child: Material(
          shadowColor: Colors.black,
          elevation: 2.0,
          color: selectedColorTween.lerp(selectedNess),
          type: style == BannerIndicatorStyle.circle ? MaterialType.circle : MaterialType.button,
          child: Container(
            width: size * zoom,
            height: size * zoom,
          ),
        ),
      ),
    );
  }
}
