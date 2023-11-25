import 'functions.dart';
import 'variables.dart';
import 'widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
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
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "UPDATES",
          style: titleStyle.copyWith(color: Colors.white),
        ),
      ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                  'UPDATE LINKS'
              ),
              MyLinksUpdater(
                myController: celebrantsController,
                myLabel: celebsLabel,
                myKey: vListUrl,
              ),
              MyLinksUpdater(
                myController: messageController,
                myLabel: messagesLabel,
                myKey: vMessageUrl,
              ),
              MyLinksUpdater(
                myController: belatedController,
                myLabel: belatedLabel,
                myKey: vBelatedUrl,
              ),
              MyLinksUpdater(
                myController: providersController,
                myLabel: networksLabel,
                myKey: vProvidersUrl,
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                  'UPDATE SMS COST'
              ),
              const SizedBox(
                height: 4,
              ),
              MyLinksUpdater(
                myController: localSms,
                myLabel: 'LOCAL',
                myKey: vLocalUnitCost,
                onClick: callUpdateLinks,
              ),
              MyLinksUpdater(
                myController: interSms,
                myLabel: 'INTERNATIONAL',
                myKey: vIntUnitCost,
                onClick: callUpdateLinks,
              ),
              const SizedBox(
                height: 12,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  backgroundColor: const MaterialStatePropertyAll(Colors.blue),
                ),
                onPressed: () {
                  reDownloadTemplates();
                },
                child: Text(
                  reDownloadLabel,
                  style: GoogleFonts.farsan(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
    );
  }


  void reDownloadTemplates() async {
    await downloadTextFile(messageUrl, "messageTemplate", messageFile);
    await downloadTextFile(
        belatedMessageUrl, "belatedMessageTemplate", belatedMessageFile);
    await downloadTextFile(providersUrl, "providers", providersFile);
    showToast(msg: 'Templates successfully downloaded', duration: 3);
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

  void updateAll() async {
    List<List<String>> valuePairs = [];
    valuePairs.add([vListUrl, celebrantsController.text]);
    valuePairs.add([vMessageUrl, messageController.text]);
    valuePairs.add([vBelatedUrl, belatedController.text]);
    valuePairs.add([vProvidersUrl, providersController.text]);

    for (final List<String> item in valuePairs) {
      if (item[1] != '') {
        await saveLink(item[0], item[1]);
      }
    }
  }

  callUpdateLinks() async {
    getThisUnitCosts();
    setState(() {

    });
  }

  void getThisUnitCosts() async {
    double value;
    value = await getCostPerUnit(vLocalUnitCost);
    setState(() {
      localSmsUnitCost = value;
    });
    value = await getCostPerUnit(vIntUnitCost);
    setState(() {
      internationalSmsUnitCost = value;
    });
    organiseMessages();
  }

  Future<double> getCostPerUnit(String key) async {
    String value;
    String defValue = key == vLocalUnitCost ? localSmsUnitCost.toString() : internationalSmsUnitCost.toString();
    value = prefs.getString(key) ?? defValue.toString();
    return double.parse(value);
  }


}
