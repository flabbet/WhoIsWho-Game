import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:who_is_who/Constants.dart';

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
                if (finalUri != null && finalUri.trim() != "") {
                  onOpenDeck(finalUri);
                  Navigator.of(context).pop();
                }
              }),
          RichText(
              text: TextSpan(
                  style: TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic),
                  children: [
                TextSpan(
                    text: "Tip: If you want to create your own deck, follow"),
                TextSpan(
                    text: " this guide",
                    style: TextStyle(
                        color: Colors.blue, fontStyle: FontStyle.normal),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch(
                            'https://github.com/flabbet/WhoIsWho-Game/wiki/Creating-your-own-deck');
                      })
              ]))
        ],
      ),
    );
  }
}

class OrganizationPopup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OrganizationPopupState();
}

class _OrganizationPopupState extends State<OrganizationPopup> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameFieldController = TextEditingController();
  final _orgDeckFieldController = TextEditingController();
  final _orgLogoFieldController = TextEditingController();
  final _authorEmailController = TextEditingController();
  final _orgDomainController = TextEditingController();
  String responseStr;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("New Organization"),
          Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                      controller: _orgNameFieldController,
                      decoration:
                          InputDecoration(hintText: "Enter organization name"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Enter organization name";
                        }
                        return null;
                      }),
                  TextFormField(
                      controller: _orgDeckFieldController,
                      decoration: InputDecoration(
                          hintText: "Enter organization deck url"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter organization deck url";
                        } else if (!Uri.parse(value).isAbsolute) {
                          return "Please enter correct url";
                        }
                        return null;
                      }),
                  TextFormField(
                      controller: _orgLogoFieldController,
                      decoration: InputDecoration(
                          hintText: "Enter organization logo url"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter organization logo url";
                        } else if (!Uri.parse(value).isAbsolute) {
                          return "Please enter correct url";
                        }
                        return null;
                      }),
                  TextFormField(
                      controller: _authorEmailController,
                      decoration: InputDecoration(hintText: "Enter your email"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter email";
                        } else if (!RegExp(
                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                            .hasMatch(value.trim())) {
                          return "Please enter valid email";
                        }
                        return null;
                      }),
                  TextFormField(
                      controller: _orgDomainController,
                      decoration: InputDecoration(hintText: "Enter organization domain"),
                      validator: (value) {
                        if (value.isNotEmpty && value.split(".").length != 2) {
                          return "Please enter valid domain";
                        }
                        else if (value.split('.')[0].isEmpty || value.split('.')[1].isEmpty){
                          return "Please enter valid domain";
                        }
                        for(int i = 0; i < Constants.forbiddenDomains.length; i++){
                          if (Constants.forbiddenDomains[i].toLowerCase() == value.toLowerCase()){
                            return "This domain is forbidden.";
                          }
                        }

                        return null;
                      }),
                  FlatButton(
                    color: Colors.green,
                    child:
                        Text("Submit", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        Dio dio = Dio();
                        FormData data = FormData.fromMap({
                          "organization_name": _orgNameFieldController.text,
                          "organization_deck": _orgDeckFieldController.text,
                          "organization_logo": _orgLogoFieldController.text,
                          "author_email": _authorEmailController.text.trim(),
                          "domain": _orgDomainController.text
                        });
                        await dio
                            .post("http://138.68.78.158:8080/org/register",
                                data: data)
                            .then((response) {
                          setState(() {
                            if (responseStr == "Success") {
                              Navigator.of(context).pop();
                            } else {
                              responseStr = "${response.data}";
                            }
                          });
                        });
                      }
                    },
                  ),
                  responseStr == null ? Text("") : Text(responseStr)
                ],
              ))
        ],
      ),
    );
  }
}

class ManageUsersPopup extends StatefulWidget {

  final GoogleSignInAccount _account;

  ManageUsersPopup(this._account);

  @override
  State<StatefulWidget> createState() => _ManageUsersPopupState(_account);
}

class _ManageUsersPopupState extends State<ManageUsersPopup> {
  final _emailTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String responseStr = "";
  GoogleSignInAccount _account;

  _ManageUsersPopupState(GoogleSignInAccount account){
    _account = account;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Manage users in your organization"),
          Form(
            key: _formKey,
              child: Column(
            children: <Widget>[
              TextFormField(
                  controller: _emailTextEditingController,
                  decoration: InputDecoration(hintText: "Enter user email"),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please enter email";
                    } else if (!RegExp(
                            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                        .hasMatch(value)) {
                      return "Please enter valid email";
                    }
                    return null;
                  }),
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    color: Colors.red,
                    child: Text("Remove", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        Dio dio = Dio();
                        GoogleSignInAuthentication auth = await _account.authentication;
                        FormData data = FormData.fromMap({
                          "access_token":  auth.accessToken,
                          "target_email": _emailTextEditingController.text
                        });
                        await dio
                            .post("http://138.68.78.158:8080/org/removeUser",
                                data: data)
                            .then((response) {
                          setState(() {
                              responseStr = "${response.data}";
                              _emailTextEditingController.text = "";
                          });
                        });
                      }
                    },
                  ),
                   FlatButton(
                color: Colors.green,
                child: Text("Add", style: TextStyle(color: Colors.white)),
                onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        Dio dio = Dio();
                        GoogleSignInAuthentication auth = await _account.authentication;
                        FormData data = FormData.fromMap({
                          "access_token":  auth.accessToken,
                          "email": _emailTextEditingController.text,
                          "is_admin": 0
                        });
                        await dio
                            .post("http://138.68.78.158:8080/org/addUser",
                                data: data)
                            .then((response) {
                          setState(() {
                              responseStr = "${response.data}";
                              _emailTextEditingController.text = "";
                          });
                        });
                      }
                    },
              ),
                ],
              ),
              Text(responseStr)
            ],
          ))
        ],
      ),
    );
  }
}
