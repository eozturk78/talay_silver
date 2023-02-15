import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/model/header.dart';
import 'package:talay_mobile/screens/search-stock/search-stock-detailed/search-stock-detailed.dart';
import 'package:talay_mobile/screens/stock/stock-detail.dart';
import 'package:talay_mobile/screens/stock/stock-price-analyse.dart';

import '../../../apis/apis.dart';
import '../../../colors/constant_colors.dart';
import '../../stock-basket/stock-basket-detail.dart';

class SearchStockScreen extends StatefulWidget {
  SearchStockScreen({Key? key}) : super(key: key);

  SearchStockState createState() => SearchStockState();
}

class SearchStockState extends State<SearchStockScreen> {
  Barcode? result;
  QRViewController? controller;

  bool isRedirected = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    /* if (Platform.isAndroid) {
      controller!.pauseCamera();
    }*/
    //controller!.resumeCamera();
  }

  @override
  void initState() {
    // TODO: implement initState
    //startCamera();
    isRedirected = false;
    super.initState();
  }

  startCamera() async {
    print("start camera");
    await controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Ürünü Bul"),
          shadowColor: null,
          leading: leading(context),
          elevation: 0.0,
          bottomOpacity: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: headerAction(context),
        ),
        backgroundColor: splashBackGroundColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            color: Colors.white,
          ),
          child: Column(
            children: <Widget>[
              Expanded(flex: 4, child: _buildQrView(context)),
              TextButton(
                  onPressed: () async {
                    controller!.stopCamera();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) =>
                                const SearchStockDetailedScreen())));
                  },
                  child: const Text("Detaylı Arama")),
            ],
          ),
        ));
  }

  Widget _buildQrView(BuildContext context) {
    print("start to get camera");
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Color.fromARGB(255, 8, 1, 0),
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      startCamera();
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        getStockInfo();
      });
    });
  }

  getStockInfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (result?.code != null) {
      String code = result?.code ?? "";
      Apis apis = Apis();
      String? cid = pref.getString("currencyId");

      if (pref.getString("redirectPage") == "analyse") {
        await apis.getStockPriceAnalysis(code, cid).then(
          (value) {
            pref.setString('stockInfo', jsonEncode(value));
            if (!isRedirected) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const StockPriceAnalyseScreen())).then((value) {
                isRedirected = false;
                startCamera();
              });
              isRedirected = true;
              controller?.stopCamera();
            }
          },
        );
      } else if (pref.getString("redirectPage") == "basket") {
        await apis.getStockBasketPrice(pref.getString("basketId"), code).then(
          (value) {
            print(jsonEncode(value));
            pref.setString('stockInfo', jsonEncode(value));
            if (!isRedirected) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const StockBasketDetailScreen())).then((value) {
                isRedirected = false;
                startCamera();
              });
              isRedirected = true;
              controller?.stopCamera();
            }
          },
        );
      } else {
        await apis.getStockInfo(code, cid, null).then(
          (value) {
            pref.setString('stockInfo', jsonEncode(value));
            if (!isRedirected) {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StockDetailScreen()))
                  .then((value) {
                isRedirected = false;
                startCamera();
              });
              isRedirected = true;
              controller?.stopCamera();
            }
          },
        );
      }
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
