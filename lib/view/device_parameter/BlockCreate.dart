import 'dart:convert';
import 'package:blockchain_frontend_flutter/model/DataDto.dart';
import 'package:blockchain_frontend_flutter/view/device_parameter/InputTextField.dart';
import 'package:universal_platform/universal_platform.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../model/BlockDto.dart';
import '../../model/BlockEntity.dart';
import '../../model/DataEntity.dart';

class BlockCreate extends StatefulWidget {
  static String IP_ADDRESS = "localhost"; //192.168.0.198
  // static String IP_ADDRESS = "192.168.0.198";

  @override
  _BlockCreate createState() => _BlockCreate();
}

class _BlockCreate extends State<BlockCreate> {

  //手動輸入的Block內容
  int no = 0;
  int nonce = 0;
  String timestamp = "";
  String data = "";
  String previousHash = "";
  String hash = "";

  @override
  void initState() {
    super.initState();
  }

  /**
   * 自動抓取原始資料Table來做區塊鏈
   */
  Future<void> createDataBlock() async {
    DataDto dataDto = DataDto(dataEntities: List.empty());
    final response = //169.254.236.3 172.20.10.2
        await http.post(
            Uri.parse(
                'http://' + BlockCreate.IP_ADDRESS + ':8888/createDataBlock'),
            //要為本地電腦的IP 模擬器不支援Localhost
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(dataDto.toJson()));

    if (response.statusCode == 200) {
      // 用utf8解析JSON，防止中文亂碼
      final result = jsonDecode(utf8.decode(response.bodyBytes));
      DataDto dataDto = DataDto.fromJson(result);

      _showSnackBar(
          'Automatic Create Blocks',
          dataDto.errorCode ?? 'No Error',
          dataDto.errorMessage ?? 'No ErrorMessage',
          dataDto.devMessage ?? 'No devMessage');
    } else {
      _showSnackBar('Automatic Create Blocks', 'Connection Error',
          'Failed to create blocks', '');
    }
  }

  /**
   * 抓取資料來做區塊鏈
   */
  Future<void> manualCreateBlock() async {
    //將手動填資料傳送
    BlockDto manualBlock = BlockDto(
        blockEntities: List.empty(),
        blockEntity: BlockEntity(
          no: no,
          nonce: nonce,
          time: timestamp,
          data: data,
          previousHash: previousHash,
          hash: hash,
          hashKey: '',
        ));

    final response = //169.254.236.3 172.20.10.2
        await http.post(
            Uri.parse(
                'http://' + BlockCreate.IP_ADDRESS + ':8888/createBlock'),
            //要為本地電腦的IP 模擬器不支援Localhost
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(manualBlock.toJson()));

    if (response.statusCode == 200) {
      // 用utf8解析JSON，防止中文亂碼
      final result = jsonDecode(utf8.decode(response.bodyBytes));
      BlockDto blockDto = BlockDto.fromJson(result);

      _showSnackBar(
          'Manual Create Block',
          blockDto.errorCode ?? 'No Error',
          blockDto.errorMessage ?? 'No ErrorMessage',
          blockDto.devMessage ?? 'No devMessage');

    } else {
      // 如果服务器没有返回一个OK响应，则抛出一个异常。
      _showSnackBar('Manual Create Block', 'Connection Error',
          'Failed to create block', '');
    }
  }

  /**
   * 驗證區塊
   */
  Future<void> verifyBlocks() async {
    BlockDto blockDto = BlockDto(blockEntities: List.empty());
    final response = //169.254.236.3 172.20.10.2
        await http.post(
            Uri.parse(
                'http://' + BlockCreate.IP_ADDRESS + ':8888/verifyBlocks'),
            //要為本地電腦的IP 模擬器不支援Localhost
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(blockDto.toJson()));

    if (response.statusCode == 200) {
      // 用utf8解析JSON，防止中文亂碼
      final result = jsonDecode(utf8.decode(response.bodyBytes));
      BlockDto blockDtoResult = BlockDto.fromJson(result);

      _showSnackBar(
          'Verify Blocks',
          blockDtoResult.errorCode ?? 'No Error',
          blockDtoResult.errorMessage ?? 'No ErrorMessage',
          blockDtoResult.devMessage ?? 'No devMessage');
    } else {
      _showSnackBar(
          'Verify Blocks', 'Connection Error', 'Failed to verify blocks', '');
    }
  }

