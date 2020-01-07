import 'dart:async';
import 'dart:convert';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'JSONLoader.dart';
import 'Person.dart';

void main() => runApp(WhoIsWhoApp());

class WhoIsWhoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  List<Person> people = List<Person>();
  int currentPersonIndex = 0;
  int _questionsCount = 0;
  int goodAnswers = 0;
  double timerValue = 0;
  var stopwatch = Stopwatch();
  double _elapsedTime = 0;
  bool tappedAgain = false;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    setState(() {
      JSONLoader.loadJSON().then((json) {
        people = JSONLoader.shuffle(JSONLoader.toPersonList(jsonDecode(json)));
        _questionsCount = people.length;
      });
    });

    Timer(Duration(milliseconds: 10), updateStopwatch);
    stopwatch.start();
    super.initState();
  }

  void restartGame() {
    setState(() {
      people = JSONLoader.shuffle(people);
      currentPersonIndex = 0;
      goodAnswers = 0;
      _elapsedTime = 0;
      stopwatch.start();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
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
                          child: people.length > 0
                              ? Image.asset(
                                  "assets/images/" +
                                      people[currentPersonIndex].fileName,
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
                      Text(tappedAgain ? people[currentPersonIndex].name : "",
                          style: TextStyle(fontSize: 34, color: Colors.white)),
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
                        child: Text("Next question", style: TextStyle(fontSize: 18)),
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
