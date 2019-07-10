import 'package:flutter/material.dart';

/// Created  on 2019/7/9.
/// @author grey
/// Function : 单窗

Future<dynamic> showPopWindowView(BuildContext context, Widget widget,
    {bool isCancel: true, bool isTouchCancel: true}) async {
  return await Navigator.of(context)
      .push(PageRouteBuilder(
          maintainState: false,
          opaque: false,
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return PopWindowLayer(
              itemBuilder: widget,
              isCancel: isCancel,
              isTouchCancel: isTouchCancel,
            );
          }))
      .then((value) => value);
}

class PopWindowLayer extends StatelessWidget {
  PopWindowLayer({
    @required this.itemBuilder,
    isCancel,
    isTouchCancel,
  })  : this.isCancel = isCancel ?? true,
        this.isTouchCancel = isTouchCancel ?? true;

  ///点击返回键
  final bool isCancel;

  ///点击空白区域是否可隐藏
  final bool isTouchCancel;

  ///弹窗内容
  final Widget itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: Color(0x88000000),
      ),
      child: WillPopScope(
          child: Scaffold(
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: itemBuilder ?? Container(),
              onTap: () {
                if (isTouchCancel) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          onWillPop: () {
            if (isCancel) {
              Navigator.pop(context);
            }
          }),
    );
  }
}
