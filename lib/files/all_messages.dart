import 'dart:developer';
import 'widgets.dart';
import 'package:flutter/material.dart';
import 'functions.dart';
import 'home.dart';
import 'variables.dart';

class AllMessages extends StatefulWidget {
  final List<List<String>> items;

  const AllMessages({super.key, required this.items});

  @override
  State<AllMessages> createState() => _AllMessagesState();
}




class _AllMessagesState extends State<AllMessages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.green,

        title: Text(
          'ALL Messages for $displayedDate',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final message = widget.items[index];
                return Message(message: message);
              },
            ),
          ),
          Container(
            height: 40,
            color: Colors.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Celebrants: ${localsCelebsCount + interCelebsCount}',
                    style: phoneStyle.copyWith(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Cost: $naira${totalLocalCost.toInt() + totalIntCost.toInt()}',
                    style: phoneStyle.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 60,
            color: Colors.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    checkForPreviousSending();
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                      const Size(100, 40),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  child: const Text(
                    'SEND',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyHome(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                      const Size(100, 40),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  child: const Text(
                    'BACK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessages() async {
    Map<String, dynamic> messagePack = {
      "SimSlot": selectedSim,
      "messages": widget.items,
    };
    final String result = await callNativeFunction(
        'sendMessages', messagePack);
    setState(() {
      showToast(msg: result, duration: 5);
    });
  }


  void checkForPreviousSending(){
    log('The date is $appliedDate');
    log('Dates thar have been sent are:-');
    printList(sentDates);
    if(!sentDates.contains(appliedDate)){
      confirmSendMessage();
    } else {
      MyConfirmationDialog(
        context: context,
        title: 'Confirm Send Message',
        message: 'You have already sent messages for the day\nAre you sure that you want to send these messages?',
        onPressed: sendMessages,
      ).confirmAction();

    }
  }

  void confirmSendMessage(){

    showDialog(context: context, builder: (BuildContext context){

      return AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        titleTextStyle: titleStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
        contentTextStyle: phoneStyle.copyWith(color: Colors.black),
        alignment: Alignment.center,
        title: const Text(
          'Confirmation',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Are you sure you want to send the messages?\nTap\nSEND to send\nCANCEL to cancel',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: (){
              sendMessages();
              sentDates.add(appliedDate);
              saveList(sentDates, sentDatesFileName);
              Navigator.of(context).pop();
            },
            child: const Text(
              'SEND',
            ),
          ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: const Text(
              'CANCEL',
            ),
          ),
        ],
      );
    },

    );

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
            borderRadius: BorderRadius.circular(10),
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
}

