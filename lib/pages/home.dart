import 'dart:io';

import 'package:bandNames/models/band.dart';
import 'package:bandNames/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        final socketService =
            Provider.of<SocketService>(context, listen: false);
        socketService.socket.on('active-bands', _handleActiveBands);
      },
    );
    super.initState();
  }

  void _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    // bands = Band.fromMap(bands);
    // print(payload);
    setState(() {});
  }

  void _socketsSevices(
      {required String option, required String action, required dynamic data}) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    switch (option) {
      case "emit":
        socketService.emit(action, data);
        break;
      default:
    }
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: socketService.serveStatus == ServerStatus.Online
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : const Icon(
                    Icons.check_circle,
                    color: Colors.red,
                  ),
          ),
        ],
        title: const Text('BandNames'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandTile(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: addNewBand,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    // final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id!),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => _socketsSevices(
          option: "emit", action: "delete-band", data: {"id": band.id}),
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
        onTap: () => _socketsSevices(
            option: "emit", action: 'vote-band', data: {"id": band.id}),
        // socketService.socket.emit('vote-band', {"id": band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
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
        ),
      );
    } else {
      // ANDROID
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
        ),
      );
    }
  }

  void addBandToList(String name) {
    // final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      _socketsSevices(option: "emit", action: 'add-band', data: {'name': name});
      // socketService.emit('add-band', {'name': name});
    }

    Navigator.of(context).pop();
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {};

    for (var band in bands) {
      dataMap.putIfAbsent(band.name!, () => band.votes!.toDouble());
    }

    List<Color> colors = [
      Colors.red,
      Colors.blue[300]!,
      Colors.purple,
      Colors.yellow,
    ];

    return PieChart(
      dataMap: dataMap,
      animationDuration: const Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      colorList: colors,
      initialAngleInDegree: 360,
      emptyColor: Colors.black12,
      chartType: ChartType.ring,
      ringStrokeWidth: 32,
      chartValuesOptions: const ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: true,
        showChartValuesOutside: false,
        decimalPlaces: 1,
      ),
    );
  }
}
