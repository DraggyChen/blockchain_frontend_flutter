import 'dart:math';
import 'package:blockchain_frontend_flutter/view/device_parameter/BlockCreate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../model/BlockDto.dart';
import '../../model/BlockEntity.dart';

// 定義DataTableSource處理Table
class BlockDataSource extends DataTableSource {
  List<BlockEntity> _data = [];
  Set<BlockEntity> _selectedRows = Set<BlockEntity>();

  Function(int) onDeleteBlock;
  final Function(BlockEntity) onEditBlock;

  BlockDataSource({required this.onDeleteBlock, required this.onEditBlock});

  /* 更新Table顯示的區塊資料 */
  void updateWithData(List<BlockEntity> fetchedData) {
    _data.clear();
    _data.addAll(fetchedData);
    notifyListeners(); // 通知監聽器已更新
  }

  /**
   * Column排序
   */
  void sort<T>(Comparable<T> Function(BlockEntity d) getField, bool ascending) {
    _data.sort((BlockEntity a, BlockEntity b) {
      if (!ascending) {
        final BlockEntity c = a;
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
          DataCell(Text(item.no.toString())),
          DataCell(Text(item.nonce.toString())),
          DataCell(Text(item.time.toString())),
          DataCell(Text(item.data.toString())),
          DataCell(Text(item.previousHash.toString())),
          DataCell(Text(item.hash.toString())),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min, // 为了防止Row占用过多空间
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    onEditBlock(item);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    onDeleteBlock(item.no);
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

class BlockPage extends StatefulWidget {
  @override
  _BlockPageState createState() => _BlockPageState();
}

class _BlockPageState extends State<BlockPage> {
  //創建區塊
  BlockDto blockDto = BlockDto(blockEntities: List.empty());

  // 創建UI的數據源
  late BlockDataSource _blockDataSource;

  // 搜尋框的TextController
  TextEditingController _searchController = TextEditingController();

  //  Column排序
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _blockDataSource = BlockDataSource(
        onDeleteBlock: _confirmDelete, onEditBlock: _editBlockDialog);
    fetchBlocks(); // 初始化先抓取區塊顯示
  }

  /**
   * 搜尋篩選區塊資料
   */
  void _searchAndUpdate(String searchText) {
    if (searchText.isEmpty) {
      fetchBlocks(); // 若搜尋字串為空則抓取原本的區塊資料
    } else {
      // 過濾 blockDto.blockEntities 而不是 _allData
      var filteredData = blockDto.blockEntities.where((block) {
        // 根據需要匹配的字段進行過濾
        return block.time.toLowerCase().contains(searchText.toLowerCase()) ||
            block.data.toLowerCase().contains(searchText.toLowerCase()) ||
            block.previousHash
                .toLowerCase()
                .contains(searchText.toLowerCase()) ||
            block.hash.toLowerCase().contains(searchText.toLowerCase()) ||
            block.hashKey.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
      _blockDataSource.updateWithData(filteredData); // 更新數據源
    }
  }

  /**
   * 後端API取得最新區塊資料
   */
  Future<void> fetchBlocks() async {
    final response = //169.254.236.3 172.20.10.2
        await http.post(Uri.parse('http://'+ BlockCreate.IP_ADDRESS +':8888/getAllBlocks'),
            //要為本地電腦的IP 模擬器不支援Localhost
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(blockDto.toJson()));

    if (response.statusCode == 200) {
      //後端回傳JSON處理
      // final result = jsonDecode(response.body);
      // 用utf8解析JSON，防止中文亂碼
      final result = jsonDecode(utf8.decode(response.bodyBytes));
      BlockDto blockDtoResult = BlockDto.fromJson(result);
      setState(() {
        blockDto = blockDtoResult; // 使用從後端獲取的數據更新blockDto
        _blockDataSource.updateWithData(blockDto.blockEntities); // 更新數據源
      });
    } else {
      //若後端無回應則報錯
      _showSnackBar('Fetch Blocks', '連線Error', 'Failed to load blocks', '');
    }
  }

  // 刪除確認對話框
  void _confirmDelete(int no) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("警告"),
          content: Text("您確定要刪除 No=" + no.toString() + " 的區塊嗎"),
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
                deleteBlock(no); // 傳送至後端刪除API
              },
            ),
          ],
        );
      },
    );
  }

