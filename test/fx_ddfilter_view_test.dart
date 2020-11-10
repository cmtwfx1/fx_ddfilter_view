import 'package:flutter/material.dart';
import 'package:fx_ddfilter_view/fx_ddfilter_view.dart';
import 'package:fx_ddfilter_view/fx_ddfilter_controller.dart';

void main() {
  // runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FxDDFilterController fxDDFilterController;

  @override
  void initState() {
    super.initState();
    fxDDFilterController = FxDDFilterController(selectedCallBack: (id, ids, names) {
      if (names.length > 1) {
        return '多条件';
        // return names.toString();
      }
      if (names.first.contains('-')) {
        return names.first.split('-').last;
      }
      return names.first;
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

  void updateData() {
      fxDDFilterController.dataSource = [
        FxDDFilterInfo<FxDDFilterItemInfo>('1', data: [FxDDFilterItemInfo(id: '11', name: '条件111'), FxDDFilterItemInfo(id: '12', name: '条件112')], maxSelectedCount: 2),
        FxDDFilterInfo<FxDDFilterItemInfo>('2', data: [FxDDFilterItemInfo(id: '21', name: '条件221'), FxDDFilterItemInfo(id: '22', name: '条件222')]),
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APP名称',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: FxDDFilterView(
          divider: VerticalDivider(
            color: Color(0xFFCECECE),
            indent: 8,
            endIndent: 10,
          ), 
          controller: fxDDFilterController,
          height: 50,
          arrowImage: Image.asset('assets/images/icon/details-arrow-down.png'),
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Colors.green,
              width: 1
            )
          ),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return RaisedButton(
                child: Text('点击'),
                onPressed: () => {
                  // print('xxxxxxxxx')
                  // updateData()
                },
              );
            },
            itemCount: 20,
          ),
        )
      ),
    );
  }
}
