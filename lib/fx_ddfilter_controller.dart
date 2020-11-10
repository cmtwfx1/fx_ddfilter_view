
enum FxDDFilterSingleLineDataDirection {
  left,
  center,
  right
}

/// 筛选框中的每个对象，包含 id 和 名称
class FxDDFilterItemInfo {
  final String id;
  final String name;

  FxDDFilterItemInfo({
    this.id,
    this.name
  });
}

/// 筛选框中的对象，二级联动列表显示
class FxDDFilterItemSecLinkInfo extends FxDDFilterItemInfo {
  final List<FxDDFilterItemInfo> subItems;

  FxDDFilterItemSecLinkInfo({
    String id,
    String name,
    this.subItems
  }) : super(id: id, name: name);
}

/// [T]: 类型可以为 String，FxDDFilterItemInfo，或者是 FxDDFilterItemSecLinkInfo
class FxDDFilterInfo<T> {
  final String id;
  final FxDDFilterSingleLineDataDirection dataDirection;
  final List<T> _data;
  final int maxSelectedCount;
  
  final List<List> defaultSelectedIdNames;
  List<String> _defaultSelectedIds;
  List<String> _defaultSelectedNames = [];
  List<String> _selectedIds;
  List<String> _selectedNames;

  /// [dataDirection] 筛选内容中的数据显示方向，默认在中间显示
  /// [data] 数据源，T一般为String、FxDDFilterItemInfo类型，单一列表显示
  /// [data] 暂不支持 - 如果T为List<FxDDFilterItemInfo>类型，则筛选为 某年某月 类型的 左右两个列表 - 暂不支持
  /// [data] 如果T为FxDDFilterItemSecLinkInfo类型，则筛选为 某省某市 类型的 左右联动列表
  /// [maxSelectedCount] 最大选中数量，可支持多选
  /// [defSelectedIds] 默认选中的 itemid，对于二级联动，id='idleft-idright'
  FxDDFilterInfo(this.id, {
    this.maxSelectedCount = 1,
    this.dataDirection = FxDDFilterSingleLineDataDirection.center,
    List<String> defSelectedIds,
    List<T> data,
  }) :  defaultSelectedIdNames = defSelectedIds == null ? initAutoDefSelected<T>(data) : initMyDefSelected<T>(defSelectedIds, data),
        _data = data {
    _defaultSelectedIds = defaultSelectedIdNames[0];
    _defaultSelectedNames = defaultSelectedIdNames[1];
    _selectedIds = _defaultSelectedIds;
    _selectedNames = _defaultSelectedNames;
  }

  static List<List<String>> initAutoDefSelected<T>(List<T> data) {
    if (data.first is FxDDFilterItemInfo) {
      FxDDFilterItemInfo itemInfo = data.first as FxDDFilterItemInfo;
      return [[itemInfo.id], [itemInfo.name]];
    }
    if (data.first is String) {
      String id = data.first as String;
      return [[id], [id]];
    }
    if (data.first is FxDDFilterItemSecLinkInfo) {
      FxDDFilterItemSecLinkInfo secLinkInfo = data.first as FxDDFilterItemSecLinkInfo;
      String id = secLinkInfo.id + '-' + secLinkInfo.subItems.first.id;
      String name = secLinkInfo.name + '-' + secLinkInfo.subItems.first.name;
      return [[id], [name]];
    }
    if (data.first is List) {
      List<String> ids = [];
      List<String> names = [];
      for (var vl in data) {
        if ((vl as List).first is FxDDFilterItemInfo) {
          FxDDFilterItemInfo itemInfo = (vl as List).first as FxDDFilterItemInfo;
          ids.add(itemInfo.id);
          names.add(itemInfo.name);
        }else if ((vl as List).first is String) {
          String id = (vl as List).first as String;
          ids.add(id);
          names.add(id);
        }
      }
      return [[ids.join('#,#')], [names.join('#,#')]];
    }
    return [];
  }

