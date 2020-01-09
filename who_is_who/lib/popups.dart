import 'package:flutter/material.dart';

class Popups {
  static AlertDialog openDeckPopup(BuildContext context, Function onOpenDeck) {
    final controller = TextEditingController();
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Choose Existing"),
          OutlineButton(
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              borderSide: BorderSide(width: 1),
              onPressed: () {
                onOpenDeck(
                    "https://github.com/flabbet/WhoIsWho-Game/blob/master/decks/Actors.deck?raw=true");
                Navigator.of(context).pop();
              },
              child: Text("Actors")),
          OutlineButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              borderSide: BorderSide(width: 1),
              onPressed: () {
                onOpenDeck(
                    "https://github.com/flabbet/WhoIsWho-Game/blob/master/decks/PolishMonarchs.deck?raw=true");
                Navigator.of(context).pop();
              },
              child: Text("Polish Monarchs")),
          Text("Or enter URL"),
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter deck url"),
          ),
          FlatButton(
              child: Text("Open deck"),
              onPressed: () {
                onOpenDeck(controller.text);
                Navigator.of(context).pop();
              })
        ],
      ),
    );
  }
}