  /**
   * 刪除全部區塊_確認對話框
   */
  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("警告"),
          content: Text("您確定要刪除全部區塊嗎？"),
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
                deleteBlocks(); // 傳送至後端刪除API
              },
            ),
          ],
        );
      },
    );
  }

  /**
   * 刪除全部區塊
   */
  Future<void> deleteBlocks() async {
    BlockDto deleteAll = BlockDto(
        blockEntities: List.empty(),
        blockEntity: BlockEntity(
          no: 0,
          nonce: 0,
          time: '',
          data: '',
          previousHash: '',
          hash: '',
          hashKey: '',
        ));

    final response = //169.254.236.3 172.20.10.2
        await http.post(
            Uri.parse(
                'http://' + BlockCreate.IP_ADDRESS + ':8888/deleteBlocks'),
            //要為本地電腦的IP 模擬器不支援Localhost
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(deleteAll.toJson()));

    if (response.statusCode == 200) {
      // 用utf8解析JSON，防止中文亂碼
      final result = jsonDecode(utf8.decode(response.bodyBytes));
      BlockDto blockDtoResult = BlockDto.fromJson(result);

      _showSnackBar(
          'Delete all blocks',
          blockDtoResult.errorCode ?? 'No Error',
          blockDtoResult.errorMessage ?? 'No ErrorMessage',
          blockDtoResult.devMessage ?? 'No devMessage');

    } else {
      _showSnackBar('Delete all blocks', 'Connection Error',
          'Failed to delete all blocks', '');
    }
  }

  /**
   * 通知訊息框 SnackBar
   */
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
    // 獲取螢幕寬度
    double screenWidth = MediaQuery.of(context).size.width;

    // 檢查是否為手機平台
    bool isMobile = UniversalPlatform.isIOS || UniversalPlatform.isAndroid;
    // 根據平台調整元件大小
    double fontSize = isMobile ? 12.5 : 20; // 手機版字體大小為原來的一半
    double fontSizeBtn = isMobile ? 12.5 : 15; // 手機版字體大小為原來的一半
    double buttonWidth = isMobile ? 100 : 200; // 手機版按鈕寬度為原來的一半
    double inputWidth = isMobile ? 75 : 700; // 手機版輸入框寬度為原來的一半

    // TODO: implement build
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
      width: screenWidth, // 設置Container的寬度為螢幕寬度
      child: Column(
        children: [
          SizedBox(height: 50),
          // 手動產出區塊
          SizedBox(width: 50),
          Text("Block",
              style:
                  TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),

          SizedBox(height: 30),

          InputTextField(
            onTextChanged: (value) {
              no = value as int;
            },
            hintText: 'No',
            width: inputWidth,
          ),

          SizedBox(height: 20),

          InputTextField(
            onTextChanged: (value) {
              nonce = value as int;
            },
            hintText: 'Nonce',
            width: inputWidth,
          ),
          SizedBox(height: 20),

          InputTextField(
            onTextChanged: (value) {
              timestamp = value;
            },
            hintText: 'Timestamp',
            width: inputWidth,
          ),
          SizedBox(height: 20),

          InputTextField(
            onTextChanged: (value) {
              data = value;
            },
            hintText: 'Data',
            width: inputWidth,
          ),

          SizedBox(height: 20),

          InputTextField(
            onTextChanged: (value) {
              previousHash = value;
            },
            hintText: 'PreviousHash',
            width: inputWidth,
          ),

          SizedBox(height: 20),

          InputTextField(
            onTextChanged: (value) {
              hash = value;
            },
            hintText: 'Hash',
            width: inputWidth,
          ),

          SizedBox(
            height: 30,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /* 手動輸入資料建立區塊 */
              ElevatedButton(
                style: ElevatedButton.styleFrom(fixedSize: Size(buttonWidth, 50)),
                onPressed: () {
                  manualCreateBlock();
                },
                child: Text('MANUALLY CREATE',
                    style: TextStyle(
                        fontSize: fontSizeBtn, fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 20),
              // /* 自動抓取資料庫形成區塊 */
              // ElevatedButton(
              //     style: ElevatedButton.styleFrom(fixedSize: Size(200, 50)),
              //     onPressed: () {
              //       createDataBlock();
              //     },
              //     child: Text(
              //       //
              //       'AUTOMATICALLY CREATE', //讀取原始資料自動加密成區塊
              //       style: TextStyle(
              //           fontSize: fontSizeBtn, fontWeight: FontWeight.bold),
              //     )),
              // SizedBox(width: 20),
              /* 區塊驗證 */
              ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize: Size(200, 50)),
                  onPressed: () {
                    verifyBlocks();
                  },
                  child: Text(
                    'BLOCK VERIFICATION',
                    style: TextStyle(
                        fontSize: fontSizeBtn, fontWeight: FontWeight.bold),
                  )),
              SizedBox(width: 20),
              /* 刪除所有區塊 */
              ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize: Size(200, 50)),
                  onPressed: () {
                    _confirmDeleteAll();
                  },
                  child: Text(
                    'DELETE ALL BLOCKS',
                    style: TextStyle(
                        fontSize: fontSizeBtn, fontWeight: FontWeight.bold),
                  )),
            ],
          )







        ],
      ),
    )));
  }
}
