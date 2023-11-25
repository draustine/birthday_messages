
import 'package:birthday_messages/files/international_messages.dart';
import 'package:birthday_messages/files/updates.dart';
import 'package:birthday_messages/files/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'all_messages.dart';
import 'message_display.dart';
import 'variables.dart';
import 'package:flutter/material.dart';
import 'functions.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  bool _isInitialised = false;
  late double opacity1;
  late double opacity2;
  String celebsLabel = 'Potential Celebrants';
  String networksLabel = 'Providers';
  String belatedLabel = 'Belated Template';
  String messagesLabel = 'Message Template';
  String reDownloadLabel = 'RE-DOWNLOAD TEMPLATES';
  TextEditingController celebrantsController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController belatedController = TextEditingController();
  TextEditingController providersController = TextEditingController();
  TextEditingController localSms = TextEditingController();
  TextEditingController interSms = TextEditingController();

  @override
  void initState() {
    super.initState();
    organiseMessages();
    if (!_isInitialised) {
      if (sim1State) {
        opacity1 = 1;
      } else {
        opacity1 = 0;
      }
      if (sim2State) {
        opacity2 = 1;
      } else {
        opacity2 = 0;
      }
    }
    _isInitialised = true;
  }

  void refresh() {
    setState(() {
      currentDate = DateTime.now().toLocal();
      todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal());
      selectedDate = '';
      appliedDate = '';
    });
    organiseMessages();
    showToast(msg: 'Date has been reset', duration: 2);
  }

  @override
  Widget build(BuildContext context) {
    displayDateString = appliedDate == '' ? todayDate : appliedDate.toString();
    dateForDisplay = DateTime.parse(displayDateString);
    displayedDate = DateFormat('E, d MMM yyyy').format(dateForDisplay);
    final double scaffoldWidth = MediaQuery.of(context).size.width;
    double thirdOfAppBarWidth = (scaffoldWidth / 3);
    TextStyle myStyle = GoogleFonts.farsan(fontSize: 16);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleTextStyle: titleStyle.copyWith(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        title: Row(
          children: [
            SizedBox(
              width: thirdOfAppBarWidth - 80,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const UpdatePage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.update,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: thirdOfAppBarWidth + 85,
              child: Text(
                displayedDate,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: thirdOfAppBarWidth - 40,
            child: IconButton(
              onPressed: selectDate,
              icon: const Icon(
                Icons.date_range,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.lightGreenAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 310,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SimCardSlot(
                    opacity: opacity1,
                    simSlot: sim1,
                    acronym: network1,
                    phoneNumber: phone1,
                    handleChange: handleRadioValueChange,
                    selectedSim: selectedSim,
                  ),
                  SimCardSlot(
                    opacity: opacity2,
                    simSlot: sim2,
                    acronym: network2,
                    phoneNumber: phone2,
                    handleChange: handleRadioValueChange,
                    selectedSim: selectedSim,
                  ),
                  Container(
                    height: 140,
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                    child: Column(
                      children: [
                        MessageSummary(
                          category: 'TOTAL',
                          categoryCount: celebrantsCount,
                          categoryMessageCount: localSmsCount + interSmsCount,
                          categoryCost: totalIntCost + totalLocalCost,
                          color: Colors.blue,
                          textStyle: myStyle.copyWith(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          onClick: previewAllMessages,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        MessageSummary(
                          category: 'LOCAL',
                          categoryCount: localsCelebsCount,
                          categoryMessageCount: localSmsCount,
                          categoryCost: totalLocalCost,
                          textStyle: myStyle.copyWith(
                            fontSize: 20,
                          ),
                          onClick: previewMessages,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        MessageSummary(
                          category: 'INT\'L',
                          categoryCount: interCelebsCount,
                          categoryMessageCount: interSmsCount,
                          categoryCost: totalIntCost,
                          textStyle: myStyle.copyWith(
                            fontSize: 20,
                          ),
                          onClick: previewInternationalMessages,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: refresh,
                      child: Center(
                        child: Image.asset(
                          'images/precise.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleRadioValueChange(int? value) {
    setState(() {
      if (value! == 1) {
        if (sim1State) {
          selectedSim = value;
        } else if (sim2State) {
          selectedSim = 2;
        }
      } else {
        if (sim2State) {
          selectedSim = value;
        } else if (sim1State) {
          selectedSim = 1;
        }
      }
      storeInteger(vDefaultSim, selectedSim);
    });

    String comment = 'Sim $selectedSim has been set as the default sim for SMS';
    showToast(msg: comment, duration: 4);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      // The user has selected a date.
      selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      // You can use formattedDate to store or display the selected date.
    } else {
      selectedDate = todayDate;
    }
    setState(() {
      appliedDate = selectedDate;
    });
  }

  selectDate() async {
    await _selectDate(context);
    organiseMessages();
  }

  void rePlaceTemplates() {
    //TODO: Develop
  }

  void previewMessages() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Messages(
          items: addNetworkCodes(localMessageList),
        ),
      ),
    );
  }

  void storeInteger(String vName, int simSlot) async {
    prefs.setInt(vName, simSlot);
  }

  void showToast({required String msg, required int duration}) {
    Future.delayed(Duration.zero, () {
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: Text(msg),
          elevation: 300,
          duration: Duration(seconds: duration),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
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

  void previewInternationalMessages() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InternationalMessages(
          items: addNetworkCodes(internationalMessageList),
        ),
      ),
    );
  }

  void previewAllMessages() {
    List<List<String>> allMessages = [];
    allMessages.addAll(localMessageList);
    allMessages.addAll(internationalMessageList);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllMessages(
          items: addNetworkCodes(allMessages),
        ),
      ),
    );
  }
}
