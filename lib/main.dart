import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'files/functions.dart';
import 'files/home.dart';
import 'files/variables.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now().toLocal();
    todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal());
    initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreenAccent,
      body: Center(
        child: Visibility(
          visible: isLoading,
          replacement: const MyHome(),
          child: const CircularProgressIndicator(
            color: Colors.purple,
            backgroundColor: Colors.lightGreen,
          ),
        ),
      ),
    );
  }

  void initializeApp() async {
    prefs = await SharedPreferences.getInstance();
    getLinks();
    await getPermissions();
    await getUnitCosts();
    await getSimCount();
    // log('In initializer, Sim count is $simCount');
    // log('In initializer, Active Sim count is $activeSimCount');
    if (activeSimCount == 0) {
      noSimAlert();
    } else {
      bool isInternetAccessible = await checkInternetConnection();
      setState(() {
        isThereInternetAccess = isInternetAccessible;
      });
      await fetchCelebrantsList();
      await downloadTemplates();
      await setSimProperties();
      await processProvidersInfo().then((_) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Future<void> getPermissions() async {
    Map<Permission, PermissionStatus> permissionStatus =
        await requestPermissions();
    // Handle the permission status after the request is complete
    permissionStatus.forEach((permission, status) {
      if (status.isGranted) {
        log('${permission.toString()} is granted');
      } else if (status.isDenied) {
        log('${permission.toString()} is denied');
        if (permission == Permission.accessNotificationPolicy) {
          openAppSettings();
        }
      }
    });
    //await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> fetchCelebrantsList() async {
    if(isThereInternetAccess){
      showToast(msg: 'Internet access is available', duration: 3);
      final response = await http.get(Uri.parse(listUrl));
      if (response.statusCode == 200) {
        setState(() {
          birthDaysJson = json.decode(response.body);
        });
        String jsonString = jsonEncode(birthDaysJson);
        await writeToFile(jsonString, downloadedJsonFile);
        await saveLink(keyCelebrantsList, jsonString);
      } else {
        throw Exception('Failed to load JSON data');
      }
    } else {
      showToast(msg: 'No Internet access!!!', duration: 3);
      try{
        birthDaysJson = await loadJsonFromSharedPreferences(keyCelebrantsList);
      } catch (e){
        showToast(msg: 'There is no List in memory', duration: 3);
      }
    }

  }

  Future<void> downloadTemplates() async {
    await checkTextData(messageUrl, "messageTemplate", messageFile);
    await checkTextData(
        belatedMessageUrl, "belatedMessageTemplate", belatedMessageFile);
    await checkTextData(providersUrl, "providers", providersFile);
  }

  Future<void> processProvidersInfo() async {
    if (providers != '') {
      List<String> serviceProviders = providers.split('\n');
      List<String> parts;
      for (final String item in serviceProviders) {
        parts = item.split('@');
        providersDetails[parts[0]] = parts.sublist(1);
      }
    }
  }

  Future<void> setSimProperties() async {
    String sim1Label = getProperty("Sim1 Label", simProperties);
    String sim2Label = getProperty("Sim2 Label", simProperties);
    String simValues = getProperty("SimValues", simProperties);
    log('Sim values is: $simValues');
    simCount = int.parse(simValues.split('@')[0]);
    phoneDefaultSim = int.parse(simValues.split('@')[1]);
    if (simCount == 1) {
      selectedSim = phoneDefaultSim;
    } else if (simCount > 1) {
      int dSlot = await getDefaultSim(simCount, phoneDefaultSim);
      selectedSim = dSlot;
    }
    network1 = sim1Label;
    network2 = sim2Label;
    sim1State = convertToBool(getProperty("Sim1 State", simProperties));
    sim2State = convertToBool(getProperty("Sim2 State", simProperties));
    phone1 = getProperty("Sim1 Number", simProperties);
    phone2 = getProperty("Sim2 Number", simProperties);
    log('Sim1 state is: $sim1State\nSim2 state is: $sim2State');
  }

  Future<void> getSimCount() async {
    String callResult = await callNativeFunction("getSimProperties");
    log(callResult);
    List<String> tempList = callResult.split('\n');
    List<List<String>> properties = [];
    for (final String item in tempList) {
      properties.add(item.split('@@@'));
    }
    int activeSims;
    String simValues = getProperty("SimValues", properties);
    activeSims = int.parse(simValues.split('@')[0]);
    activeSimCount = int.parse(simValues.split('@')[2]);
    simCount = activeSims;
    log('Immediate sim count is: $activeSims');
    simProperties.addAll(properties);
  }

  String getProperty(String key, List<List<String>> properties) {
    String result = '';
    for (final List<String> item in properties) {
      if (item.contains(key)) {
        result = item[1];
        break;
      }
    }
    return result;
  }

  Future<int> getDefaultSim(int simSlotCount, int defSlot) async {
    int smsSlot;
    int defaultSlot = prefs.getInt(vDefaultSim) ?? 0;
    if (simSlotCount == 0) {
      return 0;
    } else if (simSlotCount == 1) {
      smsSlot = defSlot;
    } else {
      if (defaultSlot == 0) {
        smsSlot = defSlot;
      } else {
        smsSlot = defaultSlot;
      }
    }
    selectedSim = smsSlot;
    if (smsSlot != 0) {
      prefs.setInt(vDefaultSim, selectedSim);
      showToast(msg: 'Current sms slot is Sim $smsSlot', duration: 4);
    }
    return smsSlot;
  }

  void showToast({required String msg, required int duration}) {
    Future.delayed(Duration.zero, () {
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: Duration(seconds: duration),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            onPressed: scaffold.hideCurrentSnackBar,
          ),
        ),
      );
    });
  }

  void noSimAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            titleTextStyle:
                titleStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
            contentTextStyle: phoneStyle.copyWith(color: Colors.black),
            alignment: Alignment.center,
            content: const Text(
              'There is no sim card in the device.\nSim card is needed to send messages.\nApplication cannot run',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  exit(0);
                },
                child: const Text('OK'),
              )
            ],
          );
        });
  }
}
