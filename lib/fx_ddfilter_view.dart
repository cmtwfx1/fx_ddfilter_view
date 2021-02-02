import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'fx_ddfilter_controller.dart';

const Color _FxDDFilterLineColor = Color(0xFFF2F2F2);
const VerticalDivider _FxDDFilterHeaderDivider = VerticalDivider( color: Color(0xFFCECECE), indent: 10, endIndent: 10);
const TextStyle _FxDDFilterHeaderTextStyle = TextStyle(fontSize: 14, color: Color(0xFF333333));
const TextStyle _FxDDFilterFooterTextStyle = TextStyle(fontSize: 16, color: Color(0xFF333333));
const TextStyle _FxDDFilterFooterCancelTextStyle = TextStyle(fontSize: 14, color: Color(0xFF8C8C8C));
const TextStyle _FxDDFilterFooterSureTextStyle = TextStyle(fontSize: 14, color: Color(0xFF726FFF));

typedef _FxDDFilterHeaderCallBack = void Function(int index);
/// [secLinkItemInfo] 二级列表联动返回
/// [itemInfo] 选择的项
typedef _FxDDFilterFooterCallBack = void Function(FxDDFilterItemSecLinkInfo secLinkItemInfo, List<FxDDFilterItemInfo> itemInfos);

class _FxDDFilterLayout {
  final VerticalDivider headerDivider;
  final TextStyle headerTextStyle;
  final Image headerImage;
  final double footerItemHeight;
  final TextStyle footerTextStyle;
  final TextStyle cancelBtnTextStyle;
  final TextStyle sureBtnTextStyle;
  
  /// [headerDivider] 筛选显示栏的分割线
  /// [headerTextStyle] 筛选显示栏的文本样式
  /// [headerImage] 筛选显示栏的箭头图标，自动旋转90度
  /// [footerItemHeight] 弹出筛选条件内容的单行高度
  /// [footerTextStyle] 弹出筛选条件内容的文本样式
  /// [cancelBtnTextStyle] 如果是二级联动筛选样式的取消按钮样式
  /// [sureBtnTextStyle] 如果是二级联动筛选样式的确定按钮样式
  _FxDDFilterLayout({
    this.headerDivider,
    this.headerTextStyle,
    this.headerImage,
    this.footerItemHeight,
    this.footerTextStyle,
    this.cancelBtnTextStyle,
    this.sureBtnTextStyle
  });

  List<Widget> buildHeader(List<String> data, int openIndex, _FxDDFilterHeaderCallBack handle) {
    List<Widget> listData = [];
    for (var i=0; i<data.length; i++) {
      final name = data[i];
      listData.add(_buildHeaderItem(name, i, openIndex == i, handle));
      if (i != data.length - 1 && headerDivider != null) {
        listData.add(headerDivider);
      }
    }
    return listData;
  }

