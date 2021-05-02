// @dart=2.9
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';

Color darkGrey = Colors.grey[900];
const Color darkGrey2 = Color(0xFF1a1a1a);
const Color darkBlueGrey = Color(0xff0e1a2b);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(_) => MaterialApp(
    home: DevicesPage(),
    debugShowCheckedModeBanner: false,
    darkTheme: ThemeData.dark().copyWith(
      accentColor: Colors.deepPurpleAccent.shade100,
      appBarTheme: ThemeData.dark().appBarTheme.copyWith(
        backgroundColor: darkGrey,
        elevation: 0,
      ),
      cardColor: darkGrey,
      cardTheme: ThemeData.dark().cardTheme.copyWith(
        elevation: 0,
        margin: EdgeInsets.all(6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          side: BorderSide(
            color: ThemeData.dark().dividerColor,
            width: 2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        labelStyle: TextStyle(color: Colors.white70),
      ),
      primaryColor: Colors.deepPurpleAccent.shade100,
      scaffoldBackgroundColor: darkGrey,
      timePickerTheme: ThemeData.dark().timePickerTheme.copyWith(
        backgroundColor: darkGrey2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    theme: ThemeData.light().copyWith(
      accentColor: Colors.deepPurple.shade400,
      appBarTheme: ThemeData.light().appBarTheme.copyWith(
        elevation: 0,
      ),
      cardColor: Colors.white,
      cardTheme: ThemeData.light().cardTheme.copyWith(
        elevation: 0,
        margin: EdgeInsets.all(6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          side: BorderSide(
            color: ThemeData.light().dividerColor,
            width: 2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        labelStyle: TextStyle(color: Colors.grey[700]),
      ),
      primaryColor: Colors.deepPurple.shade400,
      scaffoldBackgroundColor: Colors.white,
      timePickerTheme: ThemeData.light().timePickerTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    title: 'Irritate',
  );
}

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  Widget build(_) => Scaffold(
    appBar: AppBar(
      title: Text('Devices'),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded),
          onPressed: () => setState(() {}),
          tooltip: 'Refresh devices',
        ),
      ],
    ),
    body: FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot<List<BluetoothDevice>> snapshot) =>
      snapshot.connectionState == ConnectionState.waiting ?
      Center(
        child: CircularProgressIndicator(),
      ) :
      !snapshot.hasData ?
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_very_dissatisfied_rounded,
              size: 200,
            ),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ) :
      snapshot.data.length == 0 ?
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 200,
            ),
            Text(
              'No device found',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ) :
      ListView.builder(
        physics: ClampingScrollPhysics(),
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) => ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              width: 2,
            ),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HandlePage(
                device: snapshot.data[index],
              ),
            ),
          ),
          leading: Icon(
            Icons.bluetooth_rounded,
            color: Theme.of(context).primaryColor,
          ),
          trailing: Icon(Icons.keyboard_arrow_right_outlined),
          title: Text(
            snapshot.data[index].name,
          ),
        ),
      ),
      future: FlutterBluetoothSerial.instance.getBondedDevices(),
    ),
  );
}

class HandlePage extends StatefulWidget {
  final BluetoothDevice device;

  const HandlePage({Key key, @required this.device}) : super(key: key);

  @override
  _HandlePageState createState() => _HandlePageState();
}

class _HandlePageState extends State<HandlePage> {
  var startTimeController = new TextEditingController();
  var stopTimeController = new TextEditingController();

  get getTime => showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  BluetoothConnection connection;

  @override
  void initState() {
    super.initState();
    connect();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }

  connect() async {
    connection = await BluetoothConnection.toAddress(widget.device.address);
    setState(() {});
  }

