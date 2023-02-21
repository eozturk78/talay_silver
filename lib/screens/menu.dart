import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/colors/constant_colors.dart';
import 'package:talay_mobile/screens/account/search-account.dart';
import 'package:talay_mobile/screens/currency-list/currency-list.dart';
import 'package:talay_mobile/screens/login/login.dart';
import 'package:talay_mobile/screens/search-stock/search-stock-price/search-stock-price.dart';
import 'package:talay_mobile/style-model/style-model.dart';

import '../model/header.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);
  @override
  StockDetailScreenState createState() => StockDetailScreenState();
}

class StockDetailScreenState extends State<MenuScreen> {
  bool? mobilePriceAnalysisAuth = false;
  @override
  void initState() {
    // TODO: implement initState
    getValuePermission();
    super.initState();
  }

  getValuePermission() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove("currencyId");
    await pref.remove("priceTypeId");
    setState(() {
      mobilePriceAnalysisAuth =
          pref.getString('mobilePriceAnalysisAuth') == "true" ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Menü"),
          shadowColor: null,
          elevation: 0.0,
          bottomOpacity: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
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
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                  padding: EdgeInsets.all(50),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                        ),
                        child: Text("Döviz Kurları", style: labelText),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) =>
                                      CurrencyListScreen(null))));
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                        ),
                        child: Text("Sepet", style: labelText),
                        onPressed: () async {
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          pref.setString("redirectPage", "basket");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) =>
                                      SearchAccountScreen(null))));
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                        ),
                        child: const Text("Ürün & Fiyat Sorgulama",
                            style: labelText),
                        onPressed: () async {
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          pref.setString("redirectPage", "price");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => SearchStockScreen())));
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      if (mobilePriceAnalysisAuth == true)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(60),
                          ),
                          child: Text(
                            "Ürün & Fiyat Analizi",
                            style: labelText,
                          ),
                          onPressed: () async {
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            pref.setString("redirectPage", "analyse");

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) =>
                                        SearchStockScreen())));
                          },
                        ),
                      SizedBox(
                        height: 60,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(60),
                              backgroundColor:
                                  Color.fromARGB(255, 163, 163, 163)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => LoginScreen())));
                          },
                          child: Text("Oturumu Kapat", style: labelText))
                    ],
                  )),
            )));
  }
}