  Widget _buildHeaderItem(String name, int index, bool open, _FxDDFilterHeaderCallBack handle) {
    return Expanded(
      flex: 1,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name, 
              style: headerTextStyle
            ),
            RotatedBox(
              quarterTurns: open ? 2 : 0,
              child: headerImage != null ? headerImage : Icon(Icons.arrow_drop_down),
            )
            // open ? : Image.asset('assets/images/icon/details-arrow-down.png')
          ],
        ),
        onPressed: () => {
          handle(index)
        },
      )
    );
  }

  Widget buildFooter(FxDDFilterInfo filterInfo, _FxDDFilterFooterCallBack handle) {
    // 1: 根据内容判断显示的样式
    if (filterInfo[0] is FxDDFilterItemSecLinkInfo) {
      return Container(
        child: _FxDDFilerPickerView(
          key: Key(filterInfo.id),
          rowHeight: footerItemHeight,
          data: filterInfo,
          textStyle: headerTextStyle,
          handle: handle,
          cancelBtnTextStyle: cancelBtnTextStyle,
          sureBtnTextStyle: sureBtnTextStyle,
        ),
        decoration: BoxDecoration(
          color: Colors.white
        ),
      );
    }else if (filterInfo.maxSelectedCount > 1) {
      return _FxDDFilerMoreSelectView(
        rowHeight: footerItemHeight,
        data: filterInfo,
        textStyle: headerTextStyle,
        handle: handle,
        cancelBtnTextStyle: cancelBtnTextStyle,
        sureBtnTextStyle: sureBtnTextStyle,
      );
    }else if (filterInfo[0] is FxDDFilterItemInfo) {
      if (filterInfo.dataDirection == FxDDFilterSingleLineDataDirection.center) {
        return Scrollbar(
          child: ListView.separated(
            separatorBuilder: (context, index) =>  Divider(color: _FxDDFilterLineColor, height: 0.5),
            itemBuilder: (context, index) {
              FxDDFilterItemInfo itemInfo = filterInfo[index];
              return _buildFooterCenter(itemInfo, filterInfo.isSelected(itemInfo), handle);
            },
            itemCount: filterInfo.itemCount,
          ),
        );
      }else {
        return Scrollbar(
          child: ListView.separated(
            separatorBuilder: (context, index) =>  Divider(color: _FxDDFilterLineColor, height: 0.5),
            itemBuilder: (context, index) {
              FxDDFilterItemInfo itemInfo = filterInfo[index];
              return _buildFooterLeft(itemInfo, filterInfo.isSelected(itemInfo), handle);
            },
            itemCount: filterInfo.itemCount,
          )
        );
      }
    }else {
      return Text('暂不支持此类型');
    }
  }

  Widget _buildFooterLeft(FxDDFilterItemInfo itemInfo, bool isSelected, _FxDDFilterFooterCallBack handle) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: footerItemHeight,
      child: CupertinoButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              itemInfo.name,
              style: footerTextStyle,
            ),
            Icon(isSelected ? Icons.arrow_drop_down: Icons.arrow_drop_up)
            // Image.asset(isSelected ? 'assets/images/icon/details-arrow-down.png' : 'assets/images/icon/details-arrow-up.png')
          ],
        ),
        onPressed: () => handle(null, [itemInfo])
      )
    );
  }

  Widget _buildFooterCenter(FxDDFilterItemInfo itemInfo, bool isSelected, _FxDDFilterFooterCallBack handle) {
    return Container(
      height: footerItemHeight,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          itemInfo.name,
          style: footerTextStyle,
        ),
        onPressed: () => handle(null, [itemInfo]),
      ),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFEDEDFE) : Colors.white
      ),
    );
  }
}

/*-----------------------------------分割线-----------------------------------------*/

class _FxDDFilerPickerView extends StatefulWidget {

  final double rowHeight;
  final FxDDFilterInfo data;
  final TextStyle textStyle;
  final TextStyle cancelBtnTextStyle;
  final TextStyle sureBtnTextStyle;
  final _FxDDFilterFooterCallBack handle;

  /// [rowHeight] 单个row的高度
  /// [textStyle] 内容文本样式
  /// [cancelBtnTextStyle] 如果是二级联动筛选样式的取消按钮样式
  /// [sureBtnTextStyle] 如果是二级联动筛选样式的确定按钮样式
  /// [data] FxDDFilterInfo 整个筛选的添加内容数据源
  /// [handle] 确认和取消的回调
  _FxDDFilerPickerView({
    Key key,
    this.rowHeight = 50,
    this.textStyle,
    this.cancelBtnTextStyle,
    this.sureBtnTextStyle,
    @required this.data,
    @required this.handle
  }) : super(key: key);

  @override
  __FxDDFilerPickerViewState createState() => __FxDDFilerPickerViewState();
}

class __FxDDFilerPickerViewState extends State<_FxDDFilerPickerView> {

  FxDDFilterItemSecLinkInfo _currentSecLinkInfo;
  FxDDFilterItemInfo _currentItemInfo;
  FixedExtentScrollController secLinkInfoScrollController;
  FixedExtentScrollController itemInfoScrollController;

  @override
  void initState() { 
    super.initState();
    int currentSecLinkInfoIndex = initSelectedSecLinkInfo(widget.data);
    _currentSecLinkInfo = widget.data[currentSecLinkInfoIndex];

    int currentItemInfoIndex = initSelectedItemInfo(widget.data, _currentSecLinkInfo);
    _currentItemInfo = _currentSecLinkInfo.subItems[currentItemInfoIndex];

    secLinkInfoScrollController = FixedExtentScrollController(initialItem: currentSecLinkInfoIndex);
    itemInfoScrollController = FixedExtentScrollController(initialItem: currentItemInfoIndex);
  }