  disconnect() {
    if (connection != null && connection.isConnected) {
      connection.close();
      connection.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.device.name),
    ),
    body: connection == null ?
    Center(
      child: CircularProgressIndicator(),
    ) :
    !connection.isConnected ?
    Center(
      child: Icon(Icons.error_outline_rounded),
    ) :
    ListView(
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      children: [
        Card(
          child: ListView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  'Timer',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'Set start time and stop',
                ),
              ),
              TextField(
                controller: startTimeController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.play_arrow_rounded),
                  suffixIcon: Icon(Icons.keyboard_arrow_right_outlined),
                  labelText: 'Start time',
                ),
                onTap: () => getTime.then((value) {
                  if (value != null)
                    startTimeController.text = '${value.hour}:${value.minute}:00';
                }),
                readOnly: true,
              ),
              Divider(
                indent: 8,
                endIndent: 8,
                thickness: 2,
              ),
              TextField(
                controller: stopTimeController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.pause_rounded),
                  suffixIcon: Icon(Icons.keyboard_arrow_right_outlined),
                  labelText: 'Stop time',
                ),
                onTap: () => getTime.then((value) {
                  if (value != null) stopTimeController.text = '${value.hour}:${value.minute}:00';
                }),
                readOnly: true,
              ),
              Divider(
                indent: 8,
                endIndent: 8,
                thickness: 2,
              ),
              ListTile(
                selected: true,
                title: Text('Send'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12.0),),
                  side: BorderSide(
                    width: 2,
                  ),
                ),
                onTap: () => connection.isConnected ?
                connection.output.add(
                  ascii.encode(
                    jsonEncode(
                      {
                        'data': 1,
                        'start': startTimeController.text,
                        'stop': stopTimeController.text,
                      },
                    ),
                  ),
                ) :
                Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Card(
          child: ListView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  'Clock',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Sync mobile clock with device',
                ),
              ),
              StreamBuilder<DateTime>(
                stream: Stream.periodic(Duration(seconds: 1), (i) => DateTime.now()),
                builder: (context, AsyncSnapshot<DateTime> snapshot) => ListTile(
                  leading: Icon(Icons.alarm_rounded),
                  title: Text(
                    !snapshot.hasData ?
                    'Loading...' :
                    DateFormat('dd MMM, yyyy hh:mm:ss').format(DateTime.now()),
                  ),
                ),
              ),
              Divider(
                indent: 8,
                endIndent: 8,
                thickness: 2,
              ),
              ListTile(
                selected: true,
                title: Text('Sync'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12.0),),
                  side: BorderSide(
                    width: 2,
                  ),
                ),
                onTap: () => connection.isConnected ?
                connection.output.add(
                  ascii.encode(
                    jsonEncode(
                      {
                        'data': 0,
                        'time':
                        DateFormat('yy/MM/dd hh:mm:ss').format(DateTime.now()),
                      },
                    ),
                  ),
                ) :
                Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
// @override
// Widget build(BuildContext context) => Scaffold(
//   appBar: AppBar(
//     title: Text(widget.device.name),
//   ),
//   body:
//   connection == null ? Center(child: CircularProgressIndicator(),) :
//   !connection.isConnected ? Center(child: Icon(Icons.error_outline_rounded),) :
//   Column(
//     children: [
//       Padding(
//         child: TextField(
//           controller: startTimeController,
//           decoration: InputDecoration(
//             prefixIcon: Icon(Icons.play_arrow_rounded),
//             labelText: 'Start time',
//           ),
//           onTap: () => getTime.then((value) {
//             if(value != null) startTimeController.text = '${value.hour}:${value.minute}:00';
//           }),
//           readOnly: true,
//           style: Theme.of(context).textTheme.headline6,
//         ),
//         padding: const EdgeInsets.all(8.0),
//       ),
//       Padding(
//         child: TextField(
//           controller: stopTimeController,
//           decoration: InputDecoration(
//             prefixIcon: Icon(Icons.pause_rounded),
//             labelText: 'Stop time',
//           ),
//           onTap: () => getTime.then((value) {
//             if(value != null) stopTimeController.text = '${value.hour}:${value.minute}:00';
//           }),
//           readOnly: true,
//           style: Theme.of(context).textTheme.headline6,
//         ),
//         padding: const EdgeInsets.all(8.0),
//       ),
//       Padding(
//         child: Divider(),
//         padding: const EdgeInsets.all(8.0),
//       ),
//       Padding(
//         child: OutlinedButton(
//           child: Text('Set timer', style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.blue[400],),),
//           onPressed: () => connection.isConnected ?
//           connection.output.add(
//             ascii.encode(jsonEncode({'data':1,'start': startTimeController.text,'stop': stopTimeController.text}))
//             // '@${startTimeController.text},${stopTimeController.text}@'//@12:10:00,10:12:00@
//           ) : Navigator.of(context).pop(),
//         ),
//         padding: const EdgeInsets.all(8.0),
//       ),
//       Padding(
//         child: ElevatedButton(
//           child: Text('Sync clock', style: Theme.of(context).textTheme.headline6,),
//           onPressed: () =>
//           connection.isConnected ?
//           connection.output.add(
//               ascii.encode(jsonEncode({'data':0,'time': DateFormat('yy/MM/dd hh:mm:ss').format(DateTime.now())}))
//             // '@${startTimeController.text},${stopTimeController.text}@'//@12:10:00,10:12:00@
//           ) : Navigator.of(context).pop(),
//         ),
//         padding: const EdgeInsets.all(8.0),
//       ),
//     ],
//     crossAxisAlignment: CrossAxisAlignment.stretch,
//   ),
// );
}
