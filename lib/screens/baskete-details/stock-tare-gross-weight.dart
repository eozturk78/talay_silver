import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        quantityController.value = quantityController.value.copyWith(
          text: basketDetail?.Quantity.toString(),
          selection: TextSelection.collapsed(offset: 6),
        );
      }
      if (basketDetail?.GrossWeight != null) {
        grossController.value = grossController.value.copyWith(
          text: basketDetail?.GrossWeight.toString(),
          selection: TextSelection.collapsed(offset: 6),
        );
      }
      if (basketDetail?.TareWeight != null) {
        tareContoller.value = tareContoller.value.copyWith(
          text: basketDetail?.TareWeight.toString(),
          selection: TextSelection.collapsed(offset: 6),
        );
      }
      if (grossController.text.isNotEmpty && tareContoller.text.isNotEmpty) {
        netWeight = double.parse(grossController.text.toString()) -
            double.parse(tareContoller.text.toString());
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
                  controller: quantityController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'Adet',
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: grossController,
                  onChanged: (value) {
                    setState(() {
                      if (grossController.text.isNotEmpty) {
                        netWeight = double.parse(value) -
                            double.parse(tareContoller.text.toString());
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
                            : null,
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
                            : null,
                      )
                    ],
                  ),
                ),
                if (_tareType == 10)
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: tareContoller,
                    onChanged: (value) {
                      setState(() {
                        if (grossController.text.isNotEmpty) {
                          netWeight =
                              double.parse(grossController.text.toString()) -
                                  double.parse(value);
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
                      GestureDetector(
                        onTap: () {
                          setState(() {
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
                          children: [Icon(Icons.add), Text("Yeni Satır")],
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
                                      DataCell(Text(element.Weight
                                          .toString())), //Extracting from Map element the value
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
                  netWeight.toString(),
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
                        quantity =
                            double.parse(quantityController.text.toString());
                        grossWeight =
                            double.parse(grossController.text.toString());
                        tareWeight =
                            double.parse(tareContoller.text.toString());
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
                          ? const Text("Gönder")
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
                      controller: detailedWeightController,
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      decoration: const InputDecoration(
                        labelText: 'Paket Ağırlığı',
                      ),
                      validator: (text) => sh.emailValidator(text),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: detailedQuantityController,
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      decoration: const InputDecoration(
                        labelText: 'Adet',
                      ),
                      validator: (text) => sh.textValidator(text),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40)),
                        onPressed: () async {
                          var p = DetailedDare(
                              Quantity:
                                  double.parse(detailedQuantityController.text),
                              Weight:
                                  double.parse(detailedWeightController.text));
                          detailedDares.add(p);

                          totalDare +=
                              double.parse(detailedWeightController.text) *
                                  double.parse(detailedQuantityController.text);

                          tareContoller.value = tareContoller.value.copyWith(
                            text: totalDare.toString(),
                            selection: TextSelection.collapsed(offset: 6),
                          );

                          if (grossController.text.isNotEmpty) {
                            netWeight =
                                double.parse(grossController.text.toString()) -
                                    totalDare;
                          }

                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                        },
                        child: Text('Güncelle'))
                  ],
                ),
              ));
        }));
  }
}
