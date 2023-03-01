import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/model/header.dart';
import 'package:talay_mobile/screens/search-stock/search-stock-detailed/search-stock-detailed.dart';
import 'package:talay_mobile/screens/stock/stock-detail.dart';
import 'package:talay_mobile/screens/stock/stock-price-analyse.dart';

import '../../../apis/apis.dart';
import '../../../colors/constant_colors.dart';
import '../../../model/currency.dart';
import '../../../model/price-type.dart';
import '../../stock-basket/stock-basket-detail.dart';

class SearchStockScreen extends StatefulWidget {
  SearchStockScreen({Key? key}) : super(key: key);

  SearchStockState createState() => SearchStockState();
}

class SearchStockState extends State<SearchStockScreen> {
  int? _scanType;
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  FocusNode f1 = FocusNode();
  TextEditingController txtSearchStock = new TextEditingController();
  String? result;
  QRViewController? controller;
  List<CurrencyModel>? currencyList;
  List<PriceType>? priceTypeList;
  CurrencyModel? _selectedCurrency;
  PriceType? _selectedPriceType;
  String? redirectedPage;
  bool isRedirected = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.

  @override
  void initState() {
    // TODO: implement initState
    //startCamera();
    isRedirected = false;
    getInitPage();
    super.initState();
    Future.delayed(
      Duration(),
      () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
    );
  }

  getInitPage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    Apis apis = Apis();
    apis.getCreateBasketLookUpData().then((value) {
      setState(() {
        priceTypeList = (value['PriceTypes'] as List)
            .map(
              (e) => PriceType.fromJson(e),
            )
            .toList();
        currencyList = (value['Currencies'] as List)
            .map(
              (e) => CurrencyModel.fromJson(e),
            )
            .toList();
        if (pref.getString('currencyId') != null) {
          var cid = pref.getString("currencyId");
          _selectedCurrency =
              currencyList?.where((element) => element.CurrencyId == cid).first;
        }
        if (pref.getString('priceTypeId') != null) {
          var ptId = pref.getString("priceTypeId");
          _selectedPriceType = priceTypeList
              ?.where((element) => element.PriceTypeId == ptId)
              .first;
        }
      });
    });
    setState(() {
      _scanType =
          androidInfo.model.contains("M3") || androidInfo.model.contains("NLS")
              ? 20
              : 10;
      if (_scanType == 20) {
        setState(() {
          FocusScope.of(context).requestFocus(f1);
        });
      }
      redirectedPage = pref.getString("redirectPage")!;
    });
  }

  startCamera() async {
    FocusScope.of(context).requestFocus(f1);
    if (_scanType == 10) {
      await controller?.resumeCamera();
    }
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
            color: Colors.white,
          ),
          child: Column(
            children: <Widget>[
              if (redirectedPage != "basket")
                Padding(
                  padding: EdgeInsets.only(left: 40, right: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<CurrencyModel>(
                        hint: const Text("Döviz seç"),
                        items: currencyList?.map((e) {
                          return DropdownMenuItem<CurrencyModel>(
                            value: e,
                            child: Text(e.Symbol),
                          );
                        }).toList(),
                        onChanged: (CurrencyModel? value) async {
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          setState(
                            () {
                              if (value != null) {
                                pref.setString("currencyId", value.CurrencyId);
                              }
                              _selectedCurrency = value;
                              FocusScope.of(context).requestFocus(f1);
                            },
                          );
                        },
                        value: _selectedCurrency,
                      ),
                      if (redirectedPage != "analyse") Spacer(),
                      if (redirectedPage != "analyse")
                        DropdownButton<PriceType>(
                          hint: Text("Fiyat tipi seç"),
                          items: priceTypeList?.map((e) {
                            return DropdownMenuItem<PriceType>(
                              value: e,
                              child: Text(e.PriceTypeName),
                            );
                          }).toList(),
                          onChanged: (PriceType? e) async {
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            setState(() {
                              if (e != null) {
                                pref.setString("priceTypeId", e.PriceTypeId);
                              }
                              _selectedPriceType = e;
                            });
                            FocusScope.of(context).requestFocus(f1);
                          },
                          value: _selectedPriceType,
                        ),
                    ],
                  ),
                ),
              if (_scanType == 10)
                Expanded(flex: 3, child: _buildQrView(context)),
              if (_scanType == 20)
                const Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "Lütfen barkodu kullan",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              /*  TextFormField(
                autofocus: true,
                controller: txtSearchStock,
                focusNode: f1,
                onChanged: (value) {
                  if (value.length > 11) {
                    result = value.toString().substring(11);
                  } else {
                    result = value;
                  }
                  // txtSearchStock.text = "";
                  getStockInfo();
                },
                showCursor: true,
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: '',
                ),
              ),*/
              TextButton(
                  onPressed: () async {
                    //controller!.stopCamera();
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    const SearchStockDetailedScreen())))
                        .then((value) => startCamera());
                  },
                  child: const Text("Detaylı Arama")),
            ],
          ),
        ));
  }

  Widget _buildQrView(BuildContext context) {
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
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData.code;
        getStockInfo();
      });
    });
    controller.pauseCamera();
    controller.resumeCamera();
  }

  getStockInfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (result != null) {
      String code = result ?? "";
      Apis apis = Apis();
      String? cid = pref.getString("currencyId");

      if (pref.getString("redirectPage") == "analyse") {
        await apis.getStockPriceAnalysis(code, cid).then(
          (value) {
            pref.setString('stockInfo', jsonEncode(value));
            if (!isRedirected) {
              controller?.pauseCamera();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const StockPriceAnalyseScreen())).then((value) {
                isRedirected = false;
                startCamera();
              });
              isRedirected = true;
            }
          },
        );
      } else if (pref.getString("redirectPage") == "basket") {
        await apis.getStockBasketPrice(pref.getString("basketId"), code).then(
          (value) {
            pref.setString('stockInfo', jsonEncode(value));
            if (!isRedirected) {
              controller?.pauseCamera();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const StockBasketDetailScreen())).then((value) {
                isRedirected = false;
                startCamera();
              });
              isRedirected = true;
            }
          },
        );
      } else {
        await apis.getStockInfo(code, cid, null).then(
          (value) {
            pref.setString('stockInfo', jsonEncode(value));
            if (!isRedirected) {
              controller?.pauseCamera();
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StockDetailScreen()))
                  .then((value) {
                isRedirected = false;
                startCamera();
              });
              isRedirected = true;
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
