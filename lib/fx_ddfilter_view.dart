import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'fx_ddfilter_controller.dart';

const Color _FxDDFilterLineColor = Color(0xFFF2F2F2);
const VerticalDivider _FxDDFilterHeaderDivider = VerticalDivider( color: Color(0xFFCECECE));
const TextStyle _FxDDFilterHeaderTextStyle = TextStyle(fontSize: 14, color: Color(0xFF333333));
const TextStyle _FxDDFilterFooterTextStyle = TextStyle(fontSize: 16, color: Color(0xFF333333));
const TextStyle _FxDDFilterFooterCancelTextStyle = TextStyle(fontSize: 14, color: Color(0xFF8C8C8C));
const TextStyle _FxDDFilterFooterSureTextStyle = TextStyle(fontSize: 14, color: Color(0xFF726FFF));

typedef _FxDDFilterHeaderCallBack = void Function(int index);
/// [secLinkItemInfo] 二级列表联动返回
/// [itemInfo] 选择的项
typedef _FxDDFilterFooterCallBack = void Function(FxDDFilterItemSecLinkInfo secLinkItemInfo, FxDDFilterItemInfo itemInfo);

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name, 
              style: headerTextStyle
            ),
            RotatedBox(
              quarterTurns: open ? 2 : 0,
              child: headerImage,
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
    }else if (filterInfo[0] is FxDDFilterItemInfo) {
      if (filterInfo.dataDirection == FxDDFilterSingleLineDataDirection.center) {
        return ListView.builder(
          itemBuilder: (context, index) {
            FxDDFilterItemInfo itemInfo = filterInfo[index];
            return _buildFooterCenter(itemInfo, filterInfo.isSelected(itemInfo), handle);
          },
          itemCount: filterInfo.itemCount,
        );
      }else {
        return ListView.builder(
          itemBuilder: (context, index) {
            FxDDFilterItemInfo itemInfo = filterInfo[index];
            return _buildFooterLeft(itemInfo, filterInfo.isSelected(itemInfo), handle);
          },
          itemCount: filterInfo.itemCount,
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
            Image.asset(isSelected ? 'assets/images/icon/details-arrow-down.png' : 'assets/images/icon/details-arrow-up.png')
          ],
        ),
        onPressed: () => handle(null, itemInfo)
      )
    );
  }

  Widget _buildFooterCenter(FxDDFilterItemInfo itemInfo, bool isSelected, _FxDDFilterFooterCallBack handle) {
    return Container(
      height: footerItemHeight,
      child: Center(
        child: CupertinoButton(
          child: Text(
            itemInfo.name,
            style: footerTextStyle,
          ),
          onPressed: () => handle(null, itemInfo)
        )
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
  __FxDDFilerPickerViewState createState() => __FxDDFilerPickerViewState(
    rowHeight: rowHeight,
    textStyle: textStyle,
    dataSource: data,
    handle: handle,
    cancelBtnTextStyle: cancelBtnTextStyle,
    sureBtnTextStyle: sureBtnTextStyle
  );
}

class __FxDDFilerPickerViewState extends State<_FxDDFilerPickerView> {

  final double rowHeight;
  final TextStyle textStyle;
  final TextStyle cancelBtnTextStyle;
  final TextStyle sureBtnTextStyle;
  final _FxDDFilterFooterCallBack handle;
  final FxDDFilterInfo dataSource;

  FxDDFilterItemSecLinkInfo _currentSecLinkInfo;
  FxDDFilterItemInfo _currentItemInfo;
  FixedExtentScrollController secLinkInfoScrollController;
  FixedExtentScrollController itemInfoScrollController;

  __FxDDFilerPickerViewState({
    this.rowHeight,
    this.textStyle,
    this.cancelBtnTextStyle,
    this.sureBtnTextStyle,
    this.dataSource,
    @required this.handle
  }) {
    int currentSecLinkInfoIndex = initSelectedSecLinkInfo(dataSource);
    _currentSecLinkInfo = dataSource[currentSecLinkInfoIndex];

    int currentItemInfoIndex = initSelectedItemInfo(dataSource, _currentSecLinkInfo);
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
                  itemExtent: rowHeight,
                  backgroundColor: Colors.white,
                  scrollController: secLinkInfoScrollController,
                  onSelectedItemChanged: (index) => this.setState(() {
                    _currentSecLinkInfo = dataSource[index];
                  }), 
                  itemBuilder: (context, index) {
                    return Center(
                      child: Text(
                        dataSource[index].name, 
                        style: textStyle
                      )
                    );
                  },
                  childCount: dataSource.itemCount,
                ),
              ),
              Container(
                child: CupertinoButton(
                  child: Center(
                    child: Text(
                      "取消",
                      style: cancelBtnTextStyle
                    ),
                  ),
                  onPressed: () => {
                    handle(null, null)
                  }
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
                  itemExtent: rowHeight, 
                  backgroundColor: Colors.white,
                  scrollController: itemInfoScrollController,
                  onSelectedItemChanged: (index) => this._currentItemInfo = _currentSecLinkInfo.subItems[index], 
                  itemBuilder: (context, index) {
                    String name = _currentSecLinkInfo.subItems[index].name;
                    return Center(
                      child: Text(
                        name, 
                        style: textStyle
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
                      style: sureBtnTextStyle,
                    ),
                  ),
                  onPressed: () => {
                    handle(_currentSecLinkInfo, _currentItemInfo)
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

class FxDDFilterView extends StatefulWidget {
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
  }) : super(key: key);
  
  @override
  _FxDDFilterViewState createState() => _FxDDFilterViewState(
    divider: divider,
    border: border, 
    textStyle: textStyle,
    arrowImage: arrowImage,
    filterHeight: filterHeight,
    filterTextStyle: filterTextStyle,
    cancelBtnTextStyle: cancelBtnTextStyle,
    sureBtnTextStyle: sureBtnTextStyle,
    height: height, 
    child: child,
    controller: controller
  );
}

class _FxDDFilterViewState extends State<FxDDFilterView> {
  final FxDDFilterController _controller;
  final _FxDDFilterLayout _filterDelegate;
  final Border _border;
  final double _height;
  final Widget _child;
  // 控制显示筛选下拉界面
  int _currentHeaderSelectedIndex = -1;
  bool _showFilterView = false;
  FxDDFilterInfo _currentFilterItemInfo;

  /// [divider] 传入分割线，默认没有分割线
  /// [border] 边框
  /// [textStyle] 文字显示样式，有默认类型 fontSize: 14, color: Color(0xFF333333)
  /// [arrowImage] 箭头图标
  /// [filterHeight] 下拉筛选框 单个条件的高度
  /// [filterTextStyle] 下拉筛选框 内容文字样式，默认 fontSize: 16, color: Color(0xFF333333)
  /// [height] 控件的高度
  /// [controller] FxDDFilterController控制数据源
  _FxDDFilterViewState({
    VerticalDivider divider,
    Border border,
    TextStyle textStyle,
    Image arrowImage,
    double filterHeight,
    TextStyle filterTextStyle,
    TextStyle cancelBtnTextStyle,
    TextStyle sureBtnTextStyle,
    double height,
    FxDDFilterController controller,
    Widget child,
  }) :  _border = border,
        _height = height,
        _controller = controller,
        _child = child,
        _filterDelegate = _FxDDFilterLayout(
          headerDivider: divider,
          headerTextStyle: textStyle,
          headerImage: arrowImage,
          footerItemHeight: filterHeight,
          footerTextStyle: filterTextStyle,
          cancelBtnTextStyle: cancelBtnTextStyle,
          sureBtnTextStyle: sureBtnTextStyle
        );
  @override
  void initState() {
    super.initState();
    _controller.notifiReloadData = (List<String> titleList) {
      this.setState(() {
          _controller.titleList = titleList;
          _showFilterView = false;
        });
    };
  }
  
  // function
  void footerSelectedAction(FxDDFilterItemSecLinkInfo secLinkItemInfo, FxDDFilterItemInfo itemInfo) {
    if (itemInfo == null) { // 取消
        setState(() {
          _showFilterView = false;
        });
        return;
      }
      if (secLinkItemInfo == null) {  // 单列表回调
        List<String> titleList = this._controller.selectItem(_currentFilterItemInfo, itemInfo);
        bool isShow = true;
        if (_currentFilterItemInfo.maxSelectedCount == 1) {
          isShow = false;
        }
        setState(() {
          _controller.titleList = titleList;
          _showFilterView = isShow;
        });
      }else { // 二级联动列表回调
        List<String> titleList = this._controller.selectSecLinkItem(_currentFilterItemInfo, secLinkItemInfo, itemInfo);
        setState(() {
          _controller.titleList = titleList;
          _showFilterView = false;
        });
      }
  }

  // getter
  List<Widget> get filterHeaderViewWidget {
    return _filterDelegate.buildHeader(_controller.titleList, _showFilterView ? this._currentHeaderSelectedIndex : -1, (int index) => {
            this.currentHeaderSelectedIndex = index
          });
  }
  double get filterFooterViewHeight {
    if (_currentFilterItemInfo == null) {
      return 0;
    }
    if (_currentFilterItemInfo.inType == 1) {
      if (_showFilterView) {
        if (_currentFilterItemInfo.itemCount > 10) {
          return 10.5 * _filterDelegate.footerItemHeight;
        }
        return _currentFilterItemInfo.itemCount * _filterDelegate.footerItemHeight;
      }
    }
    if (_currentFilterItemInfo.inType == 2) {
      return _currentFilterItemInfo.itemCount * _filterDelegate.footerItemHeight; 
    }
    return 0;
  }

  Widget get filterFooterViewWidget {
    if (_showFilterView == false || _currentFilterItemInfo == null) {
      return Container(height: 0, width: 0);
    }
    return _filterDelegate.buildFooter(_currentFilterItemInfo, footerSelectedAction);
  }
  // setter
  set currentHeaderSelectedIndex(int index) {
    FxDDFilterInfo itemInfo = _controller.dataSource[index];
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
              border: _border
            ),
            height: _height,
          ),
        ),
        Positioned(
          top: _height,
          left: 0,
          right: 0,
          bottom: 0,
          child: _child,
        ),
        _showFilterView ? Positioned(
          top: _height,
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
          top: _height, 
          left: 0, 
          height: 0,
          child: Container()
        ),
        Positioned(
          top: _height,
          left: 0,
          right: 0,
          child: Container(
            height: filterFooterViewHeight,
            child: filterFooterViewWidget
          ),
        )
      ],
    );
  }
}