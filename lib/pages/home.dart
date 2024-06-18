import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: "1", name: "One Direction", votes: 5),
    Band(id: "2", name: "BTS", votes: 2),
    Band(id: "3", name: "Bon Jovi", votes: 3),
    Band(id: "4", name: "Mana", votes: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('BandNames'),
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, index) => _bandTile(bands[index]),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: addNewBand,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id!),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print(direction);
        print(band.id);
      },
      background: Container(
        padding: const EdgeInsets.only(left: 8),
        color: Colors.red,
        child: const Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name!.substring(0, 2)),
        ),
        title: Text(band.name!),
        trailing: Text(
          band.votes.toString(),
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    if (Platform.isIOS) {
      // ANDROID
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("New band name"),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                child: const Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              MaterialButton(
                textColor: Colors.blue,
                child: const Text("Add"),
                onPressed: () => addBandToList(textController.text),
              )
            ],
          );
        },
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("New band name"),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              // textStyle: const TextStyle(color: Colors.black),
              isDestructiveAction: true,
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              // textStyle: const TextStyle(color: Colors.blue),
              isDefaultAction: true,
              child: const Text("Add"),
              onPressed: () => addBandToList(textController.text),
            ),
          ],
        );
      },
    );
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      bands.add(Band(
        id: DateTime.now().toString(),
        name: name,
        votes: 0,
      ));
      setState(() {});
    }

    Navigator.of(context).pop();
  }
}
