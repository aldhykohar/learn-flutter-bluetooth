
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as IMG;

class ESCPosBluetoothPage extends StatefulWidget {
  const ESCPosBluetoothPage({Key? key}) : super(key: key);

  @override
  State<ESCPosBluetoothPage> createState() => _ESCPosBluetoothPageState();
}

class _ESCPosBluetoothPageState extends State<ESCPosBluetoothPage> {
  final PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String? _devicesMsg;

  var orderList = [
    const ListItem(
        title: 'Beras 1 Kg', qty: 2, totalPrice: 320000, price: 145000),
    const ListItem(
        title: 'Gula Pasir 2 Kg', qty: 3, totalPrice: 50000, price: 12000),
    const ListItem(
        title: 'Santan kelapa', qty: 5, totalPrice: 80000, price: 8000),
  ];

  @override
  void initState() {
    initPrinter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print'),
      ),
      body: _devices.isEmpty
          ? Center(child: Text(_devicesMsg ?? ''))
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (c, i) {
                return ListTile(
                  leading: const Icon(Icons.print),
                  title: Text(_devices[i].name ?? ''),
                  subtitle: Text(_devices[i].address ?? ''),
                  onTap: () {
                    _startPrint(_devices[i]);
                  },
                );
              },
            ),
    );
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    _printerManager.selectPrinter(printer);
    final result =
        await _printerManager.printTicket(await _ticket(PaperSize.mm80));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(result.msg),
      ),
    );
  }

  Future<List<int>> _ticket(PaperSize paper) async {
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(paper, profile);
    List<int> bytes = [];

    // bytes += generator.text(
    //     'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    //
    // bytes += generator.text('Bold text', styles: PosStyles(bold: true));
    // bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));
    // bytes += generator.text('Underlined text',
    //     styles: PosStyles(underline: true), linesAfter: 1);
    // bytes += generator.text('Align left', styles: PosStyles(align: PosAlign.left));
    // bytes += generator.text('Align center', styles: PosStyles(align: PosAlign.center));
    // bytes += generator.text('Align right',
    //     styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    // bytes += generator.text('Text size 200%',
    //     styles: PosStyles(
    //       height: PosTextSize.size2,
    //       width: PosTextSize.size2,
    //     ));

    int total = 0;

    // Image assets
    final ByteData data = await rootBundle.load('assets/icon_app.png');


    final Uint8List imgBytes = data.buffer.asUint8List();
    final IMG.Image? image = IMG.decodeImage(imgBytes);

    IMG.Image? img = IMG.decodeImage(imgBytes);
    IMG.Image resized = IMG.copyResize(img!, width: 100, height: 100);
    Uint8List resizedImg = Uint8List.fromList(IMG.encodePng(resized));
    final IMG.Image? icon = IMG.decodeImage(resizedImg);

    bytes += generator.image(icon!);
    bytes += generator.text(
      'TOKO KU',
      styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2),
      linesAfter: 1,
    );

    for (var i = 0; i < orderList.length; i++) {
      total += orderList[i].totalPrice ?? 0;
      bytes+=generator.text(orderList[i].title ?? '');
      bytes+=generator.row([
        PosColumn(text: '${orderList[i].price} x ${orderList[i].qty}', width: 5),
        PosColumn(text: 'Rp ${orderList[i].totalPrice}', width: 7),
      ]);
    }

    bytes+=generator.feed(1);
    bytes+=generator.row([
      PosColumn(text: 'Total', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Rp $total', width: 6, styles: const PosStyles(bold: true)),
    ]);
    bytes+=generator.feed(2);
    bytes+=generator.text('Thank You',
        styles: const PosStyles(align: PosAlign.center, bold: true));

    // bytes += generator.feed(1);
    bytes += generator.cut();
    return bytes;
  }

  void initPrinter() {
    _printerManager.startScan(const Duration(seconds: 2));
    _printerManager.scanResults.listen((event) {
      if (!mounted) return;
      setState(() => _devices = event);
      print(_devices);
      if (_devices.isEmpty) setState(() => _devicesMsg = 'No Devices');
    });
  }
}

class ListItem {
  final int? totalPrice;
  final int? price;
  final int? qty;
  final String? title;

  const ListItem(
      {required this.totalPrice,
      required this.price,
      required this.qty,
      required this.title});
}
