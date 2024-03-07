import 'dart:math';
import 'package:blockchain_frontend_flutter/model/DataEntity.dart';
import 'package:blockchain_frontend_flutter/view/device_parameter/BlockCreate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../model/DataDto.dart';
import '../../model/BlockEntity.dart';

// 定義DataTableSource處理Table
class DataSource extends DataTableSource {
  List<DataEntity> _data = [];
  Set<DataEntity> _selectedRows = Set<DataEntity>();

  Function(int) onDeleteData;
  final Function(DataEntity) onEditData;

  DataSource({required this.onDeleteData, required this.onEditData});

  /* 更新Table顯示的區塊資料 */
  void updateWithData(List<DataEntity> fetchedData) {
    _data.clear();
    _data.addAll(fetchedData);
    notifyListeners(); // 通知監聽器已更新
  }

  /**
   * Column排序
   */
  void sort<T>(Comparable<T> Function(DataEntity d) getField, bool ascending) {
    _data.sort((DataEntity a, DataEntity b) {
      if (!ascending) {
        final DataEntity c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length || index < 0) return null; // 确保索引有效
    final item = _data[index];
    return DataRow(
        selected: _selectedRows.contains(item),
        onSelectChanged: (selected) {
          if (selected ?? false) {
            _selectedRows.add(item);
          } else {
            _selectedRows.remove(item);
          }
          notifyListeners();
        },
        cells: [
          DataCell(Text(item.id.toString())),
          DataCell(Text(item.data.toString())),
          DataCell(Text(item.createId.toString())),
          DataCell(Text(item.createTime.toString())),
          DataCell(Text(item.updateId.toString())),
          DataCell(Text(item.updateTime.toString())),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min, // 为了防止Row占用过多空间
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    onEditData(item);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    onDeleteData(item.id);
                  },
                ),
              ],
            ),
          )
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}

class DataPage extends StatefulWidget {
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  //創建區塊
  DataDto dataDto = DataDto(dataEntities: List.empty());

  // 創建UI的數據源
  late DataSource _dataSource;

  // 搜尋框的TextController
  TextEditingController _searchController = TextEditingController();

  //  Column排序
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _dataSource = DataSource(
        onDeleteData: _confirmDelete, onEditData: _editDataDialog);
    fetchData(); // 初始化先抓取區塊顯示
  }

  /**
   * 搜尋篩選區塊資料
   */
  void _searchAndUpdate(String searchText) {
    if (searchText.isEmpty) {
      fetchData(); // 若搜尋字串為空則抓取原本的區塊資料
    } else {
      // 過濾 DataDto.blockEntities 而不是 _allData
      var filteredData = dataDto.dataEntities.where((data) {
        // 根據需要匹配的字段進行過濾
        return data.data.toLowerCase().contains(searchText.toLowerCase()) ||
            data.createId.toLowerCase().contains(searchText.toLowerCase()) ||
            data.createTime
                .toLowerCase()
                .contains(searchText.toLowerCase()) ||
            data.updateId.toLowerCase().contains(searchText.toLowerCase()) ||
            data.updateTime.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
      _dataSource.updateWithData(filteredData); // 更新數據源
    }
  }

  /**
   * 後端API取得最新區塊資料
   */
  Future<void> fetchData() async {
    final response = //169.254.236.3 172.20.10.2
        await http.post(Uri.parse('http://'+ BlockCreate.IP_ADDRESS +':8888/getData'),
            //要為本地電腦的IP 模擬器不支援Localhost
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(dataDto.toJson()));

    if (response.statusCode == 200) {
      //後端回傳JSON處理
      // final result = jsonDecode(response.body);
      // 用utf8解析JSON，防止中文亂碼
      final result = jsonDecode(utf8.decode(response.bodyBytes));
      DataDto dataDtoResult = DataDto.fromJson(result);
      setState(() {
        dataDto = dataDtoResult; // 使用從後端獲取的數據更新DataDto
        _dataSource.updateWithData(dataDto.dataEntities); // 更新數據源
      });
    } else {
      //若後端無回應則報錯
      _showSnackBar('Fetch Data', '連線Error', 'Failed to load data', '');
    }
  }

  // 刪除確認對話框
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("警告"),
          content: Text("您確定要刪除 Id=" + id.toString() + " 的Data嗎"),
          actions: <Widget>[
            TextButton(
              child: Text("取消"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("確認"),
              onPressed: () {
                Navigator.of(context).pop();
                deleteData(id); // 傳送至後端刪除API
              },
            ),
          ],
        );
      },
    );
  }

