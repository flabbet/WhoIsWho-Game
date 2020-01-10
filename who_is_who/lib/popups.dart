import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Popups {
  static AlertDialog openDeckPopup(BuildContext context, Function onOpenDeck) {
    final controller = TextEditingController();
    String finalUri;
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Choose Existing"),
          OutlineButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              borderSide: BorderSide(width: 1),
              onPressed: () {
                onOpenDeck(
                    "https://github.com/flabbet/WhoIsWho-Game/blob/master/decks/Actors.deck?raw=true");
                Navigator.of(context).pop();
              },
              child: Text("Actors")),
          OutlineButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              borderSide: BorderSide(width: 1),
              onPressed: () {
                onOpenDeck(
                    "https://github.com/flabbet/WhoIsWho-Game/blob/master/decks/PolishMonarchs.deck?raw=true");
                Navigator.of(context).pop();
              },
              child: Text("Polish Monarchs")),
          Text("Or get from external source"),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: "Enter deck url"),
                  onChanged: (String text) {
                    finalUri = text;
                  },
                ),
              ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text("or", style: TextStyle(fontSize: 14)),
                ),
              Expanded(
                child: RaisedButton(
                  child: Text("Select file"),
                  onPressed: () async {
                    String filePath = await FilePicker.getFilePath(
                        type: FileType.ANY, fileExtension: "deck");
                    finalUri = filePath;
                  },
                ),
              )
            ],
          ),
          FlatButton(
              color: Colors.green,
              textColor: Colors.white,
              child: Text("Open deck"),
              onPressed: () {
                if(finalUri != null && finalUri.trim() != "") {
                  onOpenDeck(finalUri);
                  Navigator.of(context).pop();
                }
              }),
          RichText(text: TextSpan(
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            children: [
              TextSpan(text: "Tip: If you want to create your own deck, follow"),
              TextSpan(
                text: " this guide",
                style: TextStyle(color: Colors.blue, fontStyle: FontStyle.normal),
                recognizer: TapGestureRecognizer()..onTap = () { launch('https://github.com/flabbet/WhoIsWho-Game/wiki/Creating-your-own-deck'); }
              )
            ]
          ))
        ],
      ),
    );
  }
}
