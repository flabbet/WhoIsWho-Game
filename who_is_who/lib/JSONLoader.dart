import 'dart:io';
import 'dart:math';

import 'CardItem.dart';

class JSONLoader{

static Future<String> loadJSON(String path) async{
  var file = File(path);
    return await file.readAsString();
}

static List<CardItem> toCardItemList(List<dynamic> list){
  List<CardItem> items = List<CardItem>();
  for (var i = 0; i < list.length; i++){
    items.add(CardItem(list[i]["name"], list[i]["path"], list[i]["description"]));
  }
  return items;
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