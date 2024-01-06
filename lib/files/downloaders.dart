import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'variables.dart';

Map<String, String> convertMapDynamicToMapString(Map<String, dynamic> myMap) {
  final Map<String, String> parsedData = Map.fromEntries(
      myMap.entries.map((e) => MapEntry(e.key, e.value.cast<String>())));
  return parsedData;
}

Map<String, List<String>> convertMapDynamicToMapListOfString(Map<String, dynamic> myMap) {
  Map<String, List<String>> convertedMap =
  myMap.map((key, value) => MapEntry(key, value.cast<String>().toList()));
  return convertedMap;
}


Future<Map<String, dynamic>> downloadJsonFileToMapDynamic(
    String fileName) async {
  try {
    final ref = storageRef.child(fileName);
    final data = await ref.getData();
    final jsonString = utf8.decode(data!); // Handle potential null data
    final parsedJson = jsonDecode(jsonString) as Map<String, dynamic>;
    log("JSON file $fileName successfully downloaded");

    return parsedJson;
  } on FirebaseException catch (e) {
    // Handle errors gracefully
    log('Error downloading JSON: $e');
    rethrow; // Rethrow to allow further handling
  }
}

Future<String> downloadAndReadTextFile(String fileName) async {
  try {
    // Download text file from Firebase Storage
    final storageReference = storageRef.child(fileName);

    // Get the download URL for the file
    final String downloadURL = await storageReference.getDownloadURL();

    // Use HTTP GET to download the file content
    final response = await http.get(Uri.parse(downloadURL));

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Read the content of the text file
      String fileContent = response.body;
      log("Contents of $fileName has been successfully accessed");
      log(fileContent);
      return fileContent;
    } else {
      throw Exception('Failed to download text file: ${response.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
    throw Exception('Failed to download and read text file');
  }
}

