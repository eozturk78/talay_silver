import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/colors/constant_colors.dart';
import 'package:talay_mobile/model/basket-price.dart';
import 'package:talay_mobile/model/currency.dart';
import 'package:talay_mobile/model/header.dart';
import 'package:talay_mobile/model/offer.dart';
import 'package:talay_mobile/model/stock-basket-detail.dart';
import 'package:talay_mobile/model/stock-variants.dart';
import 'package:talay_mobile/screens/baskete-details/basket-detail.dart';
import 'package:talay_mobile/shared/shared.dart';
import 'package:talay_mobile/apis/apis.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../model/file.dart';
import '../../style-model/style-model.dart';

class StockBasketDetailScreen extends StatefulWidget {
  const StockBasketDetailScreen({Key? key}) : super(key: key);
  @override
  StockBasketDetailScreenState createState() => StockBasketDetailScreenState();
}

class StockBasketDetailScreenState extends State<StockBasketDetailScreen> {
  bool remeberMeState = false;
  final _formKey = GlobalKey<FormState>();
  Shared sh = new Shared();
  TextEditingController offerPrice = new TextEditingController();
  TextEditingController offerCarat = new TextEditingController();
  Apis apis = Apis();
  StockBasketDetail? stockDetail;
  List<File>? stockFiles;
  List<CurrencyModel>? currencyList;
  List<BasketPriceModel>? sellingTypeList;
  int? _selectedSellingPrice;
  BasketPriceModel? basketPrice;
  StockVariant? _selectedStockVariant;
  FocusNode f1 = FocusNode();
  TextEditingController txtSearchStock = new TextEditingController();
  String? result;
  @override
  void initState() {
    // TODO: implement initState
    getStockDetailDetailFromLocal();
    super.initState();
  }

