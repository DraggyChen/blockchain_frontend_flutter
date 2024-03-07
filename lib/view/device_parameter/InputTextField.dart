import 'package:flutter/material.dart';

class InputTextField extends StatefulWidget {
  final void Function(String) onTextChanged;
  final String hintText;
  final double width;

  InputTextField({
    required this.onTextChanged,
    this.hintText = '',
    this.width = 400,
  });

  @override
  _InputTextFieldState createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(); // 初始化控制器
  }

  @override
  void dispose() {
    _controller.dispose(); // 銷毀控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          setState(() {
            // 通過調用setState更新UI
          });
          widget.onTextChanged(value); // 通知父组件
        },
        style: TextStyle(
          fontWeight: _controller.text.isNotEmpty ? FontWeight.bold : FontWeight.normal,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          hintText: widget.hintText,
          hintStyle: TextStyle(fontWeight: FontWeight.normal), // 提示文字的樣式保持原樣
        ),
      ),
    );
  }
}
