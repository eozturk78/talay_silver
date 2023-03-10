// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/colors/constant_colors.dart';
import 'package:talay_mobile/model/basket-detail-model.dart';
import 'package:talay_mobile/screens/baskete-details/stock-tare-gross-weight.dart';
import 'package:talay_mobile/screens/menu.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../apis/apis.dart';
import '../../model/basket-row.dart';
import '../../model/currency.dart';
import '../../model/header.dart';
import '../../shared/shared.dart';
import '../../style-model/style-model.dart';
import '../../toast.dart';
import '../search-stock/search-stock-price/search-stock-price.dart';
import '../stock-basket/stock-basket-detail.dart';

class BasketDetailScreen extends StatefulWidget {
  const BasketDetailScreen(Key? key) : super(key: key);
  BasketDetailState createState() => BasketDetailState();
}

class BasketDetailState extends State<BasketDetailScreen> {
  String? accountTitle = "";

  BasketDetailModel? basketDetail;
  List<CurrencyModel>? currencyList;
  CurrencyModel? _selectedCurrency;
  String? _selectedCurrencyId;
  String? _basketDetailId;
  bool loader = true;
  Shared sh = new Shared();
  TextEditingController offerPrice = new TextEditingController();
  TextEditingController offerCarat = new TextEditingController();
  TextEditingController grossWeight = new TextEditingController();
  int _sendType = 10; // --- send to sell 10, send to wait 20
  FocusNode f1 = FocusNode();
  TextEditingController txtSearchStock = new TextEditingController();
  String? result;
  List<BasketRow>? basketDetailList;
  final controller = ScrollController();
  String? basketDetailId;
  late int deletedIndex;
  late int deleteType = 10;
  @override
  void initState() {
    // TODO: implement initState
    this.getBasketDetails();
    super.initState();
  }

  getBasketDetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      FocusScope.of(context).requestFocus(f1);
      accountTitle = pref.getString("accountTitle");
    });
    Apis apis = Apis();
    loader = true;
    apis.getBasketDetails(pref.getString("basketId")).then((value) {
      setState(() {
        loader = false;
        print(value['Records'][0]);
        basketDetail = BasketDetailModel.formJson(value['Records'][0]);

        basketDetailList = basketDetail!.BasketDetails;

        currencyList = (value['Currencies'] as List)
            .map(
              (e) => CurrencyModel.fromJson(e),
            )
            .toList();
        if (basketDetail?.CurrencyId != null) {
          _selectedCurrencyId = currencyList!
              .where(
                  (element) => element.CurrencyId == basketDetail?.CurrencyId)
              .first
              .CurrencyId;
        }
      });
    });
  }

  prepareOfferValues(index) {
    setState(() {
      double? priceValue = basketDetail?.BasketDetails[index].OfferUnitPrice ??
          basketDetail?.BasketDetails[index].UnitPrice;
      offerPrice.value = offerPrice.value.copyWith(
        text: sh.numberFormatter(priceValue).toString(),
        selection: TextSelection.collapsed(offset: 6),
      );
      /* int? caratValue = basketDetail?.BasketDetails[index].OfferCarat ??
          basketDetail?.BasketDetails[index].Carat;
      offerCarat.value = offerCarat.value.copyWith(
        text: caratValue.toString(),
        selection: TextSelection.collapsed(offset: 6),
      );*/
      _basketDetailId = basketDetail?.BasketDetails[index].BasketDetailId;
    });
    showDialog(
      context: context,
      builder: (context) => updateCaratAndUniitPrice(context),
    ).then(
      (value) => setState(
        () {},
      ),
    );
  }

  goToChangeDetailed(index) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // ignore: use_build_context_synchronously
    Navigator.pushNamed(
      context,
      "/stock-tare-gross-weight",
      arguments: basketDetail?.BasketDetails[index],
    );
  }

  _scrollToEnd() {
    controller.animateTo(
      controller.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    return Scaffold(
        appBar: AppBar(
          title: Text("#${basketDetail?.BasketNo} Sepet Detay??"),
          leading: leading(context),
          shadowColor: null,
          elevation: 0.0,
          bottomOpacity: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: headerAction(context),
        ),
        backgroundColor: splashBackGroundColor,
        body: SingleChildScrollView(
            child: Column(
          children: [
            SizedBox(
              height: 0,
              child: VisibilityDetector(
                onVisibilityChanged: (VisibilityInfo info) {},
                key: Key('visible-detector-key'),
                child: BarcodeKeyboardListener(
                  bufferDuration: Duration(milliseconds: 200),
                  onBarcodeScanned: (barcode) {
                    print(barcode);
                    if (barcode.length == 11) {
                      setState(() {
                        result = barcode;
                        getStockInfo();
                      });
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 1,
              child: TextFormField(
                controller: txtSearchStock,
                focusNode: f1,
                onChanged: (value) {
                  if (value.length > 11) {
                    result = value.toString().substring(11);
                    getStockInfo();
                  } else if (value.length == 11) {
                    result = value;
                    getStockInfo();
                  }
                  txtSearchStock.text = "";
                },
                showCursor: true,
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: '',
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                color: Colors.white,
              ),
              child: loader == true
                  ? const Center(
                      child: SpinKitCircle(
                      color: Colors.black,
                      size: 50.0,
                    ))
                  : basketDetail?.BasketDetails != null &&
                          basketDetail?.BasketDetails.length != 0
                      ? Padding(
                          padding: EdgeInsets.all(10),
                          child: ListView.builder(
                              controller: controller,
                              itemCount: basketDetailList?.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: const EdgeInsets.all(10),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "${basketDetail?.BasketDetails[index].OrderIndex.toString()}",
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Color.fromARGB(
                                                      255, 202, 8, 73)),
                                            ),
                                            Spacer(),
                                            SizedBox(
                                              width: 50,
                                              height: 30,
                                              child: MaterialButton(
                                                padding: EdgeInsets.only(
                                                    left: 0, right: 0),
                                                onPressed: () {
                                                  setState(() {
                                                    deletedIndex = index;
                                                    basketDetailId =
                                                        basketDetail
                                                            ?.BasketDetails[
                                                                index]
                                                            .BasketDetailId;
                                                  });
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        areYouSure(context),
                                                  ).then(
                                                    (value) => setState(
                                                      () {
                                                        Apis apis = Apis();
                                                        apis
                                                            .deleteBasketDetail(
                                                                basketDetailId)
                                                            .then((value) {
                                                          setState(() {
                                                            if (deleteType ==
                                                                20) {
                                                              basketDetail
                                                                  ?.BasketDetails
                                                                  .removeAt(
                                                                      deletedIndex);
                                                            }
                                                          });
                                                        });
                                                        setState(() {
                                                          FocusScope.of(context)
                                                              .requestFocus(f1);
                                                        });
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            basketDetail?.BasketDetails[index]
                                                        .StockImage !=
                                                    null
                                                ? Image(
                                                    width: 90,
                                                    height: 90,
                                                    fit: BoxFit.fill,
                                                    image: NetworkImage(
                                                        "${basketDetail?.BasketDetails[index].StockImage.toString()}"),
                                                  )
                                                : Image.asset(
                                                    "assets/images/image-ph.jpg",
                                                    width: 90,
                                                    height: 90,
                                                    fit: BoxFit.fill),
                                            SizedBox(
                                              width: 30,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 150,
                                                  child: Text(
                                                    "${basketDetail?.BasketDetails[index].StockName.toString()}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                    "${basketDetail?.BasketDetails[index].StockCode.toString()}"),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                SizedBox(
                                                  width: 150,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Text(
                                                        "Birim Fiyat",
                                                        style: tableHeader,
                                                      ),
                                                      Spacer(),
                                                      Text(sh.numberFormatter(
                                                              basketDetail
                                                                  ?.BasketDetails[
                                                                      index]
                                                                  .UnitPrice) ??
                                                          ""),
                                                    ],
                                                  ),
                                                ),
                                                if (basketDetail
                                                        ?.BasketDetails[index]
                                                        .OfferUnitPrice !=
                                                    null)
                                                  SizedBox(
                                                    width: 150,
                                                    child: Row(
                                                      children: [
                                                        const Text(
                                                          "Teklif Fiyat",
                                                          style: tableHeader,
                                                        ),
                                                        Spacer(),
                                                        Text(
                                                          sh.numberFormatter(
                                                              basketDetail
                                                                  ?.BasketDetails[
                                                                      index]
                                                                  .OfferUnitPrice),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                SizedBox(
                                                  width: 150,
                                                  child: Row(
                                                    children: [
                                                      const Text(
                                                        "Ayar",
                                                        style: tableHeader,
                                                      ),
                                                      Spacer(),
                                                      Text(
                                                        basketDetail
                                                                ?.BasketDetails[
                                                                    index]
                                                                .Carat
                                                                .toString() ??
                                                            "",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: 150,
                                                    height: 25,
                                                    child: ElevatedButton(
                                                        onPressed: () {
                                                          prepareOfferValues(
                                                              index);
                                                          setState(() {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    f1);
                                                          });
                                                        },
                                                        child: Text("Teklif"))),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          transform: Matrix4.translationValues(
                                              0.0, 0, 0.0),
                                          child: ElevatedButton(
                                            style: listButton,
                                            onPressed: () {
                                              goToChangeDetailed(index);
                                            },
                                            child: Row(
                                              children: [
                                                const Text(
                                                  "Miktar",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  basketDetail
                                                              ?.BasketDetails[
                                                                  index]
                                                              .Quantity !=
                                                          null
                                                      ? "${basketDetail?.BasketDetails[index].Quantity.toString()}"
                                                      : "0",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          transform: Matrix4.translationValues(
                                              0.0, -10, 0.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              goToChangeDetailed(index);
                                            },
                                            style: listButton,
                                            child: Row(
                                              children: [
                                                const Text(
                                                  "Br??t",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                const Spacer(),
                                                const Text("  "),
                                                Text(
                                                  sh.numberFormatter(
                                                      basketDetail
                                                          ?.BasketDetails[index]
                                                          .GrossWeight),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          transform: Matrix4.translationValues(
                                              0.0, -20, 0.0),
                                          child: ElevatedButton(
                                            style: listButton,
                                            onPressed: () {
                                              goToChangeDetailed(index);
                                            },
                                            child: Row(
                                              children: [
                                                const Text(
                                                  "Dara",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                const Spacer(),
                                                const Text("  "),
                                                Text(
                                                  sh.numberFormatter(
                                                      basketDetail
                                                          ?.BasketDetails[index]
                                                          .TareWeight),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          transform: Matrix4.translationValues(
                                              0.0, -30, 0.0),
                                          child: ElevatedButton(
                                            style: listButton,
                                            onPressed: () {
                                              goToChangeDetailed(index);
                                            },
                                            child: Row(
                                              children: [
                                                const Text(
                                                  "N. A????rl??k",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                const Spacer(),
                                                const Text("  "),
                                                Text(
                                                  sh.numberFormatter(
                                                      basketDetail
                                                          ?.BasketDetails[index]
                                                          .NetWeight),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/no-data-found.png",
                                width: 90, height: 90, fit: BoxFit.fill),
                            Text(
                              "Sepet Detay?? Yok",
                              style: labelText,
                            )
                          ],
                        ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Padding(
                padding: EdgeInsets.only(left: 30, right: 30, top: 5),
                child: Column(
                  children: [
                    Text(
                      "M????teri $accountTitle",
                      style: labelText,
                    ),
                    Row(
                      children: [
                        Text(
                          "Sepet D??vizi",
                          style: labelText,
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        DropdownButton<String>(
                          hint: const Text("D??viz se??"),
                          items: currencyList?.map((e) {
                            return DropdownMenuItem<String>(
                              value: e.CurrencyId,
                              child: Text(e.Symbol),
                            );
                          }).toList(),
                          onChanged: (String? value) async {
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            setState(() {
                              FocusScope.of(context).requestFocus(f1);
                              _selectedCurrencyId = value;
                            });
                            Apis apis = Apis();
                            apis
                                .updateBasketCurrency(
                                    pref.getString("basketId"), value)
                                .then((value) {
                              setState(() {
                                basketDetail = BasketDetailModel.formJson(
                                    value['Records'][0]);
                              });
                            });
                          },
                          value: _selectedCurrencyId,
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        pref.setString("searchProductResource", "basket");
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchStockScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                          backgroundColor: Color.fromARGB(255, 68, 68, 68)),
                      child: const Text("??r??n Ekle"),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Miktar",
                          style: tableHeader,
                        ),
                        const Spacer(),
                        Text(basketDetail?.TotalItemCount != null
                            ? "${basketDetail?.TotalItemCount.toString()}"
                            : "0"),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Br??t A????rl??k",
                          style: tableHeader,
                        ),
                        const Spacer(),
                        Text(
                            sh.numberFormatter(basketDetail?.TotalGrossWeight)),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Dara",
                          style: tableHeader,
                        ),
                        const Spacer(),
                        Text(sh.numberFormatter(basketDetail?.TotalTareWeight)),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Text(
                          "N. A????rl??k",
                          style: tableHeader,
                        ),
                        const Spacer(),
                        Text(sh.numberFormatter(basketDetail?.TotalNetWeight)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) => sentBasket(context),
                        ).then(
                          (value) => setState(
                            () {
                              setState(() {
                                FocusScope.of(context).requestFocus(f1);
                              });
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                          backgroundColor: Colors.red),
                      child: const Text("Sepeti G??nder"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )));
  }

  getStockInfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Apis apis = Apis();
    await apis.getStockBasketPrice(pref.getString("basketId"), result).then(
      (value) {
        setState(() {
          pref.setString('stockInfo', jsonEncode(value));
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StockBasketDetailScreen()))
              .then((value) {
            setState(() {
              FocusScope.of(context).requestFocus(f1);
            });
          });
        });
      },
    );
  }

  Widget updateCaratAndUniitPrice(BuildContext context) {
    return AlertDialog(
        title: Text("Teklif Tutarlar??n?? Gir"),
        content: StatefulBuilder(builder: (BuildContext context, setState) {
          return FittedBox(
              fit: BoxFit.none,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  children: [
                    TextFormField(
                      controller: offerPrice,
                      obscureText: false,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Birim Fiyat',
                      ),
                      validator: (text) => sh.emailValidator(text),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40)),
                        onPressed: () async {
                          Apis apis = Apis();
                          apis
                              .setBasketDetailOfferValues(_basketDetailId,
                                  offerCarat.text, offerPrice.text)
                              .then((value) {
                            setState(() {
                              basketDetail = BasketDetailModel.formJson(
                                  value['Records'][0]);
                            });
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          });
                        },
                        child: Text('G??ncelle'))
                  ],
                ),
              ));
        }));
  }

  Widget sentBasket(BuildContext context) {
    return AlertDialog(
        title: Text("Sepeti G??nder"),
        content: StatefulBuilder(builder: (BuildContext context, setState) {
          return FittedBox(
              fit: BoxFit.none,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  children: [
                    TextFormField(
                      controller: grossWeight,
                      obscureText: false,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Sepet Br??t A????rl??????',
                      ),
                      validator: (text) => sh.textValidator(text),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Sepet hesaplanacak m???",
                      style: labelText,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _sendType = 10;
                            });
                          },
                          child: const Text("Evet"),
                          style: _sendType == 10
                              ? const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll<Color>(
                                          Colors.red),
                                )
                              : const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll<Color>(
                                          Color.fromARGB(255, 83, 83, 83)),
                                ),
                        ),
                        const Text(" "),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _sendType = 20;
                            });
                          },
                          child: const Text("Hay??r"),
                          style: _sendType == 20
                              ? const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll<Color>(
                                          Colors.red),
                                )
                              : const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll<Color>(
                                          Color.fromARGB(255, 83, 83, 83)),
                                ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40)),
                      onPressed: () async {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        Apis apis = Apis();
                        double? grossWeightValue;
                        if (grossWeight.text.isNotEmpty) {
                          grossWeightValue = double.parse(
                              sh.prePareNumberForRequest(grossWeight.text));
                        }
                        apis
                            .sendBasketToWaiting(pref.getString("basketId"),
                                _sendType == 20, grossWeightValue)
                            .then((value) {
                          showToast("Sepet ba??ar??yla g??nderildi");
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MenuScreen()));
                        });
                      },
                      child: Text('G??nder'),
                    ),
                  ],
                ),
              ));
        }));
  }

  Widget areYouSure(BuildContext context) {
    return AlertDialog(
        title: Text("Devam stedi??inizden emin misiniz?"),
        content: StatefulBuilder(builder: (BuildContext context, setState) {
          return FittedBox(
              fit: BoxFit.none,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        deleteType = 20;
                        Navigator.of(context, rootNavigator: false)
                            .pop('dialog');
                      },
                      child: Text('Evet'),
                    ),
                    Text("  "),
                    ElevatedButton(
                      onPressed: () {
                        deleteType = 10;
                        Navigator.of(context, rootNavigator: false)
                            .pop('dialog');
                      },
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            Color.fromARGB(255, 133, 132, 132)),
                      ),
                      child: Text('Hay??r'),
                    ),
                  ],
                ),
              ));
        }));
  }
}
