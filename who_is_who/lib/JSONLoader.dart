import 'dart:math';

import 'package:flutter/services.dart';

import 'Person.dart';

class JSONLoader{

  static const String JSONPath = "assets/actors.json";

static Future<String> loadJSON() async{
    return await rootBundle.loadString(JSONPath);
}

static List<Person> toPersonList(List<dynamic> list){
  List<Person> people = List<Person>();
  for (var i = 0; i < list.length; i++){
    people.add(Person(list[i]["name"], list[i]["path"], list[i]["description"]));
  }
  return people;
}

static List shuffle(List items){
     var random = new Random();

  for (var i = items.length - 1; i > 0; i--) {

    var n = random.nextInt(i + 1);

    var temp = items[i];
    items[i] = items[n];
    items[n] = temp;
  }

  return items;
}

}