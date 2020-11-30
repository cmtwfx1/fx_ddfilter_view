# fx_ddfilter_view

A new Flutter package project.

![image](https://coding-pages-bucket-3485423-7990906-4062-359403-1301677377.cos-website.ap-hongkong.myqcloud.com/post-images/1604980647592.png)

## 1：fx_ddfilter_view.dart 布局文件说明

##### 1.1：FxDDFilterView 
`FxDDFilterView`一般作为一个界面的主体，包含一个封装好的筛选布局，以及一个需要传入的`子widget`。
包含属性如下：
```
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
    this.filterTextStyle = _FxDDFilterFooterTextStyle,
    this.cancelBtnTextStyle = _FxDDFilterFooterCancelTextStyle,
    this.sureBtnTextStyle = _FxDDFilterFooterSureTextStyle,
    @required this.child,
    @required this.height,
    @required this.controller,
  }) : super(key: key);
```
##### 1.2：_FxDDFilterLayout
`_FxDDFilterLayout`是一个私有的类，`FxDDFilterView`中的筛选布局都在`_FxDDFilterLayout`中实现
定义的属性如下：
```
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
```
如果弹出的筛选内容只是单一列表样式，则布局都在`_FxDDFilterLayout`中完成，如果是二级联动的筛选内容样式，则需要借助`_FxDDFilerPickerView`实现

##### 1.2：_FxDDFilerPickerView
`_FxDDFilerPickerView` 包含两个`CupertinoPicker`来实现二级联动的筛选内容框，一般可以实现左侧为省，右侧为市的选项。
定义属性如下：
```
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
```

##### 1.3：_FxDDFilerMoreSelectView
`_FxDDFilerMoreSelectView` 多条件筛选，当 maxSelectedCount 大于1，则构建此widget，可选择多个条件，显示取消确定按钮
```
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
```


## 2：fx_ddfilter_controller.dart 数据源文件说明

##### 2.1：FxDDFilterController
`FxDDFilterController`控制数据源和接收筛选条件的回调，支持动态修改数据源刷新界面布局。
属性介绍如下：
```
/// 数据源控制类
/// [selectedCallBack] 外部传入 - 选择筛选条件的回调，返回一个String，用来筛选栏显示文字
/// [_dataSource] 外部传入 - List<FxDDFilterInfo> 筛选界面所有的数据源，由外部传入，可动态修改
/// [titleList] 非外部传入 - 当前筛选栏显示的文字 由 selectedCallBack回调返回的字符串指定
/// [notifiReloadData] 非外部传入 - 动态修改数据源后 通知FxDDFilterView刷新界面布局
class FxDDFilterController {
  final FxDDFilterControllerSelectedCallBack selectedCallBack;
  List<FxDDFilterInfo> _dataSource = [];
  List<String> titleList = [];
  void Function(List<String>) notifiReloadData;
  
  FxDDFilterController({
    this.selectedCallBack
  });
```
* 注意1：非外部传入的属性不需要外部定义，防止出现错乱
* 注意2：动态设置 `dataSource` 之后，需调用 `reloadData` 方法布局才会更新
##### 2.2：FxDDFilterInfo<T>
`FxDDFilterInfo<T>` 为数据源类型，为了后期扩展支持泛型，目前建议`T`为`FxDDFilterItemInfo`或者`FxDDFilterItemSecLinkInfo`类型。

`FxDDFilterItemInfo`：为单一筛选条件列表需要的数据类型
`FxDDFilterItemSecLinkInfo`：为二级联动筛选条件列表需要的数据类型

## 3：使用方式

布局方式：
```
Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APP名称',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('app')
          ),
          body: FxDDFilterView(
          divider: VerticalDivider(
            color: Color(0xFFCECECE),
            indent: 8,
            endIndent: 10,
          ), 
          controller: fxDDFilterController,
          height: 50,
          // arrowImage: Image.asset('assets/images/icon/details-arrow-down.png'),
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Colors.green,
              width: 1
            )
          ),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return RaisedButton(
                child: Text('${_dataSource[index]}'),
                onPressed: () => {
                  // print('xxxxxxxxx')
                  updateData()
                },
              );
            },
            itemCount: _dataSource.length,
          ),
        )
      ),
    );
  }
```
根据`FxDDFilterController`传入的数据源类型，可自动区分筛选条件样式类型
```
  FxDDFilterController fxDDFilterController;
  List<String> _dataSource = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];

 void initState() {
    super.initState();
    fxDDFilterController = FxDDFilterController(selectedCallBack: (isInit, id, ids, names) {
      String showName = '';
      if (names.length > 1) {
        showName = '多条件';
        // return names.toString();
      }else if (names.first.contains('-')) {
        showName = names.first.split('-').last;
      }else showName = names.first;
      if (!isInit) {
        // isInit true 表示初始化时选中筛选条件的回调，有多个筛选条件会被多次回调
        setState(() {
          _dataSource.add(showName);
        });
      }
      return showName;
    });
    fxDDFilterController.dataSource = [
      FxDDFilterInfo<FxDDFilterItemSecLinkInfo>('1', data: [FxDDFilterItemSecLinkInfo(id: '11', name: '安徽省', subItems: [FxDDFilterItemInfo(id: '11', name: '合肥市'), FxDDFilterItemInfo(id: '12', name: '芜湖市')]),
                                                            FxDDFilterItemSecLinkInfo(id: '22', name: '江苏省', subItems: [FxDDFilterItemInfo(id: '11', name: '南京市'), FxDDFilterItemInfo(id: '12', name: '苏州市')]),
                                                            FxDDFilterItemSecLinkInfo(id: '33', name: '浙江省', subItems: [FxDDFilterItemInfo(id: '11', name: '杭州市'), FxDDFilterItemInfo(id: '12', name: '宁波市')]), 
                                                            FxDDFilterItemSecLinkInfo(id: '44', name: '广东省', subItems: [FxDDFilterItemInfo(id: '11', name: '广州市'), FxDDFilterItemInfo(id: '12', name: '深圳市')]),
                                                            FxDDFilterItemSecLinkInfo(id: '55', name: '福建省', subItems: [FxDDFilterItemInfo(id: '11', name: '福州市'), FxDDFilterItemInfo(id: '12', name: '厦门市'), FxDDFilterItemInfo(id: '13', name: '武夷山市')]),
                                                            FxDDFilterItemSecLinkInfo(id: '66', name: '云南省', subItems: [FxDDFilterItemInfo(id: '11', name: '昆明市'), FxDDFilterItemInfo(id: '12', name: '大理石'), FxDDFilterItemInfo(id: '13', name: '丽江市'), FxDDFilterItemInfo(id: '14', name: '攀枝花市')])
                                                            ]),
      FxDDFilterInfo<FxDDFilterItemInfo>('2', data: [FxDDFilterItemInfo(id: '21', name: '条件221'), FxDDFilterItemInfo(id: '22', name: '条件222')], maxSelectedCount: 2),
      FxDDFilterInfo<FxDDFilterItemInfo>('3', data: [FxDDFilterItemInfo(id: '31', name: '条件331'), FxDDFilterItemInfo(id: '32', name: '条件332')])
    ];
  }
```
动态修改数据源：
```
  void updateData() {
    fxDDFilterController.dataSource = [
      FxDDFilterInfo<FxDDFilterItemInfo>('1', data: [FxDDFilterItemInfo(id: '11', name: '条件111'), 
                                                    FxDDFilterItemInfo(id: '12', name: '条件112')], 
                                              maxSelectedCount: 2),
      FxDDFilterInfo<FxDDFilterItemInfo>('2', data: [FxDDFilterItemInfo(id: '21', name: '条件221'),
                                                    FxDDFilterItemInfo(id: '22', name: '条件222')]),
      FxDDFilterInfo<FxDDFilterItemInfo>('3', data: [FxDDFilterItemInfo(id: '31', name: '条件331'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332'), 
                                                    FxDDFilterItemInfo(id: '32', name: '条件332')])
    ];
    fxDDFilterController.reloadData();
  }
```
