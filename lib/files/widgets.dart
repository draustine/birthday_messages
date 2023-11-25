import 'package:birthday_messages/files/functions.dart';
import 'variables.dart';
import 'package:flutter/material.dart';

class MessageSummary extends StatelessWidget {
  final String category;
  final int categoryCount;
  final int categoryMessageCount;
  final double categoryCost;
  final void Function()? onClick;
  final Color color;
  final TextStyle textStyle;

  const MessageSummary({
    super.key,
    required this.category,
    required this.categoryCount,
    required this.categoryMessageCount,
    required this.categoryCost,
    this.onClick,
    this.color = Colors.black,
    TextStyle? textStyle, // Make it nullable
  }) : textStyle = textStyle ?? const TextStyle(fontSize: 20);


  @override
  Widget build(BuildContext context) {
    final double scaffoldWidth = MediaQuery.of(context).size.width;
    double quarterWidth = scaffoldWidth / 4;

    return GestureDetector(
      onTap: () {
        onClick?.call();
      },
      child: Row(
        children: [
          SizedBox(
            width: quarterWidth - 35,
            child: Text(
              category,
              style: textStyle.copyWith(color: color),
            ),
          ),
          SizedBox(
            width: quarterWidth + 40,
            child: Text(
              '${categoryCount.toString()} celebrants',
              style: textStyle.copyWith(color: color),
            ),
          ),
          SizedBox(
            width: quarterWidth - 10,
            child: Text(
              '${categoryMessageCount.toString()} sms',
              style: textStyle.copyWith(color: color),
            ),
          ),
          SizedBox(
            width: quarterWidth - 40,
            child: Text(
              '$naira${categoryCost.toInt().toString()}',
              style: textStyle.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}


class MyLinksUpdater extends StatelessWidget {
  final TextEditingController myController;
  final String myLabel;
  final double myHeight;
  final double myWidth;
  final String myKey;
  final void Function()? onClick;

  const MyLinksUpdater({
    super.key,
    required this.myLabel,
    this.myHeight = 40,
    this.myWidth = 160,
    required this.myKey,
    required this.myController,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (BuildContext context) {
            return ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(
                  Size(myWidth, myHeight),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              onPressed: () {
                if (myController.text != '') {
                  confirmUpdate(context, onClick);
                }
              },
              child: Text(
                myLabel,
                style: buttonStyle1,
              ),
            );
          },
        ),
        SizedBox(
          width: 10,
          height: myHeight,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              height: myHeight,
              child: TextField(
                controller: myController,
                keyboardType: TextInputType.url,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void confirmUpdate(BuildContext context, void Function()? onClick) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          title: const Text('Confirm Update'),
          content: const Text('Are you sure you want to update?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Perform the update action here
                saveLink(myKey, myController.text);
                onClick?.call();
                myController.text = '';
                Navigator.of(context).pop(); // Close the AlertDialog
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                myController.text = '';
                Navigator.of(context).pop(); // Close the AlertDialog
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}

class MyConfirmationDialogFromDialog {
  final BuildContext context;
  final String title;
  final String message;
  final VoidCallback onPressed;
  final VoidCallback dismissDialog;

  const MyConfirmationDialogFromDialog({
    required this.context,
    required this.title,
    required this.message,
    required this.onPressed,
    required this.dismissDialog,
  });

  void confirmUpdate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                onPressed();
                dismissDialog();
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}


class MyConfirmationDialog {
  final BuildContext context;
  final String title;
  final String message;
  final VoidCallback onPressed;

  const MyConfirmationDialog({
    required this.context,
    required this.title,
    required this.message,
    required this.onPressed,
  });

  void confirmAction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                onPressed();
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}



class TwoWidgetsInARow extends StatefulWidget {
  final double height;
  final double width;
  final Color color;
  final Widget widget1;
  final Widget widget2;
  final bool equalWidths;

  const TwoWidgetsInARow(
      {super.key,
      this.height = 60,
      this.width = 180,
      this.color = Colors.transparent,
      required this.widget1,
      required this.widget2,
      this.equalWidths = false});

  @override
  State<TwoWidgetsInARow> createState() => _TwoWidgetsInARowState();
}

class _TwoWidgetsInARowState extends State<TwoWidgetsInARow> {
  @override
  Widget build(BuildContext context) {
    double width = widget.equalWidths
        ? (MediaQuery.of(context).size.width) / 2 - 10
        : widget.width;

    return Container(
      height: widget.height,
      color: widget.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: width,
              child: widget.widget1,
            ),
          ),
          SizedBox(
            width: widget.equalWidths ? width : null,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.widget2,
            ),
          ),
        ],
      ),
    );
  }
}

class SimCardSlot extends TwoWidgetsInARow {
  final int simSlot;
  final String acronym;
  final String phoneNumber;
  final void Function(int?) handleChange;
  final int selectedSim;
  final double opacity;

  SimCardSlot({
    super.key,
    required this.simSlot,
    required this.acronym,
    required this.phoneNumber,
    super.height,
    super.width,
    super.color,
    required this.handleChange,
    required this.selectedSim,
    required this.opacity,
  }) : super(
          widget1: Opacity(
            opacity: opacity,
            child: SizedBox(
              width: width,
              child: RadioListTile(
                value: simSlot,
                groupValue: selectedSim,
                onChanged: handleChange,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.blue,
                title: Text(
                  acronym,
                  style: titleStyle.copyWith(
                    fontSize: titleStyle.fontSize! + 3,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          widget2: Opacity(
            opacity: opacity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
              child: Text(
                phoneNumber,
                style: phoneStyle.copyWith(
                    color: Colors.black,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
}

class Message extends StatefulWidget {
  final List<String> message;

  const Message({super.key, required this.message});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String title = widget.message[2];

    return ExpansionTile(
      title: Text(
        title,
        style: tileTitleStyle,
      ),
      collapsedTextColor: Colors.purple,
      textColor: Colors.indigo,
      onExpansionChanged: (expanded) {
        setState(() {
          isExpanded = expanded;
        });
      },
      children: [
        if (isExpanded)
          Column(children: [
            MessageBody(item: widget.message),
          ]),
      ],
    );
  }
}

class MessageBody extends StatelessWidget {
  final List<String> item;

  const MessageBody({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    String customerID = item[3];
    String body = item[1];
    String phone = item[0];
    TextAlign textAlign = TextAlign.left;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(leftPad, 2, 8, 2),
          child: Text(
            customerID,
            style: bodyStyle.copyWith(color: Colors.purple),
            textAlign: textAlign,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(leftPad, 2, 8, 2),
          child: Text(
            phone,
            style: phoneStyle,
            textAlign: textAlign,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(leftPad, 2, 8, 10),
          child: Text(
            body,
            style: bodyStyle,
            textAlign: textAlign,
          ),
        ),
      ],
    );
  }
}