  static int initSelectedSecLinkInfo(FxDDFilterInfo data) {
    List<String> ids = data.selectedIds.first.split('-');
    String leftId = ids.first;
    for (int i=0; i<data.itemCount; i++) {
      FxDDFilterItemSecLinkInfo secLinkInfo = data[i];
      if (secLinkInfo.id == leftId) {
        return i;
      }
    }
    return 0;
  }

  static int initSelectedItemInfo(FxDDFilterInfo data, FxDDFilterItemSecLinkInfo secLinkInfo) {
    List<String> ids = data.selectedIds.first.split('-');
    String rightId = ids.last;
    for (int i=0; i<secLinkInfo.subItems.length; i++) {
      FxDDFilterItemInfo itemInfo = secLinkInfo.subItems[i];
      if (itemInfo.id == rightId) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Column(
            children: [
              Flexible(
                child: CupertinoPicker.builder(
                  itemExtent: widget.rowHeight,
                  backgroundColor: Colors.white,
                  scrollController: secLinkInfoScrollController,
                  onSelectedItemChanged: (index) {
                    // 控制二级列表
                    itemInfoScrollController.jumpToItem(0);
                    this.setState(() {
                      _currentSecLinkInfo = widget.data[index];
                    });
                    this._currentItemInfo = _currentSecLinkInfo.subItems[0];
                  }, 
                  itemBuilder: (context, index) {
                    return Center(
                      child: Text(
                        widget.data[index].name, 
                        style: widget.textStyle
                      )
                    );
                  },
                  childCount: widget.data.itemCount,
                ),
              ),
              Container(
                child: CupertinoButton(
                  child: Center(
                    child: Text(
                      "取消",
                      style: widget.cancelBtnTextStyle
                    ),
                  ),
                  onPressed: () => widget.handle(null, null)
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: _FxDDFilterLineColor,
                      width: 0.5
                    )
                  )
                ),
              )
            ],
          )
        ),
        Flexible(
          child: Column(
            children: [
              Flexible(
                child: CupertinoPicker.builder(
                  itemExtent: widget.rowHeight, 
                  backgroundColor: Colors.white,
                  scrollController: itemInfoScrollController,
                  onSelectedItemChanged: (index) {
                    this._currentItemInfo = _currentSecLinkInfo.subItems[index];
                  }, 
                  itemBuilder: (context, index) {
                    String name = _currentSecLinkInfo.subItems[index].name;
                    return Center(
                      child: Text(
                        name, 
                        style: widget.textStyle
                      ),
                    );
                  },
                  childCount: _currentSecLinkInfo.subItems.length,
                )
              ),
              Container(
                child: CupertinoButton(
                  child: Center(
                    child: Text(
                      "确定",
                      style: widget.sureBtnTextStyle,
                    ),
                  ),
                  onPressed: () => {
                    widget.handle(_currentSecLinkInfo, [_currentItemInfo])
                  },
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: _FxDDFilterLineColor,
                      width: 0.5
                    )
                  )
                ),
              )
            ],
          )
        )
      ],
    );
  }
}


/*-----------------------------------分割线-----------------------------------------*/
class _FxDDFilerMoreSelectView extends StatefulWidget {
  /// [rowHeight] 单个row的高度
  /// [textStyle] 内容文本样式
  /// [cancelBtnTextStyle] 如果是二级联动筛选样式的取消按钮样式
  /// [sureBtnTextStyle] 如果是二级联动筛选样式的确定按钮样式
  /// [data] FxDDFilterInfo 整个筛选的添加内容数据源
  /// [handle] 确认和取消的回调
  _FxDDFilerMoreSelectView({
    Key key,
    this.rowHeight,
    this.data,
    this.textStyle,
    this.cancelBtnTextStyle,
    this.sureBtnTextStyle,
    this.handle
  }) : super(key: key);

