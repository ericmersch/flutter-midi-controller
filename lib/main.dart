import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MidiControllerScreen(),
    );
  }
}

class MidiControllerScreen extends StatefulWidget {
  @override
  _MidiControllerScreenState createState() => _MidiControllerScreenState();
}

class _MidiControllerScreenState extends State<MidiControllerScreen> {
  final MidiCommand _midiCommand = MidiCommand();
  List<MidiDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _initMidi();
  }

void _initMidi() async {
  _midiCommand.onMidiSetupChanged?.listen((event) async {
    List<MidiDevice>? devices = await _midiCommand.devices;
    setState(() {
      _devices = devices ?? [];
    });
  });

  List<MidiDevice>? initialDevices = await _midiCommand.devices;
  setState(() {
    _devices = initialDevices ?? [];
  });

  // Connexion automatique au premier périphérique MIDI détecté
  if (_devices.isNotEmpty) {
    _midiCommand.connectToDevice(_devices.first);
  }
}


  void _sendMidiNote() {
    if (_devices.isNotEmpty) {
      Uint8List noteOn = Uint8List.fromList([0x90, 60, 127]); // Note On (C4, velocity 127)
      Uint8List noteOff = Uint8List.fromList([0x80, 60, 0]);  // Note Off (C4, velocity 0)

      _midiCommand.sendData(noteOn);
      Future.delayed(Duration(milliseconds: 500), () {
        _midiCommand.sendData(noteOff);
      });
    } else {
      print("Aucun périphérique MIDI détecté !");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MIDI Controller")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _sendMidiNote,
              child: Text("Send MIDI Note"),
            ),
            ElevatedButton(
  onPressed: () async {
    List<MidiDevice>? devices = await _midiCommand.devices;
    setState(() {
      _devices = devices ?? [];
    });
  },
  child: Text("Rafraîchir MIDI"),
),

            SizedBox(height: 20),
            Text("Devices found: ${_devices.length}"),
          ],
        ),
      ),
    );
  }
  
}
