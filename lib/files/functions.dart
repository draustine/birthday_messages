import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'variables.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';



Future<bool> checkInternetConnection() async {
  bool result = await InternetConnectionChecker().hasConnection;
  if (result == true) {
    log('Internet connection is available');
  } else {
    log('No internet connection');
  }
  return result;
}


Future<Map<Permission, PermissionStatus>> requestPermissions() async {
  return await [
    Permission.phone,
    Permission.sms,
  ].request();
}

void saveLinks() async {
  await saveLink(vListUrl, listUrl);
  await saveLink(vMessageUrl, messageUrl);
  await saveLink(vBelatedUrl, belatedMessageUrl);
  await saveLink(vProvidersUrl, providersUrl);
}

Future<void> saveLink(String key, String value) async {
  await prefs.setString(key, value);
}

void getLinks() async {
  listUrl = await getLink(vListUrl, listUrl);
  messageUrl = await getLink(vMessageUrl, messageUrl);
  belatedMessageUrl = await getLink(vBelatedUrl, belatedMessageUrl);
  providersUrl = await getLink(vProvidersUrl, providersUrl);
  sentDates = await getList(sentDatesFileName);
}

Future<String> getLink(String key, currentValue) async {
  String value = prefs.getString(key) ?? currentValue;
  return value;
}

Future<dynamic> callNativeFunction(String functionName,
    [dynamic parameter]) async {
  dynamic result;
  try {
    result = await platform.invokeMethod(functionName, parameter);
  } on PlatformException catch (e) {
    result = "Failed to call $functionName: ${e.message}";
  }
  return result;
}



Future<void> checkTextData(String fileUrl, String dataName, String fileName) async {
  String? textFromFile = prefs.getString(fileName);

  if (textFromFile == null) {
    await downloadTextFile(fileUrl, dataName, fileName);
  } else {
    switch (dataName){
      case "messageTemplate":
        messageTemplate = textFromFile;
        break;
      case "belatedMessageTemplate":
        belatedMessageTemplate = textFromFile;
        break;
      case "providers":
        providers = textFromFile;
        break;
    }
  }
}


Future<void> downloadTextFile(String fileUrl, String dataName, String fileName) async {
  // Replace 'URL_TO_YOUR_TEXT_FILE' with the actual URL of the text file
  var url = Uri.parse(fileUrl);

  try {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // Fetching text from the file
      String downloadedText = response.body;
      prefs.setString(fileName, downloadedText);
      // Save the downloaded text to shared preferences
      switch (dataName){
        case "messageTemplate":
          messageTemplate = downloadedText;
          break;
        case "belatedMessageTemplate":
          belatedMessageTemplate = downloadedText;
          break;
        case "providers":
          providers = downloadedText;
          break;
      }

    } else {
      // Handle any error when fetching the file
    }
  } catch (e) {
    // Handle any network or unexpected errors
  }
}


bool convertToBool(String stringRepresentation) {
  bool booleanValue = false;
  if (stringRepresentation.toLowerCase() == 'true') {
    booleanValue = true;
  }
  return booleanValue;
}



void storeStringInMemory(String variableName, String url) async {
  await prefs.setString(variableName, url);
}


Future<String?> getStringFromMemory(String fileName) async {
  String? textFromFile = prefs.getString(fileName);
  return textFromFile;
}

Future<void> getUnitCosts() async {
  String value;
  value = prefs.getString(vLocalUnitCost) ?? localSmsUnitCost.toString();
  localSmsUnitCost = double.parse(value);
  value = prefs.getString(vIntUnitCost) ?? internationalSmsUnitCost.toString();
  internationalSmsUnitCost = double.parse(value);
}


void saveCost(double cost, String key) async {
  await prefs.setDouble(key, cost);
}


