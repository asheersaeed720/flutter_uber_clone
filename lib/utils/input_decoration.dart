import 'package:flutter/material.dart';

InputDecoration buildTextFieldInputDecoration(
  context, {
  required String hintText,
  Color fillColor = Colors.white,
  String prefixIconUrl = '',
}) {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 22),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(style: BorderStyle.none, width: 0),
    ),
    hintText: '$hintText',
    isDense: true,
    fillColor: fillColor != Colors.white ? fillColor : Theme.of(context).cardColor,
    hintStyle: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 12.0),
    filled: true,
    prefixIcon: prefixIconUrl.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: Image.asset(prefixIconUrl),
          )
        : SizedBox.shrink(),
    prefixIconConstraints: BoxConstraints(minWidth: 23, maxHeight: 20),
  );
}

InputDecoration buildPasswordInputDecoration(
  context, {
  required String hintText,
  Color fillColor = Colors.white,
  required Widget suffixIcon,
}) {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 22),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(style: BorderStyle.none, width: 0),
    ),
    hintText: '$hintText',
    isDense: true,
    fillColor: fillColor != Colors.white ? fillColor : Theme.of(context).cardColor,
    hintStyle: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 12.0),
    filled: true,
    suffixIcon: suffixIcon,
  );
}
