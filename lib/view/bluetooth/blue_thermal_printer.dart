import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as IMG;
import 'package:flutter_bluetooth/utils/printerenum.dart' as ENUM;

import '../../utils/test_print.dart';

class BlueThermalPrinterPage extends StatefulWidget {
  const BlueThermalPrinterPage({Key? key}) : super(key: key);

  @override
  State<BlueThermalPrinterPage> createState() => _BlueThermalPrinterPageState();
}

class _BlueThermalPrinterPageState extends State<BlueThermalPrinterPage> {
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;

  bool _connected = false;
  TestPrint testPrint = TestPrint();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  printTest2()async{
    final ByteData data = await rootBundle.load('assets/ic_love.png');

    final Uint8List imgBytes = data.buffer.asUint8List();
    // IMG.Image? img = IMG.decodeImage(imgBytes);
    // IMG.Image resized = IMG.copyResize(img!, width: 100, height: 100);
    // Uint8List resizedImg = Uint8List.fromList(IMG.encodePng(resized));
    // printer.printImageBytes(resizedImg); //image from Asset

    var response = await http.get(Uri.parse(
        "https://e7.pngegg.com/pngimages/615/342/png-clipart-red-heart-illustration-love-heart-love-heart-romance-symbol-love-symbol-love-heart-thumbnail.png"));
    Uint8List bytesNetwork = response.bodyBytes;
    Uint8List imageBytesFromNetwork = bytesNetwork.buffer
        .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);
    IMG.Image? img = IMG.decodeImage(imageBytesFromNetwork);
    IMG.Image resized = IMG.copyResize(img!, width: 100, height: 100);
    Uint8List resizedImg = Uint8List.fromList(IMG.encodePng(resized));

    printer.printNewLine();
    printer.printNewLine();
    printer.printCustom("GUSTIAM", ENUM.Size.boldMedium.val, ENUM.Align.center.val);
    printer.printNewLine();
    printer.printImageBytes(resizedImg); //image from Asset
    printer.printNewLine();
    printer.printNewLine();
    printer.printCustom("RINI", ENUM.Size.boldMedium.val, ENUM.Align.center.val);
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }

  printTest()async{

    final ByteData data = await rootBundle.load('assets/icon_app.png');

    final Uint8List imgBytes = data.buffer.asUint8List();
    IMG.Image? img = IMG.decodeImage(imgBytes);
    IMG.Image resized = IMG.copyResize(img!, width: 100, height: 100);
    Uint8List resizedImg = Uint8List.fromList(IMG.encodePng(resized));
    printer.printImageBytes(resizedImg); //image from Asset


    printer.printNewLine();
    printer.printCustom("HEADER", ENUM.Size.boldMedium.val, ENUM.Align.center.val);

    // printer.printNewLine();
    // printer.printImage(file.path); //path of your image/logo
    // printer.printNewLine();
    // printer.printImageBytes(imageBytesFromAsset); //image from Asset
    // printer.printNewLine();
    // printer.printImageBytes(imageBytesFromNetwork); //image from Network
    printer.printNewLine();
    printer.printLeftRight("LEFT", "RIGHT", ENUM.Size.medium.val);
    printer.printLeftRight("LEFT", "RIGHT", ENUM.Size.bold.val);
    printer.printLeftRight("LEFT", "RIGHT", ENUM.Size.bold.val,
        format:
        "%-15s %15s %n"); //15 is number off character from left or right
    printer.printNewLine();
    printer.printLeftRight("LEFT", "RIGHT", ENUM.Size.boldMedium.val);
    printer.printLeftRight("LEFT", "RIGHT", ENUM.Size.boldLarge.val);
    printer.printLeftRight("LEFT", "RIGHT", ENUM.Size.extraLarge.val);
    printer.printNewLine();
    printer.print3Column("Col1", "Col2", "Col3", ENUM.Size.bold.val);
    printer.print3Column("Col1", "Col2", "Col3", ENUM.Size.bold.val,
        format:
        "%-10s %10s %10s %n"); //10 is number off character from left center and right
    printer.printNewLine();
    printer.print4Column("Col1", "Col2", "Col3", "Col4", ENUM.Size.bold.val);
    printer.print4Column("Col1", "Col2", "Col3", "Col4", ENUM.Size.bold.val,
        format: "%-8s %7s %7s %7s %n");
    printer.printNewLine();
    printer.printCustom("čĆžŽšŠ-H-ščđ", ENUM.Size.bold.val, ENUM.Align.center.val,
        charset: "windows-1250");
    printer.printLeftRight("Številka:", "18000001", ENUM.Size.bold.val,
        charset: "windows-1250");
    printer.printCustom("Body left", ENUM.Size.bold.val, ENUM.Align.left.val);
    printer.printCustom("Body right", ENUM.Size.medium.val, ENUM.Align.right.val);
    printer.printNewLine();
    printer.printCustom("Thank You", ENUM.Size.bold.val, ENUM.Align.center.val);
    printer.printNewLine();
    printer.printQRcode(
        "Insert Your Own Text to Generate", 200, 200, ENUM.Align.center.val);
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await printer.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await printer.getBondedDevices();
    } on PlatformException {}

    printer.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      this.devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Blue Thermal Printer'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    'Device:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: DropdownButton(
                      items: _getDeviceItems(),
                      onChanged: (BluetoothDevice? value) =>
                          setState(() => selectedDevice = value),
                      value: selectedDevice,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.brown),
                    onPressed: () {
                      initPlatformState();
                    },
                    child: const Text(
                      'Refresh',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: _connected ? Colors.red : Colors.green),
                    onPressed: _connected ? _disconnect : _connect,
                    child: Text(
                      _connected ? 'Disconnect' : 'Connect',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.brown),
                  onPressed: () async {

                    if((await printer.isConnected)!){
                      // printTest();
                      printTest2();
                      // printer.printNewLine();
                      // printer.printCustom('Thermal Printer Demo', 0, 1);
                      // printer.printQRcode('Thermal Printer Demo', 200, 200, 1);
                      // printer.printNewLine();
                      // printer.printNewLine();
                      // printer.printNewLine();
                      // printer.printNewLine();
                    }
                  },
                  child: const Text('PRINT TEST',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (devices.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      for (var device in devices) {
        items.add(DropdownMenuItem(
          value: device,
          child: Text(device.name ?? ""),
        ));
      }
    }
    return items;
  }

  void _connect() {
    if (selectedDevice != null) {
      printer.isAvailable.then((value) => print('Is Available => $value'));
      printer.isOn.then((value) => print('Is On => $value'));
      printer.isConnected.then((value) => print('Is Connected => $value'));
      printer.isAvailable.then((isAvailable) {
        if (isAvailable == true) {
          printer.connect(selectedDevice!).catchError((error) {
            print('ALDI_LOG =>$error');
            setState(() => _connected = false);
          });
          setState(() => _connected = true);
          print('ALDI_LOG =>$_connected');
        }
      });
    } else {
      print('No device selected.');
    }
  }

  void _disconnect() {
    print('Disconnected status ');
    printer.disconnect();
    setState(() => _connected = false);
  }

  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }
}
