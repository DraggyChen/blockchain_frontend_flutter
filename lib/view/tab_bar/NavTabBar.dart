
import 'package:blockchain_frontend_flutter/view/blockchain/BlockPage.dart';
import 'package:blockchain_frontend_flutter/view/device_parameter/DeviceSettingsPage.dart';
import 'package:blockchain_frontend_flutter/view/home/HomePage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io'; // 用於檢測操作系統

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class NavTabBar extends StatefulWidget {
  @override
  _NavTabBar createState() => _NavTabBar();
}

class _NavTabBar extends State<NavTabBar> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Align(alignment: Alignment.center ,child: Text('Takming uni Blockchain System')),
          bottom: TabBar(
            isScrollable: kIsWeb? false : Platform.isMacOS? false: true, //若是網頁就平均分散，因為手機版可能太小所以要允許平均分配
            tabs: [
              Tab(child: Text('Functions')), //裝置數值設定介面
              Tab(child: Text('BlockChain Table')), //區塊鏈後台資訊
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(), // 禁止左右滑動切換
          children: [
            DeviceSettingsPage(),
            BlockPage(),
          ],
        ),
      ),
    );
  }
}
