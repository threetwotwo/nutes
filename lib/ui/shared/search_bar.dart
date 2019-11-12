import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final void Function(String) onTextChange;
  final void Function() onCancel;

  final TextEditingController controller;
  final FocusNode focusNode;

  SearchBar(
      {this.onTextChange, this.onCancel, this.controller, this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 45,
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        child: TextField(
            autofocus: false,
            focusNode: focusNode,
            controller: controller,
            onChanged: onTextChange,
            decoration: InputDecoration(
                fillColor: Colors.black.withOpacity(0.1),
                filled: true,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 18,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.grey,
                    size: 16,
                  ),
                  onPressed: onCancel,
                ),
                hintText: 'Search',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                contentPadding: EdgeInsets.zero)));
  }
}
