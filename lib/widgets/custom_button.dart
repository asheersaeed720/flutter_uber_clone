import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String btnTxt;
  final onPressed;
  final btnColor;
  final dynamic width;
  final double height;
  final bool isRounded;
  final dynamic iconImg;

  CustomButton({
    required this.btnTxt,
    required this.onPressed,
    this.btnColor,
    this.width,
    this.height = 50.0,
    this.isRounded = false,
    this.iconImg = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        label: iconImg.isEmpty ? Text('') : Image.asset('$iconImg', width: 22.0),
        icon: Padding(
          padding: EdgeInsets.only(left: 6.0),
          child: Text(
            '$btnTxt',
            style: btnColor == Colors.white
                ? TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  )
                : TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(btnColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: isRounded ? BorderRadius.circular(50.0) : BorderRadius.circular(8.0),
            ),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
