import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/colors/constant_colors.dart';
import 'package:talay_mobile/model/basket-price.dart';
import 'package:talay_mobile/model/currency.dart';
import 'package:talay_mobile/model/header.dart';
import 'package:talay_mobile/model/offer.dart';
import 'package:talay_mobile/model/price-type.dart';
import 'package:talay_mobile/model/stock-basket-detail.dart';
import 'package:talay_mobile/model/stock-detail.dart';
import 'package:talay_mobile/model/stock-variants.dart';
import 'package:talay_mobile/screens/baskete-details/basket-detail.dart';
import 'package:talay_mobile/screens/stock-varyants/stock-varyants.dart';
import 'package:talay_mobile/shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:talay_mobile/apis/apis.dart';

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
  @override
  void initState() {
    // TODO: implement initState
    getStockDetailDetailFromLocal();
    super.initState();
  }

  getStockDetailDetailFromLocal() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String bodyString = pref.getString('stockInfo')!;
    if (bodyString != null) {
      setState(() {
        var bodyJson = jsonDecode(bodyString);
        stockDetail = StockBasketDetail.fromJson(bodyJson['Records'][0]);
        basketPrice = stockDetail?.Prices
            .where((element) => element.SellingType == 25)
            .first;
        _selectedSellingPrice = basketPrice?.SellingType;
        sellingTypeList = stockDetail?.Prices;
        String? cid = stockDetail!.Currency.CurrencyId;
        if (pref.getString('currencyId') != null) {
          cid = pref.getString("currencyId");
        }
      });
    }
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
                    padding: EdgeInsets.all(30),
                    child: Center(
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
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            offerPrice.value =
                                                offerPrice.value.copyWith(
                                              text:
                                                  basketPrice?.Price.toString(),
                                              selection:
                                                  TextSelection.collapsed(
                                                      offset: 6),
                                            );
                                            offerCarat.value =
                                                offerCarat.value.copyWith(
                                              text:
                                                  basketPrice?.Carat.toString(),
                                              selection:
                                                  TextSelection.collapsed(
                                                      offset: 6),
                                            );
                                          });
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                updateCaratAndUniitPrice(
                                                    context),
                                          ).then(
                                            (value) => setState(
                                              () {},
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${basketPrice?.Price} ${stockDetail!.Currency.Symbol}',
                                              style: priceText,
                                            ),
                                            offerPrice.text.isNotEmpty &&
                                                    offerPrice.text !=
                                                        basketPrice!.Price
                                                            .toString()
                                                ? const Icon(
                                                    Icons.discount_rounded,
                                                    color: Color.fromARGB(
                                                        255, 0, 175, 6),
                                                  )
                                                : const Icon(
                                                    Icons.discount_rounded,
                                                  ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (offerPrice.text.isEmpty)
                                              offerPrice.value =
                                                  offerPrice.value.copyWith(
                                                text: basketPrice?.Price
                                                    .toString(),
                                                selection:
                                                    TextSelection.collapsed(
                                                        offset: 6),
                                              );
                                            if (offerCarat.text.isEmpty)
                                              offerCarat.value =
                                                  offerCarat.value.copyWith(
                                                text: basketPrice?.Carat
                                                    .toString(),
                                                selection:
                                                    TextSelection.collapsed(
                                                        offset: 6),
                                              );
                                          });
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                updateCaratAndUniitPrice(
                                                    context),
                                          ).then(
                                            (value) => setState(
                                              () {},
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Ayar",
                                              style: setText,
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              basketPrice!.Carat.toString(),
                                              style: setText,
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            offerCarat.text.isNotEmpty &&
                                                    offerCarat.text !=
                                                        basketPrice!.Carat
                                                            .toString()
                                                ? const Icon(
                                                    Icons.discount_rounded,
                                                    color: Color.fromARGB(
                                                        255, 0, 175, 6),
                                                  )
                                                : const Icon(
                                                    Icons.discount_rounded,
                                                  ),
                                          ],
                                        ),
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
                                            image: NetworkImage(stockDetail!
                                                .Files[index].FileName),
                                          );
                                        })),
                                  ),
                              ],
                            )
                          : Text("Veri Bulunamadi"),
                    )),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: ElevatedButton(
                        onPressed: () async {
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
                              offerPriceValue = double.parse(offerPrice.text);
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
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                            backgroundColor: Colors.red),
                        child: const Text("Sepete Ekle"),
                      ),
                    ),
                    if (stockDetail!.StockVariants?.isNotEmpty != false)
                      Padding(
                        padding: EdgeInsets.all(15),
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
                              p.offerPrice = double.parse(offerPrice.text);
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
                          child: const Text("Stock Varyantları"),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ));
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
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      decoration: const InputDecoration(
                        labelText: 'Birim Fiyat',
                      ),
                      validator: (text) => sh.emailValidator(text),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: offerCarat,
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ayar',
                      ),
                      validator: (text) => sh.textValidator(text),
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