//刪除區塊
  Future<void> deleteData(int id) async {
    DataDto deleteDto = DataDto(
        dataEntities: List.empty(),
        dataEntity: DataEntity(
            id: id,
            data: '',
            createId: '',
            createTime: '',
            updateId: '',
            updateTime: ''));

    final response = //169.254.236.3 172.20.10.2
        await http.post(Uri.parse('http://localhost:8888/deleteData'),
            //要為本地電腦的IP 模擬器不支援Localhost
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(deleteDto.toJson()));

    if (response.statusCode == 200) {
      // 用utf8解析JSON，防止中文亂碼
      final result = jsonDecode(utf8.decode(response.bodyBytes));
      DataDto dataDtoResult = DataDto.fromJson(result);
      _showSnackBar(
          'Delete Data',
          dataDtoResult.errorCode ?? 'No Error',
          dataDtoResult.errorMessage ?? 'No ErrorMessage',
          dataDtoResult.devMessage ?? 'No devMessage');
      fetchData();
    } else {
      _showSnackBar('Delete Data', '連線Error', 'Failed to load data', '');
    }
  }

  //修改區塊對話框
  void _editDataDialog(DataEntity dataEntity) {
    // TextEditingController 管理修改字串
    TextEditingController idController =
        TextEditingController(text: dataEntity.id.toString());
    TextEditingController dataController =
        TextEditingController(text: dataEntity.data);
    TextEditingController createIdController =
        TextEditingController(text: dataEntity.createId);
    TextEditingController createTimeController =
        TextEditingController(text: dataEntity.createTime);
    TextEditingController updateIdController =
        TextEditingController(text: dataEntity.updateId);
    TextEditingController updateTimeController =
    TextEditingController(text: dataEntity.updateTime);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "EDIT DATA",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Id:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                TextFormField(
                  controller: idController,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Data:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                TextFormField(
                  controller: dataController,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Create Id:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                TextFormField(
                  controller: createIdController,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Create Time:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                TextFormField(
                  controller: createTimeController,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Update Id:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                TextFormField(
                  controller: updateIdController,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Update Time:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                TextFormField(
                  controller: updateTimeController,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: Size(300, 50)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("CANCEL",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: Size(300, 50)),
              onPressed: () {
                editBlock(DataEntity(
                    id: int.parse(idController.text),
                    data: dataController.text,
                    createId: createIdController.text,
                    createTime: createTimeController.text,
                    updateId: updateIdController.text,
                    updateTime: updateTimeController.text));
                Navigator.of(context).pop();
              },
              child: Text("SUBMIT",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            ),
          ],
        );
      },
    );
  }

  //修改區塊
  Future<void> editBlock(DataEntity dataEntity) async {
    DataDto editDto = DataDto(
        dataEntities: List.empty(),
        dataEntity: DataEntity(
            id: dataEntity.id,
            data: dataEntity.data,
            createId: dataEntity.createId,
            createTime: dataEntity.createTime,
            updateId: dataEntity.updateId,
            updateTime: dataEntity.updateTime,)
    );

    final response = //169.254.236.3 172.20.10.2
        await http.post(Uri.parse('http://localhost:8888/editData'),
            //要為本地電腦的IP 模擬器不支援Localhost
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(editDto.toJson()));

    if (response.statusCode == 200) {
      // 用utf8解析JSON，防止中文亂碼
      final result = jsonDecode(utf8.decode(response.bodyBytes));
      DataDto dataDtoResult = DataDto.fromJson(result);
      _showSnackBar(
          'Edited Data',
          dataDtoResult.errorCode ?? 'No Error',
          dataDtoResult.errorMessage ?? 'No ErrorMessage',
          dataDtoResult.devMessage ?? 'No devMessage');

      fetchData();
    } else {
      _showSnackBar('Edited Data', '連線Error', 'Failed to edit Data', '');
    }
  }

  //通知訊息框 SnackBar
  void _showSnackBar(
      String method, String errorCode, String errorMessage, String devMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SelectableText(
          '功能： $method\n回傳代碼： $errorCode\nMessage： $errorMessage\nDev Message： $devMessage',
          style: TextStyle(fontSize: 20),
          toolbarOptions: ToolbarOptions(copy: true), // 允许复制
        ),
        duration: Duration(seconds: 5), // 持续时间
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
          child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1400), // 最大寬度1400
        child: PaginatedDataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          header: Row(
            children: [
              Expanded(
                child: Text(
                  'Data List',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search ( id , data, create id, create time, update id, update time )',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchAndUpdate('');
                      },
                    ),
                  ),
                  onChanged: _searchAndUpdate,
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          ),
          rowsPerPage: 10,
          columns: [
            DataColumn(
              label: Text(
                'Id',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onSort: (int columnIndex, bool ascending) {
                _dataSource.sort<num>((DataEntity d) => d.id, ascending);
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
            DataColumn(
              label: Text(
                'Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onSort: (int columnIndex, bool ascending) {
                _dataSource.sort<String>(
                    (DataEntity d) => d.data, ascending);
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
            DataColumn(
              label: Text(
                'Create Id',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onSort: (int columnIndex, bool ascending) {
                _dataSource.sort<String>(
                    (DataEntity d) => d.createId, ascending);
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
            DataColumn(
              label: Text(
                'Create Time',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onSort: (int columnIndex, bool ascending) {
                _dataSource.sort<String>(
                    (DataEntity d) => d.createTime, ascending);
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
            DataColumn(
              label: Text(
                'Update Id',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onSort: (int columnIndex, bool ascending) {
                _dataSource.sort<String>(
                    (DataEntity d) => d.updateId, ascending);
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
            DataColumn(
              label: Text(
                'Update Time',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onSort: (int columnIndex, bool ascending) {
                _dataSource.sort<String>(
                    (DataEntity d) => d.updateTime, ascending);
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
            DataColumn(
              label: Center(
                child: Text(
                  'Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          source: _dataSource,
        ),
      )),
    ));
  }
}
