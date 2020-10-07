import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../constants/colors.dart';

class TextFormInput extends StatelessWidget {
  const TextFormInput(
      {Key key,
      this.text,
      this.cController,
      this.prefixIcon,
      this.kt,
      this.postfixIcon,
      this.obscureText,
      this.suffixicon,
      this.readOnly,
      this.onTab,
      this.focusNode,
      this.nextfocusNode,
      this.onFieldSubmitted,
      this.onFieldChanged,
      this.validator,
      this.prefixWidget})
      : super(key: key);
  final String text;
  final TextEditingController cController;
  final IconData prefixIcon;
  final TextInputType kt;
  final IconData postfixIcon;
  final bool obscureText;
  final Widget suffixicon;
  final bool readOnly;
  final void Function() onTab;
  final FocusNode focusNode;
  final FocusNode nextfocusNode;
  final Function onFieldSubmitted;
  final Function(String st) onFieldChanged;

  final String Function(String error) validator;
  final Widget prefixWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: TextFormField(
        readOnly: readOnly,
        keyboardType: kt,
        onTap: () => onTab(),
        controller: cController,
        style: const TextStyle(color: Colors.black, fontSize: 12),
        obscureText: obscureText,
        decoration: InputDecoration(
            suffix: prefixWidget,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.myBlue)),
            filled: true,
            fillColor: Colors.white70,
            hintText: text,
            hintStyle: TextStyle(color: colors.ggrey, fontSize: 10),
            disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
              color: Colors.blue,
            )),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colors.myBlue,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            prefixIcon: Icon(
              prefixIcon,
              color: colors.blue,
              size: 24,
            ),
            suffixIcon: suffixicon),
        focusNode: focusNode,
        onFieldSubmitted: (String v) {
          onFieldSubmitted();
        },
        onChanged: onFieldChanged,
        validator: (String error) {
          return validator(error);
        },
      ),
    );
  }
}
