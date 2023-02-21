import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/apis/apis.dart';
import 'package:talay_mobile/model/detailed-dare.dart';
import 'package:talay_mobile/screens/baskete-details/basket-detail.dart';

import '../../colors/constant_colors.dart';
import '../../model/basket-row.dart';
import '../../model/header.dart';
import '../../shared/shared.dart';
import '../../style-model/style-model.dart';

class StockTareGrossWeightScreen extends StatefulWidget {
  const StockTareGrossWeightScreen(Key? key) : super(key: key);
  StockTareGrossWeightState createState() => StockTareGrossWeightState();
}

class StockTareGrossWeightState extends State<StockTareGrossWeightScreen> {
  BasketRow? basketDetail;
  int _tareType = 10;
  double netWeight = 0;
  double quantity = 0;
  double grossWeight = 0;
  double tareWeight = 0;
  bool loaderButton = false;
  TextEditingController quantityController = new TextEditingController();
  TextEditingController grossController = new TextEditingController();
  TextEditingController tareContoller = new TextEditingController();
  double totalDare = 0;
  Shared sh = new Shared();
  TextEditingController detailedQuantityController =
      new TextEditingController();
  TextEditingController detailedWeightController = new TextEditingController();
  List<DetailedDare> detailedDares = [];
  @override
  void initState() {
    // TODO: implement initState
    getDataFromShared();
    detailedDares.clear();
    super.initState();
  }