  getStockDetailDetailFromLocal() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String bodyString = pref.getString('stockInfo')!;
    setState(() {
      var bodyJson = jsonDecode(bodyString);
      stockDetail = StockBasketDetail.fromJson(bodyJson['Records'][0]);
      offerCarat.clear();
      offerPrice.clear();
      if (stockDetail?.Prices
              .where((element) => element.SellingType == 25)
              .length !=
          0) {
        basketPrice = stockDetail?.Prices
            .where((element) => element.SellingType == 25)
            .first;
      } else {
        basketPrice ??= stockDetail?.Prices[0];
      }
      _selectedSellingPrice = basketPrice?.SellingType;
      sellingTypeList = stockDetail?.Prices;
      String? cid = stockDetail!.Currency.CurrencyId;
      if (pref.getString('currencyId') != null) {
        cid = pref.getString("currencyId");
      }
      setState(() {
        FocusScope.of(context).requestFocus(f1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Stok Detayı"),
          shadowColor: null,
          elevation: 0.0,
          bottomOpacity: 0,
          centerTitle: true,
          automaticallyImplyLeading: true,
          actions: headerAction(context),
        ),
        backgroundColor: splashBackGroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: stockDetail != null
                      ? Column(
                          children: [
                            Center(
                              child: Text(
                                stockDetail!.StockName,
                                style: headerTitleText,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 60),
                              child: Column(
                                children: [
                                  Text(
                                    '${sh.numberFormatter(basketPrice?.Price)} ${stockDetail!.Currency.Symbol}',
                                    style: priceText,
                                  ),
                                  if (offerPrice.text.isNotEmpty)
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Teklif Fiyatı ${offerPrice.text}",
                                          style: offerText,
                                        ),
                                      ],
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Ayar ${basketPrice?.Carat}",
                                    style: setText,
                                    textAlign: TextAlign.center,
                                  ),
                                  if (offerCarat.text.isNotEmpty)
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Teklif Ayar ${offerCarat.text}",
                                          style: offerText,
                                        ),
                                      ],
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                updateCaratAndUniitPrice(
                                                    context),
                                          ).then(
                                            (value) => setState(
                                              () {
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                            ),
                                          );
                                        },
                                        child: Text("Teklif")),
                                  ),
                                ],
                              ),
                            ),
                            if (stockDetail!.Files.isEmpty == false)
                              Expanded(
                                child: GridView.count(
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20,
                                    crossAxisCount: 3,
                                    children: List.generate(
                                        stockDetail!.Files.length, (index) {
                                      return Image(
                                        width: 250,
                                        height: 250,
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                            stockDetail!.Files[index].FileName),
                                      );
                                    })),
                              ),
                          ],
                        )
                      : Text("Veri Bulunamadi"),
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  children: [
                    SizedBox(
                      height: 1,
                      child: VisibilityDetector(
                        onVisibilityChanged: (VisibilityInfo info) {},
                        key: Key('visible-detector-key'),
                        child: BarcodeKeyboardListener(
                          bufferDuration: Duration(milliseconds: 200),
                          onBarcodeScanned: (barcode) {
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
                        showCursor: false,
                        keyboardType: TextInputType.none,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: '',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 15, left: 15),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (stockDetail != null) {
                            if (stockDetail!.StockVariants != null &&
                                stockDetail!.StockVariants?.length != 0 &&
                                _selectedStockVariant == null) {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    showStockVariantProblem(context),
                              ).then(
                                (value) => setState(
                                  () {},
                                ),
                              );
                            } else {
                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                              pref.setString("searchProductResource", "basket");
                              int? offerCaratValue;
                              if (offerCarat.text.isNotEmpty) {
                                offerCaratValue = int.parse(offerCarat.text);
                              }
                              double? offerPriceValue;
                              if (offerPrice.text.isNotEmpty) {
                                offerPriceValue = double.parse(sh
                                    .prePareNumberForRequest(offerPrice.text));
                              }
                              Apis api = Apis();
                              api
                                  .addToBasket(
                                      pref.getString("basketId"),
                                      stockDetail?.StockId,
                                      _selectedStockVariant?.StockVariantId,
                                      offerCaratValue,
                                      offerPriceValue)
                                  .then((value) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BasketDetailScreen(null)));
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                            backgroundColor: Colors.red),
                        child: const Text("Sepete Ekle"),
                      ),
                    ),
                    if (stockDetail != null &&
                        stockDetail!.StockVariants?.isNotEmpty != false)
                      Padding(
                        padding: EdgeInsets.only(right: 15, left: 15),
                        child: ElevatedButton(
                          onPressed: () async {
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            dynamic list =
                                (stockDetail?.StockVariants as dynamic);

                            OfferValues p = OfferValues();

                            if (offerCarat.text.isNotEmpty &&
                                offerCarat.text !=
                                    basketPrice?.Carat.toString()) {
                              p.offerCarat = int.parse(offerCarat.text);
                            }
                            if (offerPrice.text.isNotEmpty &&
                                offerPrice.text !=
                                    basketPrice?.Price.toString()) {
                              p.offerPrice = double.parse(
                                  sh.prePareNumberForRequest(offerPrice.text));
                            }

                            // ignore: use_build_context_synchronously
                            Navigator.pushNamed(
                              context,
                              "/stock-varyants",
                              arguments: p,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                              backgroundColor: Color.fromARGB(255, 63, 63, 63)),
                          child: const Text("Stok Varyantları"),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  getStockInfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
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

  Widget showStockVariantProblem(BuildContext context) {
    return AlertDialog(
        title: Text("Stok Varyant"),
        content: StatefulBuilder(builder: (BuildContext context, setState) {
          return FittedBox(
              fit: BoxFit.none,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text("Lütfen bir stock varyantı seçin"),
              ));
        }));
  }

  Widget updateCaratAndUniitPrice(BuildContext context) {
    return AlertDialog(
        title: Text("Teklif Tutarlarını Gir"),
        content: StatefulBuilder(builder: (BuildContext context, setState) {
          return FittedBox(
              fit: BoxFit.none,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  children: [
                    TextFormField(
                      controller: offerPrice,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9,]')),
                      ],
                      obscureText: false,
                      decoration: const InputDecoration(
                        labelText: 'Birim Fiyat',
                      ),
                      validator: (text) => sh.emailValidator(text),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40)),
                        onPressed: () async {
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
