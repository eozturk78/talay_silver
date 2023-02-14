import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:talay_mobile/apis/apis.dart';
import 'package:talay_mobile/model/exchange-rate.dart';
import 'package:talay_mobile/style-model/style-model.dart';

import '../../colors/constant_colors.dart';
import '../../model/currency.dart';
import '../../model/header.dart';

class CurrencyListScreen extends StatefulWidget {
  const CurrencyListScreen(Key? key) : super(key: key);
  CurrencyListState createState() => CurrencyListState();
}

class CurrencyListState extends State<CurrencyListScreen> {
  List<ExchangeRate>? listCurrency;

  @override
  void initState() {
    // TODO: implement initState
    getCurrencyList();
    super.initState();
  }

  getCurrencyList() async {
    Apis apis = new Apis();
    apis.getCurrencyList().then((value) {
      setState(() {
        listCurrency =
            (value as List).map((e) => ExchangeRate.fromJson(e)).toList();
      });
      print(listCurrency);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Döviz Listesi"),
        leading: leadingWithBack(context),
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
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: listCurrency != null
              ? ListView.builder(
                  itemCount: listCurrency?.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 1),
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                "${listCurrency![index].CurrencyName} (${listCurrency![index].Symbol})",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
                              child: Row(
                                children: [
                                  Text(
                                    "Alış",
                                    style: setText,
                                  ),
                                  Spacer(),
                                  Text(
                                    "Satış",
                                    style: setText,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
                              child: Row(
                                children: [
                                  Text(
                                    listCurrency![index].Buying.toString(),
                                    style: labelText,
                                  ),
                                  const Spacer(),
                                  Text(
                                    listCurrency![index].Selling.toString(),
                                    style: labelText,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
                              child: Row(
                                children: [
                                  Text(
                                    "Alış USD",
                                    style: setText,
                                  ),
                                  Spacer(),
                                  Text(
                                    "Satış USD",
                                    style: setText,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
                              child: Row(
                                children: [
                                  Text(
                                    listCurrency![index]
                                        .BuyingRateCrossRate
                                        .toString(),
                                    style: labelText,
                                  ),
                                  const Spacer(),
                                  Text(
                                    listCurrency![index]
                                        .SellingRateCrossRate
                                        .toString(),
                                    style: labelText,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  })
              : SpinKitCircle(
                  color: Colors.black,
                  size: 50.0,
                ),
        ),
      ),
    );
  }
}
