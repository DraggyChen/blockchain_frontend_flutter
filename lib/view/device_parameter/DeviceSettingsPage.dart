import 'package:blockchain_frontend_flutter/view/device_parameter/BlockCreate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class DeviceSettingsPage extends StatefulWidget {
  @override
  _DeviceSettingsPage createState() => _DeviceSettingsPage();
}

class _DeviceSettingsPage extends State<DeviceSettingsPage> {
  @override
  Widget build(BuildContext context) {
    // 判斷平台
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // 桌面或網頁平台，使用左右分頁佈局
      return _buildHorizontalLayout();
    } else {
      // 移動平台，使用上下分頁佈局
      return _buildVerticalLayout();
    }
  }

  Widget _buildHorizontalLayout() {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: BlockCreate(),
          ),

        ],
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: BlockCreate(),
          ),
        ],
      ),
    );
  }
}