  final double rowHeight;
  final FxDDFilterInfo data;
  final TextStyle textStyle;
  final TextStyle cancelBtnTextStyle;
  final TextStyle sureBtnTextStyle;
  final _FxDDFilterFooterCallBack handle;

  @override
  __FxDDFilerMoreSelectViewState createState() => __FxDDFilerMoreSelectViewState();
}

class __FxDDFilerMoreSelectViewState extends State<_FxDDFilerMoreSelectView> {

  List<FxDDFilterItemInfo> _mySelectedItems = [];

  @override
  void initState() {
    super.initState();
    for (int i=0; i<widget.data.itemCount; i++) {
      FxDDFilterItemInfo itemInfo = widget.data[i];
      if (widget.data.selectedIds.contains(itemInfo.id)) {
        _mySelectedItems.add(itemInfo);
      }
    }
  }

  void touchFilerItem(FxDDFilterItemInfo itemInfo) {
    setState(() {
      if (_mySelectedItems.contains(itemInfo)) {
        _mySelectedItems.remove(itemInfo);
      }else {
        _mySelectedItems.add(itemInfo);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) =>  Divider(color: _FxDDFilterLineColor, height: 0.5),
              itemBuilder: (context, index) {
                FxDDFilterItemInfo itemInfo = widget.data[index];
                return Container(
                  height: widget.rowHeight,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      itemInfo.name,
                      style: widget.textStyle,
                    ),
                    onPressed: () => touchFilerItem(itemInfo),
                  ),
                  decoration: BoxDecoration(
                    color: _mySelectedItems.contains(itemInfo) ? Color(0xFFEDEDFE) : Colors.white
                  ),
                );
              },
              itemCount: widget.data.itemCount,
            )
          ),
          Container(
            height: widget.rowHeight,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CupertinoButton(
                  child: Text(
                    '取消',
                    style: widget.cancelBtnTextStyle
                  ),
                  onPressed: () => widget.handle(null, null),
                ),
                CupertinoButton(
                  child: Text(
                    '确定',
                    style: widget.sureBtnTextStyle
                  ),
                  onPressed: () => widget.handle(null, _mySelectedItems),
                )
              ],
            ),
            color: Colors.white,
          )
        ],
      ),
    );
  }
}

/*-----------------------------------分割线-----------------------------------------*/

class FxDDFilterView extends StatefulWidget {
  /// [border] 边框
  /// [divider] 传入分割线，默认没有分割线
  /// [filterHeight] 下拉筛选框 单个条件的高度
  /// [textStyle] 文字显示样式，有默认类型 fontSize: 14, color: Color(0xFF333333)
  /// [filterTextStyle] 下拉筛选框 内容文字样式，默认 fontSize: 16, color: Color(0xFF333333)
  /// [cancelBtnTextStyle] 二级联动筛选取消按钮样式
  /// [sureBtnTextStyle] 二级联动筛选确认按钮样式
  /// [child] 因为筛选弹框一般覆盖在上层，需要使用 Stack 布局
  /// [height] 控件的高度
  /// [controller] FxDDFilterController 数据源控制器
  FxDDFilterView({
    Key key,
    this.border,
    this.divider = _FxDDFilterHeaderDivider,
    this.filterHeight = 50,
    this.textStyle = _FxDDFilterHeaderTextStyle,
    this.arrowImage,
    this.filterTextStyle = _FxDDFilterFooterTextStyle,
    this.cancelBtnTextStyle = _FxDDFilterFooterCancelTextStyle,
    this.sureBtnTextStyle = _FxDDFilterFooterSureTextStyle,
    @required this.child,
    @required this.height,
    @required this.controller,
  }) : _filterDelegate = _FxDDFilterLayout(
          headerDivider: divider,
          headerTextStyle: textStyle,
          headerImage: arrowImage,
          footerItemHeight: filterHeight,
          footerTextStyle: filterTextStyle,
          cancelBtnTextStyle: cancelBtnTextStyle,
          sureBtnTextStyle: sureBtnTextStyle
        ),
      super(key: key);
  
  final VerticalDivider divider;
  final Border border;
  final double height;
  final TextStyle textStyle;
  final Image arrowImage;
  final double filterHeight;
  final TextStyle filterTextStyle;
  final FxDDFilterController controller;
  final Widget child;
  final TextStyle cancelBtnTextStyle;
  final TextStyle sureBtnTextStyle;
  final _FxDDFilterLayout _filterDelegate;