void organiseMessages(){
  totalLocalCost = 0;
  totalIntCost = 0;
  String? phone = '';
  String? title = '';
  String? name = '';
  String? dateOfBirth = '';
  String? anniversary = '';
  int age = 0;
  String ordAge = '';
  String fullName = '';
  String message = '';
  localMessageList = [];
  internationalMessageList = [];
  String messageFormat = '';
  String? belated;
  String? customerId;
  String date;
  double addedCost;
  localSmsCount = 0;
  interSmsCount = 0;
  int size;
  DateTime usedDate;
  DateTime realDate;
  if (appliedDate == ''){
    date = todayDate;
  }else{
    date = appliedDate;
  }
  usedDate = DateTime.parse(date);
  appliedDate = DateFormat('yyyy-MM-dd').format(usedDate);
  realDate = DateTime.parse(todayDate);
//log('Used date is: ${usedDate.toString()}\nCurrent date is: ${realDate.toString()}');
  if(usedDate.isAtSameMomentAs(realDate)) {
    messageFormat = messageTemplate;
  } else if(usedDate.isAfter(realDate)){
    messageFormat = messageTemplate;
  }else{
    messageFormat = belatedMessageTemplate;
    DateTime startDate = DateTime.parse(date);
    DateTime endDate = DateTime.parse(todayDate);
    Duration difference = endDate.difference(startDate);
    int interval = difference.inDays;
    if(interval == 1){
      belated = 'yesterday';
    } else if(interval > 1){
      belated = '$interval  days ago'.trim();
    }
  }
  List<String> thisMessage = [];
  int counter = 0;
  int interCounter = 0;
  int localCounter = 0;
  for (final key in birthDaysJson.keys){
    Map<String, dynamic> item = birthDaysJson[key];
    anniversary = item["Anniversary"];
    if (anniversary == date){
      thisMessage = [];
      addedCost = 0;
      counter ++;
      customerId = key;
      title = item["Title"];
      name = item["Name"];
      dateOfBirth = item["Date of Birth"];
      phone = item["Phone Number"];
      age = calculateAge(DateTime.parse(dateOfBirth!), DateTime.parse(date));
      if (age >= 18 && title == 'MASTER') {
        title = 'MR';
      }
      fullName = toTitleCase('$title  $name'.trim());
      ordAge = toOrdinal(age);
      message = _composeMessage(messageFormat, fullName, ordAge, belated: belated);
      size = message.length;
      thisMessage = [phone!, message, fullName, customerId];
      double cost;
      int additionalSms;
      if(phone.substring(0, 4) == '+234'){
        localCounter ++;
        cost = localSmsUnitCost;
        addedCost = calculateAddedCost(size, cost);
        totalLocalCost += cost + addedCost;
        additionalSms = addedCost > 0 ? addedCost ~/ cost : 0;
        localSmsCount += 1 + additionalSms;
        thisMessage.add(cost.toString());
        localMessageList.add(thisMessage);
      } else {
        interCounter ++;
        cost = internationalSmsUnitCost;
        addedCost = calculateAddedCost(size, cost);
        totalIntCost += cost + addedCost;
        additionalSms = addedCost > 0 ? addedCost ~/ cost : 0;
        interSmsCount += 1 + additionalSms;
        thisMessage.add(cost.toString());
        internationalMessageList.add(thisMessage);
      }
    }
  }
  celebrantsCount = counter;
  interCelebsCount = interCounter;
  localsCelebsCount = localCounter;
}


double calculateAddedCost(int size, double cost) {
  double addedCost = 0;

  if (size > firstPart) {
    int factor = ((size - firstPart) / otherParts).ceil();
    addedCost = factor * cost;
  }

  return addedCost;
}


List<List<String>> addNetworkCodes(List<List<String>> theMessageList){
  if(theMessageList.isNotEmpty){
    List<List<String>> newMessageList = [];
    newMessageList.addAll(theMessageList);
    String theKey;
    String networkName;
    if(selectedSim == 1){
      networkName = network1;
    } else {
      networkName = network2;
    }
    theKey = splitString(networkName)[0].toUpperCase();
    for(final String key in providersDetails.keys){
      if(theKey == key){
        onCode = providersDetails[key]![1];
        offCode = providersDetails[key]![2];
        shortCode = providersDetails[key]![0];
        String iD = providersDetails[key]![3];
        newMessageList.insert(1, [shortCode, offCode, networkName, iD, '0']);
        newMessageList.add([shortCode, onCode, networkName, iD, '0']);
        break;
      }
    }
    return newMessageList;

  } else {
    return theMessageList;
  }
}


String toOrdinal(int number) {
  if (number % 100 > 10 && number % 100 < 14) {
    return '$number th'.replaceAll(" ", '');
  } else {
    switch (number % 10) {
      case 1:
        return '$number st'.replaceAll(" ", '');
      case 2:
        return '$number nd'.replaceAll(" ", '');
      case 3:
        return '$number rd'.replaceAll(" ", '');
      default:
        return '$number th'.replaceAll(" ", '');
    }
  }
}

