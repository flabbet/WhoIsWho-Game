import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as driveApi;
import 'package:path_provider/path_provider.dart';
import 'package:who_is_who/Constants.dart';
import 'package:who_is_who/popups.dart';
import 'package:http/http.dart' as http;

import 'JSONLoader.dart';
import 'CardItem.dart';
import 'google_http_client.dart';

void main() => runApp(WhoIsWhoApp());

class WhoIsWhoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Who is who',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameHomePage(title: 'Who is Who'),
    );
  }
}

class GameHomePage extends StatefulWidget {
  GameHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _GameHomePageState createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  static const int SecondsPerQuestion = 10;
  String middleText = "Select deck to start";
  List<CardItem> cardItems = List<CardItem>();
  int currentPersonIndex = 0;
  int _questionsCount = 0;
  int goodAnswers = 0;
  double timerValue = 0;
  var stopwatch = Stopwatch();
  double _elapsedTime = 0;
  bool tappedAgain = false;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  String deckPath;
  bool deckIsLoading = false;
  GoogleSignIn _signIn = GoogleSignIn(
      scopes: ['email', 'https://www.googleapis.com/auth/drive.readonly']);
  GoogleSignInAccount _signedInAccount;
  String organizationDeckUrl;
  String organizationLogoFileName;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Popups.openDeckPopup(context, getDeck);
        }));
    if (_questionsCount > 0) {
      Timer(Duration(milliseconds: 10), updateStopwatch);
      stopwatch.start();
    }
    super.initState();
  }

  void loadDeckJson(String path) {
    JSONLoader.loadJSON(path).then((json) {
      cardItems =
          JSONLoader.shuffle(JSONLoader.toCardItemList(jsonDecode(json)));
      _questionsCount = cardItems.length;
    });
    restartGame();
  }

  void restartGame() {
    setState(() {
      cardItems = JSONLoader.shuffle(cardItems);
      currentPersonIndex = 0;
      goodAnswers = 0;
      _elapsedTime = 0;
      if (tappedAgain && cardKey.currentState != null) {
        cardKey.currentState.toggleCard();
      }
      tappedAgain = false;
      deckIsLoading = false;
      stopwatch.start();
      stopwatch.reset();
      updateStopwatch();
    });
  }

  void updateStopwatch() {
    setState(() {
      _elapsedTime = stopwatch.elapsedMilliseconds / 10000.0;
    });

    if (_elapsedTime * 10 >= SecondsPerQuestion) {
      stopwatch.reset();
      _elapsedTime = 0;
      _switchQuestion(false);
    }
    if (stopwatch.isRunning) {
      Timer(Duration(milliseconds: 10), updateStopwatch);
    }
  }

  void _switchQuestion(bool wasGoodAnswer) {
    if (tappedAgain) {
      cardKey.currentState.toggleCard();
      tappedAgain = false;
      stopwatch.start();
      updateStopwatch();
    } else if (wasGoodAnswer) {
      goodAnswers++;
    } else {
      tappedAgain = true;
      cardKey.currentState.toggleCard();
      stopwatch.stop();
      return;
    }

    if (currentPersonIndex == _questionsCount - 1) {
      stopwatch.reset();
      stopwatch.stop();
      _elapsedTime = 0;
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Your score was"),
                  Text(
                      goodAnswers.toString() + "/" + _questionsCount.toString(),
                      style: TextStyle(fontSize: 30)),
                  FlatButton(
                      child: Text("Try again?"),
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: () {
                        restartGame();
                        Navigator.of(context).pop();
                      })
                ],
              ),
            );
          });
      return;
    }
    setState(() {
      stopwatch.reset();
      _elapsedTime = 0;
      currentPersonIndex++;
    });
  }

  Future<File> downloadDeck(String url, String path, String filename) async {
    http.Client client = new http.Client();
    var req = await client.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    File file = new File('$path/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  String decompressDeck(List<int> bytes, String path) {
    var archive = ZipDecoder().decodeBytes(bytes);
    String rootDirName = archive[0].name.split("/")[0];
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(path + '/out/' + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(path + '/out/' + filename)..create(recursive: true);
      }
    }
    return rootDirName + "/";
  }

  Future<List<int>> openDeckFile() async {
    var file = File((await getTemporaryDirectory()).path);
    return file.readAsBytes();
  }

  void getDeck(String uri) async {
    setState(() {
      deckIsLoading = true;
    });
    try {
      var path = (await getTemporaryDirectory()).path;
      File file;
      if (uri.startsWith("http")) {
        file = await downloadDeck(uri, path, "deck.deck");
      } else if (uri.startsWith("/")) {
        file = File(uri);
      }
      deckPath = "$path/out/${decompressDeck(await file.readAsBytes(), path)}";
      loadDeckJson("${deckPath}data.json");
      deckIsLoading = false;
    } catch (ex) {
      setState(() {
        deckIsLoading = false;
        String errorMessage = ex.toString().replaceAll("%20", " ");
        middleText = errorMessage;
        print(errorMessage);
      });
    }
  }

  Future<void> downloadDeckFromGoogleDrive(String fileId) async {
    var client = GoogleHttpClient(await _signedInAccount.authHeaders);
    var drive = driveApi.DriveApi(client);
    final deckFile = await drive.files
        .get(fileId, downloadOptions: driveApi.DownloadOptions.FullMedia);
    var path = (await getTemporaryDirectory()).path + "deck.deck";
    File file = File(path);
    await file.writeAsBytes(await deckFile.stream.toBytes());
    getDeck(path);
  }

  void choiceAction(String choice) async {
    if (choice == Constants.OpenDeck) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Popups.openDeckPopup(context, getDeck);
          });
    } else if (choice == Constants.SingIn) {
      _signedInAccount = await _signIn.signIn();
      final json = jsonDecode(
          await DefaultAssetBundle.of(context).loadString("assets/org.json"));
      if (_signedInAccount.email.split('@')[1].toLowerCase() ==
          json['domain']) {
        var fileId = json['file_id'];
        if (fileId != null) {
          await downloadDeckFromGoogleDrive(fileId);
        } else {
          organizationDeckUrl = json['deck_url'];
          getDeck(organizationDeckUrl);
        }
        organizationLogoFileName = "assets/logo.png";
      } else {
        setState(() {
          middleText = "Not authorized.";
        });
      }
    } else if (choice == Constants.SignOut) {
      setState(() {
        _signedInAccount = null;
        _signIn.signOut();
        organizationLogoFileName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          organizationLogoFileName != null
              ? CircleAvatar(child: ClipOval(child: Image.asset(organizationLogoFileName)))
              : Text(""),
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.buildChoices(_signedInAccount)
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: deckIsLoading
            ? CircularProgressIndicator()
            : _questionsCount == 0
                ? Text(
                    middleText,
                    style: TextStyle(fontSize: 34),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      LinearProgressIndicator(value: _elapsedTime),
                      Text(
                          (currentPersonIndex + 1).toString() +
                              "/" +
                              _questionsCount.toString(),
                          style: TextStyle(fontSize: 18)),
                      FlipCard(
                        key: cardKey,
                        direction: FlipDirection.HORIZONTAL,
                        flipOnTouch: false,
                        front: Container(
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            color: Colors.white,
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: cardItems.length > 0
                                        ? Image.file(
                                            File(deckPath +
                                                "images/" +
                                                cardItems[currentPersonIndex]
                                                    .fileName),
                                            width: 300,
                                            height: 450,
                                            fit: BoxFit.cover)
                                        : null),
                                FlatButton(
                                  child: const Text("Do you know who is that?"),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        back: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          color: Color(0xFFd55563),
                          elevation: 10,
                          child: Container(
                            width: 300,
                            height: 450,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                    tappedAgain
                                        ? cardItems[currentPersonIndex].name
                                        : "",
                                    style: TextStyle(
                                        fontSize: 34, color: Colors.white),
                                    textAlign: TextAlign.center),
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MarkdownBody(
                                      styleSheet: MarkdownStyleSheet.fromTheme(
                                          ThemeData(
                                              textTheme: Theme.of(context)
                                                  .textTheme
                                                  .apply(
                                                      bodyColor: Colors.white70,
                                                      fontSizeDelta: 8))),
                                      data: tappedAgain
                                          ? cardItems[currentPersonIndex]
                                              .description
                                          : "",
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: tappedAgain
                            ? <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    _switchQuestion(false);
                                  },
                                  child: Text("Next question",
                                      style: TextStyle(fontSize: 18)),
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                )
                              ]
                            : <Widget>[
                                FlatButton(
                                  color: Colors.red,
                                  textColor: Colors.white,
                                  child: Text("No"),
                                  onPressed: () {
                                    _switchQuestion(false);
                                  },
                                ),
                                FlatButton(
                                  color: Colors.green,
                                  textColor: Colors.white,
                                  child: Text("Yes"),
                                  onPressed: () {
                                    _switchQuestion(true);
                                  },
                                )
                              ],
                      )
                    ],
                  ),
      ),
    );
  }
}