  @override
  _FxDDFilterViewState createState() => _FxDDFilterViewState();
}

class _FxDDFilterViewState extends State<FxDDFilterView> {

  bool _showFilterView = false;
  // 控制显示筛选下拉界面
  int _currentHeaderSelectedIndex = -1;
  FxDDFilterInfo _currentFilterItemInfo;
  @override
  void initState() {
    super.initState();
    widget.controller.notifiReloadData = (List<String> titleList) {
      this.setState(() {
          widget.controller.titleList = titleList;
          _showFilterView = false;
        });
    };
  }
  
  // function
  void footerSelectedAction(FxDDFilterItemSecLinkInfo secLinkItemInfo, List<FxDDFilterItemInfo> itemInfos) {
    if (itemInfos == null) { // 取消
        setState(() {
          _showFilterView = false;
        });
        return;
      }
      if (secLinkItemInfo == null) {  // 单列表回调
        List<String> titleList = widget.controller.selectItem(_currentFilterItemInfo, itemInfos);
        setState(() {
          widget.controller.titleList = titleList;
          _showFilterView = false;
        });
      }else { // 二级联动列表回调
        List<String> titleList = widget.controller.selectSecLinkItem(_currentFilterItemInfo, secLinkItemInfo, itemInfos.first);
        setState(() {
          widget.controller.titleList = titleList;
          _showFilterView = false;
        });
      }
  }

  // getter
  List<Widget> get filterHeaderViewWidget {
    return widget._filterDelegate.buildHeader(
      widget.controller.titleList, _showFilterView ? _currentHeaderSelectedIndex : -1, 
      (int index) => {
        this.currentHeaderSelectedIndex = index
      }
    );
  }
  double get filterFooterViewHeight {
    if (_currentFilterItemInfo == null || !_showFilterView) {
      return 0;
    }
    double height = _currentFilterItemInfo.maxSelectedCount > 1 ? 50 : 0;
    if (_currentFilterItemInfo.inType == 1) {
      if (_showFilterView) {
        if (_currentFilterItemInfo.itemCount > 10) {
          return 10.5 * widget._filterDelegate.footerItemHeight + height;
        }
        return _currentFilterItemInfo.itemCount * widget._filterDelegate.footerItemHeight + height;
      }
    }
    if (_currentFilterItemInfo.inType == 2) {
      return _currentFilterItemInfo.itemCount * widget._filterDelegate.footerItemHeight + height; 
    }
    return 0;
  }

  Widget get filterFooterViewWidget {
    if (_showFilterView == false || _currentFilterItemInfo == null) {
      return Container(height: 0, width: 0);
    }
    return widget._filterDelegate.buildFooter(_currentFilterItemInfo, footerSelectedAction);
  }
  // setter
  set currentHeaderSelectedIndex(int index) {
    FxDDFilterInfo itemInfo = widget.controller.dataSource[index];
    bool isShow;
    if (_currentHeaderSelectedIndex == index) {
      isShow = !_showFilterView;
    }else {
      isShow = true;
    }
    setState(() {
      _currentHeaderSelectedIndex = index;
      _showFilterView = isShow;
      _currentFilterItemInfo = itemInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            child: Row(
              children: filterHeaderViewWidget,
            ),
            decoration: BoxDecoration(
              border: widget.border
            ),
            height: widget.height,
          ),
        ),
        Positioned(
          top: widget.height,
          left: 0,
          right: 0,
          bottom: 0,
          child: widget.child,
        ),
        _showFilterView ? Positioned(
          top: widget.height,
          left: 0,
          right: 0,
          bottom: 0,
          child: Offstage(
            offstage: !_showFilterView,
            child:  Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.5)
              ),
           )
          )
        ) : Positioned(
          top: widget.height, 
          left: 0, 
          height: 0,
          child: Container()
        ),
        Positioned(
          top: widget.height,
          left: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            child: Container(
              height: filterFooterViewHeight,
              child: filterFooterViewWidget,
              color: Colors.white
            ),
          )
        )
      ],
    );
  }
}