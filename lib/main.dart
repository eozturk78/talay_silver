import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/apis/apis.dart';
import 'package:talay_mobile/colors/constant_colors.dart';
import 'package:talay_mobile/screens/account-basket/account-basket.dart';
import 'package:talay_mobile/screens/account/new-account.dart';
import 'package:talay_mobile/screens/account/search-account.dart';
import 'package:talay_mobile/screens/baskete-details/stock-tare-gross-weight.dart';
import 'package:talay_mobile/screens/currency-list/currency-list.dart';
import 'package:talay_mobile/screens/login/login.dart';
import 'package:talay_mobile/screens/menu.dart';
import 'package:talay_mobile/screens/search-stock/search-stock-detailed/search-stock-detailed.dart';
import 'package:talay_mobile/screens/search-stock/search-stock-price/search-stock-price.dart';
import 'package:talay_mobile/screens/stock-varyants/stock-varyants.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const MyHomePage(title: ''),
        "/home": (context) => const MyHomePage(title: ''),
        "/new-account": (context) => const NewAccountScreen(null),
        "/menu": (context) => const MenuScreen(),
        "/currency-list": (context) => const CurrencyListScreen(null),
        "/login": (context) => const LoginScreen(),
        "/search-stock-price": (context) => SearchStockScreen(),
        "/search-account": (context) => const SearchAccountScreen(null),
        "/stock-varyants": (context) => const StockVariantsScreen(),
        "/search-stock-detailed": (context) =>
            const SearchStockDetailedScreen(),
        "/account-basket": (context) => const AccountBasketScreen(null),
        "/stock-tare-gross-weight": (context) =>
            const StockTareGrossWeightScreen(null)
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      (() {
        redirectToMain();
      }),
    );
  }

  redirectToMain() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString('token') != null) {
      Apis apis = new Apis();
      apis.renewToken(pref.getString('token')).then((value) {
        if (value != null) {
          pref.setString('token', value['Token']);
          if (value['MobilePriceAnalysisAuth'] != null)
            pref.setString('mobilePriceAnalysisAuth',
                value['MobilePriceAnalysisAuth'].toString());
          Navigator.of(context).pushReplacementNamed("/menu");
        } else {
          Navigator.of(context).pushReplacementNamed("/login");
        }
      }).onError((error, stackTrace) {
        Navigator.of(context).pushReplacementNamed("/login");
      });
    } else {
      Navigator.of(context).pushReplacementNamed("/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: splashBackGroundColor,
        body: Center(
          child: Image.asset("assets/images/talay_logo.png"),
        ),
      ),
    );
  }
}