//刪除區塊
  Future<void> deleteBlock(int no) async {
    BlockDto deleteDto = BlockDto(
        blockEntities: List.empty(),
        blockEntity: BlockEntity(
            no: no,
            nonce: 0,
            data: '',
            time: '',
            previousHash: '',
            hash: '',
            hashKey: ''));

    final response = //169.254.236.3 172.20.10.2
        await http.post(Uri.parse('http://localhost:8888/deleteBlock'),
            //要為本地電腦的IP 模擬器不支援Localhost
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(deleteDto.toJson()));

    if (response.statusCode == 200) {
      // 用utf8解析JSON，防止中文亂碼
      final result = jsonDecode(utf8.decode(response.bodyBytes));
      BlockDto blockDtoResult = BlockDto.fromJson(result);
      _showSnackBar(
          'Delete Block',
          blockDtoResult.errorCode ?? 'No Error',
          blockDtoResult.errorMessage ?? 'No ErrorMessage',
          blockDtoResult.devMessage ?? 'No devMessage');
      fetchBlocks();
    } else {
      _showSnackBar('Delete Block', '連線Error', 'Failed to load blocks', '');
    }
  }

  //修改區塊對話框
  void _editBlockDialog(BlockEntity blockEntity) {
    // TextEditingController 管理修改字串
    TextEditingController nonceController =
        TextEditingController(text: blockEntity.nonce.toString());
    TextEditingController dataController =
        TextEditingController(text: blockEntity.data);
    TextEditingController timeController =
        TextEditingController(text: blockEntity.time);
    TextEditingController previousHashController =
        TextEditingController(text: blockEntity.previousHash);
    TextEditingController hashController =
        TextEditingController(text: blockEntity.hash);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "EDIT BLOCK",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Nonce:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                TextFormField(
                  controller: nonceController,
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
                  "Time",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                TextFormField(
                  controller: timeController,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Previous Hash",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                TextFormField(
                  controller: previousHashController,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Hash",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                TextFormField(
                  controller: hashController,
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
                editBlock(BlockEntity(
                    no: blockEntity.no,
                    nonce: int.parse(nonceController.text),
                    data: dataController.text,
                    time: timeController.text,
                    previousHash: previousHashController.text,
                    hash: hashController.text,
                    hashKey: blockEntity.hashKey));
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
  Future<void> editBlock(BlockEntity blockEntity) async {
    BlockDto editDto = BlockDto(
        blockEntities: List.empty(),
        blockEntity: BlockEntity(
            no: blockEntity.no,
            nonce: blockEntity.nonce,
            data: blockEntity.data,
            time: blockEntity.time,
            previousHash: blockEntity.previousHash,
            hash: blockEntity.hash,
            hashKey: blockEntity.hashKey));

    final response = //169.254.236.3 172.20.10.2
        await http.post(Uri.parse('http://localhost:8888/editBlock'),
            //要為本地電腦的IP 模擬器不支援Localhost
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(editDto.toJson()));

    if (response.statusCode == 200) {
      // 用utf8解析JSON，防止中文亂碼
      final result = jsonDecode(utf8.decode(response.bodyBytes));
      BlockDto blockDtoResult = BlockDto.fromJson(result);
      _showSnackBar(
          'Edited Block',
          blockDtoResult.errorCode ?? 'No Error',
          blockDtoResult.errorMessage ?? 'No ErrorMessage',
          blockDtoResult.devMessage ?? 'No devMessage');

      fetchBlocks();
    } else {
      _showSnackBar('Edited Block', '連線Error', 'Failed to edit blocks', '');
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
                  'Blockchain List',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search ( time , data, previous Hash, hash )',
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
                'No',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onSort: (int columnIndex, bool ascending) {
                _blockDataSource.sort<num>((BlockEntity d) => d.no, ascending);
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
            DataColumn(
              label: Text(
                'Nonce',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onSort: (int columnIndex, bool ascending) {
                _blockDataSource.sort<num>(
                    (BlockEntity d) => d.nonce, ascending);
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
            DataColumn(
              label: Text(
                'Timestamp',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onSort: (int columnIndex, bool ascending) {
                _blockDataSource.sort<String>(
                    (BlockEntity d) => d.time, ascending);
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
                _blockDataSource.sort<String>(
                    (BlockEntity d) => d.data, ascending);
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
            DataColumn(
              label: Text(
                'Previous Hash',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onSort: (int columnIndex, bool ascending) {
                _blockDataSource.sort<String>(
                    (BlockEntity d) => d.previousHash, ascending);
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
            DataColumn(
              label: Text(
                'Hash',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onSort: (int columnIndex, bool ascending) {
                _blockDataSource.sort<String>(
                    (BlockEntity d) => d.hash, ascending);
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
          source: _blockDataSource,
        ),
      )),
    ));
  }
}