  getDataFromShared() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      basketDetail = ModalRoute.of(context)!.settings.arguments as BasketRow?;
      if (basketDetail?.DetailedTare?.length != 0) {
        setState(() {
          _tareType = 20;
          if (basketDetail?.DetailedTare != null) {
            basketDetail?.DetailedTare?.forEach((element) {
              detailedDares.add(element);
            });
          }
        });
      }
      if (basketDetail?.Quantity != null) {
        print(basketDetail?.Quantity);
        quantityController.value = quantityController.value.copyWith(
          text: basketDetail?.Quantity.toString(),
          selection: TextSelection.collapsed(offset: 6),
        );
      }
      if (basketDetail?.GrossWeight != null) {
        grossController.value = grossController.value.copyWith(
          text: sh.numberFormatter(basketDetail?.GrossWeight),
          selection: TextSelection.collapsed(offset: 6),
        );
      }
      if (basketDetail?.TareWeight != null) {
        tareContoller.value = tareContoller.value.copyWith(
          text: sh.numberFormatter(basketDetail?.TareWeight),
          selection: TextSelection.collapsed(offset: 6),
        );
      }
      if (grossController.text.isNotEmpty && tareContoller.text.isNotEmpty) {
        netWeight =
            double.parse(sh.prePareNumberForRequest(grossController.text)) -
                double.parse(sh.prePareNumberForRequest(tareContoller.text));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Brüt / Dara Girişi"),
        leading: leadingWithBack(context),
        shadowColor: null,
        elevation: 0.0,
        bottomOpacity: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: headerAction(context),
      ),
      backgroundColor: splashBackGroundColor,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 1),
                        blurRadius: 5,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          basketDetail?.StockImage != null
                              ? Image(
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                      "${basketDetail?.StockImage.toString()}"),
                                )
                              : Image.asset("assets/images/image-ph.jpg",
                                  width: 90, height: 90, fit: BoxFit.fill),
                          const SizedBox(
                            width: 30,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 200,
                                child: Text(
                                  "${basketDetail?.StockName.toString()}",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text("${basketDetail?.StockCode.toString()}"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: quantityController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'Adet',
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9,]')),
                  ],
                  controller: grossController,
                  onChanged: (value) {
                    setState(() {
                      if (grossController.text.isNotEmpty) {
                        print(value);
                        netWeight = double.parse(
                                sh.prePareNumberForRequest(value)) -
                            double.parse(
                                sh.prePareNumberForRequest(tareContoller.text));
                      }
                    });
                  },
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'Brüt Ağırlık',
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _tareType = 10;
                          });
                        },
                        child: const Text("Toplam Dara"),
                        style: _tareType == 10
                            ? const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll<Color>(Colors.red),
                              )
                            : const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll<Color>(
                                        Color.fromARGB(255, 112, 112, 112)),
                              ),
                      ),
                      const Text(" "),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _tareType = 20;
                          });
                        },
                        child: const Text("Detaylı Dara"),
                        style: _tareType == 20
                            ? const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll<Color>(Colors.red),
                              )
                            : const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll<Color>(
                                        Color.fromARGB(255, 112, 112, 112)),
                              ),
                      )
                    ],
                  ),
                ),
                if (_tareType == 10)
                  TextFormField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9,]')),
                    ],
                    controller: tareContoller,
                    onChanged: (value) {
                      setState(() {
                        if (grossController.text.isNotEmpty) {
                          netWeight = double.parse(sh.prePareNumberForRequest(
                                  grossController.text)) -
                              double.parse(sh.prePareNumberForRequest(value));
                        }
                      });
                    },
                    obscureText: false,
                    decoration: const InputDecoration(
                      labelText: 'Toplam Dara',
                    ),
                  ),
                if (_tareType == 20)
                  Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            detailedWeightController.clear();
                            detailedQuantityController.clear();
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  updatePackedQuantity(context),
                            ).then(
                              (value) => setState(
                                () {},
                              ),
                            );
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.add), Text("Yeni Dara Paketi")],
                        ),
                      ),
                      DataTable(
                        columns: [
                          DataColumn(label: Text('Paket')),
                          DataColumn(label: Text('Adet')),
                          DataColumn(label: Text(' ')),
                        ],
                        rows: detailedDares
                            .map(
                              ((element) => DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(sh.numberFormatter(element
                                          .Weight))), //Extracting from Map element the value
                                      DataCell(
                                          Text(element.Quantity.toString())),
                                      DataCell(GestureDetector(
                                        onTap: (() {
                                          setState(() {
                                            totalDare -= element.Quantity *
                                                element.Weight;
                                            detailedDares.remove(element);
                                          });
                                        }),
                                        child: Icon(Icons.delete),
                                      )),
                                    ],
                                  )),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  "Net Ağırlık",
                  style: labelText,
                ),
                Text(
                  sh.numberFormatter(netWeight),
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loaderButton = true;
                        });
                        Apis apis = Apis();
                        if (quantityController.text.isNotEmpty) {
                          quantity =
                              double.parse(quantityController.text.toString());
                        }

                        if (grossController.text.isNotEmpty) {
                          grossWeight = double.parse(
                              sh.prePareNumberForRequest(grossController.text));
                        }

                        if (tareContoller.text.isNotEmpty) {
                          tareWeight = double.parse(
                              sh.prePareNumberForRequest(tareContoller.text));
                        }
                        apis
                            .updateBasketDetail(
                                basketDetail!.BasketDetailId,
                                grossWeight,
                                tareWeight,
                                quantity,
                                detailedDares,
                                _tareType)
                            .then((value) {
                          setState(() {
                            loaderButton = false;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BasketDetailScreen(null)));
                        });
                      },
                      child: loaderButton == false
                          ? const Text("Güncelle")
                          : SpinKitCircle(
                              color: Colors.white,
                              size: 30.0,
                            ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget updatePackedQuantity(BuildContext context) {
    return AlertDialog(
        title: Text("Paket Ağırlığı & Adet"),
        content: StatefulBuilder(builder: (BuildContext context, setState) {
          return FittedBox(
              fit: BoxFit.none,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  children: [
                    TextFormField(
                      controller: detailedQuantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      obscureText: false,
                      decoration: const InputDecoration(
                        labelText: 'Adet',
                      ),
                      validator: (text) => sh.textValidator(text),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: detailedWeightController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9,]')),
                      ],
                      obscureText: false,
                      decoration: const InputDecoration(
                        labelText: 'Paket Ağırlığı',
                      ),
                      validator: (text) => sh.emailValidator(text),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40)),
                        onPressed: () async {
                          var p = DetailedDare(
                              Quantity: int.parse(sh.prePareNumberForRequest(
                                  detailedQuantityController.text)),
                              Weight: double.parse(sh.prePareNumberForRequest(
                                  detailedWeightController.text)));
                          detailedDares.add(p);

                          totalDare += double.parse(sh.prePareNumberForRequest(
                                  detailedWeightController.text)) *
                              double.parse(sh.prePareNumberForRequest(
                                  detailedQuantityController.text));

                          tareContoller.value = tareContoller.value.copyWith(
                            text: sh.numberFormatter(totalDare).toString(),
                            selection: TextSelection.collapsed(offset: 6),
                          );

                          if (grossController.text.isNotEmpty) {
                            netWeight = double.parse(sh.prePareNumberForRequest(
                                    grossController.text)) -
                                totalDare;
                          }

                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                        },
                        child: Text('Ekle'))
                  ],
                ),
              ));
        }));
  }
}
