import 'package:flutter/material.dart';

class Popups{

  static AlertDialog openDeckPopup(BuildContext context, Function onOpenDeck) {
    final controller = TextEditingController();
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: controller,
            decoration: InputDecoration(
                hintText: "Enter deck url"
            ),
          ),
          FlatButton(child: Text("Open deck"), onPressed: ()
          {
            onOpenDeck(controller.text);
            Navigator.of(context).pop();
            })
        ],
      ),
    );
  }

}