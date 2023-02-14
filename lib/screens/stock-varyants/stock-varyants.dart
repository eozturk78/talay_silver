import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/colors/constant_colors.dart';
import 'package:talay_mobile/model/currency.dart';
import 'package:talay_mobile/model/header.dart';
import 'package:talay_mobile/model/offer.dart';
import 'package:talay_mobile/model/price-type.dart';
import 'package:talay_mobile/model/stock-basket-detail.dart';
import 'package:talay_mobile/model/stock-detail.dart';
import 'package:talay_mobile/screens/stock/stock-detail.dart';
import 'package:talay_mobile/screens/stock/stock-price-analyse.dart';
import 'package:talay_mobile/shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:talay_mobile/apis/apis.dart';

import '../../model/file.dart';
import '../../model/stock-list.dart';
import '../../model/stock-variants.dart';
import '../../style-model/style-model.dart';
import '../baskete-details/basket-detail.dart';
import '../stock-basket/stock-basket-detail.dart';

class StockVariantsScreen extends StatefulWidget {
  const StockVariantsScreen({Key? key}) : super(key: key);
  @override
  StockVariantsScreenState createState() => StockVariantsScreenState();
}

class StockVariantsScreenState extends State<StockVariantsScreen> {
  bool remeberMeState = false;
  final _formKey = GlobalKey<FormState>();
  Shared sh = new Shared();
  Apis apis = Apis();
  StockBasketDetail? stockDetail;
  List<StockVariant>? stockVariants;
  List<File>? stockFiles;
  List<CurrencyModel>? currencyList;
  List<PriceType>? priceTypeList;
  StockVariant? _selectedStockVariant;
  OfferValues? priceDetail;
  @override
  void initState() {
    // TODO: implement initState
    getStockDetailDetailFromLocal();
    super.initState();
  }

  getStockDetailDetailFromLocal() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // ignore: use_build_context_synchronously
    priceDetail = ModalRoute.of(context)!.settings.arguments as OfferValues;

    print(priceDetail);

    setState(() {
      var d = null;
      String bodyString = pref.getString('stockInfo')!;
      if (bodyString != null) {
        var bodyJson = jsonDecode(bodyString);
        stockDetail = StockBasketDetail.fromJson(bodyJson['Records'][0]);
        stockVariants = stockDetail?.StockVariants;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stok Varyantları"),
        shadowColor: null,
        elevation: 0.0,
        bottomOpacity: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: headerAction(context),
      ),
      backgroundColor: splashBackGroundColor,
      body: SingleChildScrollView(
          child: Column(children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.05,
          child: Center(
            child: Text(
              stockDetail!.StockName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.690,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: stockVariants != null
                ? GridView.count(
                    mainAxisSpacing: 25,
                    crossAxisSpacing: 15,
                    crossAxisCount: 3,
                    children: List.generate(stockVariants!.length, (index) {
                      return GestureDetector(
                        onTap: (() async {
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();

                          String code = stockVariants![index].StockVariantCode;
                          setState(() {
                            if (_selectedStockVariant?.StockVariantId !=
                                stockVariants![index].StockVariantId)
                              _selectedStockVariant = stockVariants![index];
                            else {
                              _selectedStockVariant = null;
                            }
                          });
                        }),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: _selectedStockVariant
                                              ?.StockVariantId ==
                                          stockVariants![index].StockVariantId
                                      ? Border.all(
                                          color: const Color.fromARGB(
                                              255, 0, 134, 69),
                                          width: 1)
                                      : null),
                              child: Column(
                                children: [
                                  stockVariants![index].Files != null &&
                                          stockVariants![index].Files?.length !=
                                              0
                                      ? Image(
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.fill,
                                          image: NetworkImage(
                                              stockVariants![index]
                                                  .Files![0]
                                                  .FileName),
                                        )
                                      : Image.asset(
                                          "assets/images/image-ph.jpg",
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.fill),
                                  Text(stockVariants![index].StockVariantName,
                                      style: _selectedStockVariant
                                                  ?.StockVariantId !=
                                              stockVariants![index]
                                                  .StockVariantId
                                          ? const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)
                                          : const TextStyle(
                                              fontSize: 12,
                                              color: Color.fromARGB(
                                                  255, 0, 134, 69),
                                              fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/no-data-found.png",
                          width: 90, height: 90, fit: BoxFit.fill),
                      const Text(
                        "Stok bulunamadı",
                        style: labelText,
                      )
                    ],
                  ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(color: Colors.white),
          height: MediaQuery.of(context).size.height * 0.190,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: ElevatedButton(
                  onPressed: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    int? offerCarat;
                    double? offerPrice;
                    if (priceDetail != "") {
                      offerCarat = priceDetail?.offerCarat;
                    }
                    if (priceDetail != null) {
                      offerPrice = priceDetail?.offerPrice;
                    }
                    Apis api = Apis();
                    api
                        .addToBasket(
                            pref.getString("basketId"),
                            stockDetail?.StockId,
                            _selectedStockVariant?.StockVariantId,
                            offerCarat,
                            offerPrice)
                        .then((value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const BasketDetailScreen(null)));
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      backgroundColor: Colors.red),
                  child: const Text("Sepete Ekle"),
                ),
              ),
            ],
          ),
        ),
      ])),
    );
  }
}