  static List<List<String>> initMyDefSelected<T>(List<String> ids, List data) {
    List<String> names = [];
    for (String id in ids) {
      for (var item in data) {
        if (item is FxDDFilterItemInfo && id == (item as FxDDFilterItemInfo).id) {
          names.add((item as FxDDFilterItemInfo).name);
          break;
        }else if (item is String && item == id) {
          names.add(id);
          break;
        }else if (item is FxDDFilterItemSecLinkInfo) {
          FxDDFilterItemSecLinkInfo secLinkInfo = item as FxDDFilterItemSecLinkInfo;
          if (id.startsWith(secLinkInfo.id + '-')) {
            for (FxDDFilterItemInfo info in secLinkInfo.subItems) {
              if (id == secLinkInfo.id + '-' + info.id) {
                names.add(secLinkInfo.name + '-' + info.name);
              }
            }
          }
        }else if (item is List) {
          List<List<String>> subIdNames = initMyDefSelected(ids, item as List);
          names.addAll(subIdNames[1]);
        }
      }
    }
    return [ids, names];
  }

  FxDDFilterItemInfo operator [](int index) {
    if (_data[index] is String) {
      return FxDDFilterItemInfo(id: '', name: _data[index] as String);
    }
    if (_data[index] is FxDDFilterItemInfo) {
      return _data[index] as FxDDFilterItemInfo;
    }
    return null;
  }

  /// 筛选的选项数量
  int get itemCount {
    return _data.length;
  }

  List<String> get selectedIds {
    return _selectedIds;
  }

  /// 当前item是否被选中了
  bool isSelected(FxDDFilterItemInfo itemInfo) {
    return _selectedIds.contains(itemInfo.id);
  }
  /// 判断内容
  int get inType {
    if (_data.first is FxDDFilterItemSecLinkInfo) {
      return 2;
    }else if (_data.first is FxDDFilterItemInfo) {
      return 1;
    }
    return 0;
  }
}

/* --------------------------------------------分割线---------------------------------------------*/

typedef FxDDFilterControllerSelectedCallBack = String Function(String id, List<String> ids, List<String> names);

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

  // getter
  List<FxDDFilterInfo> get dataSource {
    return _dataSource;
  }

  // setter
  set dataSource(List<FxDDFilterInfo> data) {
    _dataSource = data;
    titleList.clear();
    for (FxDDFilterInfo element in data) {
      titleList.add(selectedCallBack(element.id, element._defaultSelectedIds, element._defaultSelectedNames));
    }
  }

  void reloadData() {
    notifiReloadData(titleList);
  }

  /// 点击一个筛选条件
  /// [info] 当前的筛选
  /// [itemInfo] 当前点击的筛选条件
  List<String> selectItem(FxDDFilterInfo info, FxDDFilterItemInfo itemInfo) {
    List<String> selectTitleList = titleList;
    int index = _dataSource.indexOf(info);
    if (info.maxSelectedCount > 1) {
      // 需要判断是取消还是选中
      if (info.isSelected(itemInfo)) {
        if (info._selectedIds.length == 1) {
          String showName = selectedCallBack(info.id, info._selectedIds, info._selectedNames);
          selectTitleList[index] = showName;
        }else {
          info._selectedIds.remove(itemInfo.id);
          info._selectedNames.remove(itemInfo.name);
          String showName = selectedCallBack(info.id, info._selectedIds, info._selectedNames);
          selectTitleList[index] = showName;
        }
      }else {
        info._selectedIds.add(itemInfo.id);
        info._selectedNames.add(itemInfo.name);
        String showName = selectedCallBack(info.id, info._selectedIds, info._selectedNames);
        selectTitleList[index] = showName;
      }
    }else {
      info._selectedIds = [itemInfo.id];
      info._selectedNames = [itemInfo.name];
      String showName = selectedCallBack(info.id, info._selectedIds, info._selectedNames);
      selectTitleList[index] = showName;
    }
    return selectTitleList;
  }
  
  List<String> selectSecLinkItem(FxDDFilterInfo info, FxDDFilterItemSecLinkInfo secItemInfo, FxDDFilterItemInfo itemInfo) {
    List<String> selectTitleList = titleList;
    int index = _dataSource.indexOf(info);
    
    info._selectedIds = [secItemInfo.id + '-' + itemInfo.id];
    info._selectedNames = [secItemInfo.name + '-' + itemInfo.name];
    String showName = selectedCallBack(info.id, info._selectedIds, info._selectedNames);
    selectTitleList[index] = showName;

    return selectTitleList;
  }
}