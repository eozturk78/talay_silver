import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/colors/constant_colors.dart';
import 'package:talay_mobile/model/currency.dart';
import 'package:talay_mobile/model/header.dart';
import 'package:talay_mobile/model/price-type.dart';
import 'package:talay_mobile/model/stock-detail.dart';
import 'package:talay_mobile/screens/stock/stock-detail.dart';
import 'package:talay_mobile/screens/stock/stock-price-analyse.dart';
import 'package:talay_mobile/shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:talay_mobile/apis/apis.dart';

import '../../model/file.dart';
import '../../model/stock-list.dart';
import '../../style-model/style-model.dart';
import '../stock-basket/stock-basket-detail.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({Key? key}) : super(key: key);
  @override
  StockListScreenState createState() => StockListScreenState();
}

class StockListScreenState extends State<StockListScreen> {
  bool remeberMeState = false;
  final _formKey = GlobalKey<FormState>();
  Shared sh = new Shared();
  Apis apis = Apis();
  List<StockList>? stockList;
  List<File>? stockFiles;
  List<CurrencyModel>? currencyList;
  List<PriceType>? priceTypeList;
  @override
  void initState() {
    // TODO: implement initState
    getStockDetailDetailFromLocal();
    super.initState();
  }

  getStockDetailDetailFromLocal() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      var d = null;
      String bodyString = pref.getString('stockList')!;
      if (bodyString != null) {
        var bodyJson = jsonDecode(bodyString);
        stockList =
            (bodyJson as List).map((e) => StockList.fromJson(e)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stok Listesi"),
        shadowColor: null,
        elevation: 0.0,
        bottomOpacity: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
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
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Center(
              child: stockList != null
                  ? Container(
                      child: GridView.count(
                          mainAxisSpacing: 25,
                          crossAxisSpacing: 15,
                          crossAxisCount: 3,
                          children: List.generate(stockList!.length, (index) {
                            return GestureDetector(
                              onTap: (() async {
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();

                                String code = stockList![index].StockCode;
                                Apis apis = Apis();

                                String? cid = pref.getString("currencyId");

                                if (pref.getString("redirectPage") ==
                                    "analyse") {
                                  await apis
                                      .getStockPriceAnalysis(code, cid)
                                      .then((value) {
                                    pref.setString(
                                        'stockInfo', jsonEncode(value));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const StockPriceAnalyseScreen()));
                                  });
                                } else if (pref.getString("redirectPage") ==
                                    "basket") {
                                  await apis
                                      .getStockBasketPrice(
                                          pref.getString("basketId"),
                                          stockList![index].StockId)
                                      .then(
                                    (value) {
                                      pref.setString(
                                          'stockInfo', jsonEncode(value));

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const StockBasketDetailScreen()));
                                    },
                                  );
                                } else {
                                  await apis
                                      .getStockInfo(code, cid, null)
                                      .then((value) {
                                    print(value['Records']);
                                    pref.setString(
                                        'stockInfo', jsonEncode(value));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const StockDetailScreen()));
                                  });
                                }
                              }),
                              child: Column(
                                children: [
                                  stockList![index].Files.length > 0
                                      ? Image(
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.fill,
                                          image: NetworkImage(stockList![index]
                                              .Files[0]
                                              .FileName),
                                        )
                                      : Image.asset(
                                          "assets/images/image-ph.jpg",
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.fill),
                                  stockList![index].StockName != null
                                      ? Text(stockList![index].StockName,
                                          style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis)
                                      : Text("")
                                ],
                              ),
                            );
                          })))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/no-data-found.png",
                            width: 90, height: 90, fit: BoxFit.fill),
                        Text(
                          "Stok bulunamadı",
                          style: labelText,
                        )
                      ],
                    ),
            )),
      ),
    );
  }
}
