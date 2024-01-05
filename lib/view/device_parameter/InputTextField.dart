import 'package:flutter/material.dart';

class InputTextField extends StatefulWidget {
  final void Function(String) onTextChanged;
  final String hintText;
  final double width;

  InputTextField({
    required this.onTextChanged,
    this.hintText = '',
    this.width = 400
  });

  @override
  _InputTextFieldState createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  late String text;

  @override
  void initState() {
    super.initState();
    text = ''; // 初始文本为空
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: TextField(
        onChanged: (value) {
          setState(() {
            text = value; // 更新本地状态
          });
          widget.onTextChanged(value); // 通知父组件
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          hintText: widget.hintText, // 提示文本
        ),
      ),
    );
  }
}