String toTitleCase(String text, [String delimiter = ' ']) {
  List<String> words = text.toLowerCase().split(delimiter);
  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      if(words[i].contains('-')){
        words[i] = toTitleCase(words[i], '-');
      }
    }
  }
  return words.join(delimiter);
}



String _composeMessage(String template, String name, String age, {String? belated}){
  String message = '';
    message = template.replaceAll('*name*', name);
    message = message.replaceAll('*ord*', age);
    if(belated != null){
      message = message.replaceAll('*day*', belated);
    }
  return message;
}



int calculateAge(DateTime startDate, DateTime endDate) {
  int years = endDate.year - startDate.year;

  if (endDate.month < startDate.month ||
      (endDate.month == startDate.month && endDate.day < startDate.day)) {
    years--;
  }
  return years;
}

Future<void> downloadAndSaveFile({required String url, required String fileName, required String content}) async {
  try {
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String fileContent = response.body;
      content = fileContent;
      await prefs.setString(fileName, fileContent);
    } else {
      //TODO: Develop or remove
    }
  } catch (e) {
    //TODO: Show alert to the user
  }
}


Future<void> saveMap(Map<String, dynamic> myMap, String mapName) async {
  prefs.setString(mapName, mapToString(myMap)); // Save the map as a string
}

String mapToString(Map<String, dynamic> map) {
  return map.entries.map((entry) {
    return '${entry.key}=${entry.value}';
  }).join(',');
}


Future<void> retrieveMap(Map<String, dynamic> retrievedMap, String mapFile) async {
  String? serializedMap = prefs.getString(mapFile);

  if (serializedMap != null) {
    retrievedMap = stringToMap(serializedMap);
  }
}

Map<String, dynamic> stringToMap(String data) {
  List<String> keyValuePairs = data.split(',');
  Map<String, dynamic> resultMap = {};
  for (var pair in keyValuePairs) {
    List<String> keyValue = pair.split('=');
    resultMap[keyValue[0]] = keyValue[1];
  }
  return resultMap;
}


void printMap(Map<String, String> myMap){
  for (final key in myMap.keys){
    log('$key is : ${myMap[key]}');
  }
}




Map<String, String> convertMapToString(Map<Object?, Object?> originalMap) {
  Map<String, String> stringMap = {};

  originalMap.forEach((key, value) {
    if (key is String && value is String) {
      stringMap[key] = value;
    } else {
      stringMap[key.toString()] = value.toString();
    }
  });

  return stringMap;
}

Map<String, String> convertMapToString2(Map<String, Object> originalMap) {
  return originalMap.map((key, value) {
    if (value is String) {
      return MapEntry(key, value);
    } else {
      return MapEntry(key, value.toString());
    }
  });
}


List<String> splitString(String input) {
  int indexOfDash = input.indexOf("-");
  int indexOfSpace = input.indexOf(" ");
  int splitIndex = (indexOfDash != -1 && (indexOfSpace == -1 || indexOfDash < indexOfSpace))
      ? indexOfDash
      : (indexOfSpace != -1 ? indexOfSpace : input.length);
  String firstPart = input.substring(0, splitIndex).trim();
  String secondPart = input.substring(splitIndex + 1);
  return [firstPart, secondPart];
}


Future<Map<String, dynamic>> loadJsonFromSharedPreferences(String key) async {
  String jsonString = prefs.getString(key) ?? '{}'; // Default value is an empty JSON object
  await writeToFile(jsonString, retrievedJsonFile);
  Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  String retrievedFromJson = jsonEncode(jsonMap);
  writeToFile(retrievedFromJson, 'Recoded_From_Retrieved.txt');
  return jsonMap;
}


Future<void> saveList(List<String> theList, String fileName) async {
  await prefs.setStringList(fileName, theList);
}

Future<List<String>> getList(String fileName) async {
  List<String> theList;
  theList = prefs.getStringList(fileName) ?? [];
  return theList;
}


Future<void> writeToFile(String text, String filename) async {
  try {
    final directory = await getExternalStorageDirectory();
    final folder = await Directory('${directory?.path}/my_folder').create(recursive: true);

    final file = File('${folder.path}/$filename');

    // Write the text to the file
    await file.writeAsString(text);

    log('File written: ${file.path}');
    } catch (e) {
    log('Error writing to file: $e');
  }
}

void printList(List<String> list){
  for(final String item in list){
    log(item);
  }

}
