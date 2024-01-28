import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

const platform = MethodChannel('my_channel');
const String retrievedJsonFile = 'Retrieved_JSON_String.txt';
const String downloadedJsonFile = 'Downloaded_JSON_String.txt';

late bool isThereInternetAccess;
DateTime currentDate = DateTime.now().toLocal();
String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal());
String selectedDate = '';
String appliedDate = '';
String displayedDate = '';
String displayDateString = '';
late DateTime dateForDisplay;
String dateOfLastMessages = '';
String sentDatesFileName = "DatesOfMessagesSent";
List<String> sentDates = [];

List<String> bookmarks = [];

late int simCount;
late int defaultSim;
late int activeSimCount;
String network1 = 'Sim 1';
String network2 = 'Sim 2';
int sim1 = 1;
int sim2 = 2;
bool sim1State = true;
bool sim2State = true;
String phone1 = '';
String phone2 = '';
late SharedPreferences prefs;
String? textFromFile;
late int selectedSim;
String vDefaultSim = 'defaultSim';
late int phoneDefaultSim;

String listUrl = 'https://www.dropbox.com/scl/fi/wh4xye4sqg0w2v4pz06lb/Upcoming-Birthdays.json?rlkey=b8g2uix8d451na1za46kg16mf&dl=1';
String messageUrl = 'https://www.dropbox.com/scl/fi/xeo8aprr2my081qayujvq/Message-Template-flutter.txt?rlkey=r1wfkl8oobkorbxpv9zek5qxk&dl=1';
String belatedMessageUrl = 'https://www.dropbox.com/scl/fi/xtp9aokmpkn46y1m55yif/Belated-Message-Template-flutter.txt?rlkey=j4juwmxccpdsvbtqmgx9hmthc&dl=1';
String providersUrl = 'https://www.dropbox.com/s/yzxzzicw1eox5op/Network%20Providers.txt?dl=1';

String providersFileName = "Network Providers.txt";
String messageTemplateFilename = "Message Template.txt";
String belatedMessageTemplateFileName = "Belated Message Template.txt";
String clientsListFileName = "Upcoming Birthdays.json";
const String myBucket = "gs://messaging-68f27.appspot.com";
final storageRef = FirebaseStorage.instanceFor(bucket: myBucket).ref();



String vListUrl = 'listUrl';
String vMessageUrl = 'messageUrl';
String vBelatedUrl = 'belatedMessageUrl';
String vProvidersUrl = 'providersUrl';
String vSmsCosts = 'SmsCosts';
String keyCelebrantsList = 'keyCelebrantsList';

Map<String, dynamic> birthDaysJson = {};
String messageTemplate = '';
String belatedMessageTemplate = '';
String providers = '';
String messageFile = 'messageTemplate';
String belatedMessageFile = 'belatedMessageTemplate';
String providersFile = 'providersTemplate';
List<List<String>> localMessageList = [];
List<List<String>> internationalMessageList = [];
List<List<String>> simProperties = [];
Map<String, List> providersDetails = {};
String naira = '\u20A6';
RegExp pattern = RegExp(r'\s+|-');
late String fullName;
late String customerId;
late String phoneNumber;
late int celebrantsCount;
late int localsCelebsCount;
late int interCelebsCount;
late int localSmsCount;
late int interSmsCount;

double localSmsUnitCost = 4;
double internationalSmsUnitCost = 20;

String vLocalUnitCost = 'vLocalUnitCost';
String vIntUnitCost = 'vIntUnitCost';


late double totalLocalCost;
late double totalIntCost;
int firstPart = 160;
int otherParts = 140;
String onCode = '';
String offCode = '';
String shortCode = '';




String channelResult = '';

double leastFontSize = 18;
TextStyle bodyStyle = GoogleFonts.montserrat(fontSize: leastFontSize, color: Colors.blue);
TextStyle titleStyle = GoogleFonts.farsan (fontSize: bodyStyle.fontSize!, color: Colors.green);
TextStyle phoneStyle = GoogleFonts.noticiaText(fontSize: titleStyle.fontSize!, color: Colors.blue);
TextStyle nameStyle = GoogleFonts.handlee(fontSize: leastFontSize, color: Colors.blue);
TextStyle tileTitleStyle = GoogleFonts.neuton(fontSize: leastFontSize + 2, fontWeight: FontWeight.bold, color: Colors.black);
TextStyle expandedTileTitleStyle = tileTitleStyle.copyWith(color: Colors.purple);
TextStyle buttonStyle1 = GoogleFonts.farsan(color: Colors.white, fontSize: leastFontSize + 2, fontWeight: FontWeight.bold);

double leftPad = 12;

List<Permission> permissions = [
  Permission.phone, // Combines READ_PHONE_STATE and READ_PHONE_NUMBERS
  Permission.sms,
];
