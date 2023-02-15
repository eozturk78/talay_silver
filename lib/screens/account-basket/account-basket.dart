import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/apis/apis.dart';
import 'package:talay_mobile/model/account.dart';
import 'package:talay_mobile/model/basket.dart';
import 'package:talay_mobile/screens/baskete-details/basket-detail.dart';
import 'package:talay_mobile/screens/search-stock/search-stock-price/search-stock-price.dart';
import 'package:talay_mobile/style-model/style-model.dart';
import 'package:talay_mobile/toast.dart';

import '../../colors/constant_colors.dart';
import '../../model/header.dart';

class AccountBasketScreen extends StatefulWidget {
  const AccountBasketScreen(Key? key) : super(key: key);
  AccountBasketState createState() => AccountBasketState();
}

class AccountBasketState extends State<AccountBasketScreen> {
  String? accountTitle = "";
  List<Basket>? basketList;
  bool? loader = true;
  @override
  void initState() {
    // TODO: implement initState
    getAccountBasket();
    super.initState();
  }

  getAccountBasket() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Apis api = Apis();
    loader = true;
    api.getCustomerBasketList(pref.getString("accountId")).then((value) {
      setState(() {
        loader = false;
        if (value != null) {
          basketList = (value as List).map((e) => Basket.formJson(e)).toList();
        }
      });
    });
    setState(() {
      accountTitle = pref.getString("accountTitle");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Cari Sepetleri"),
          leading: leadingWithBack(context),
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
                child: loader == false
                    ? Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          child: basketList != null && !basketList!.isEmpty
                              ? ListView.builder(
                                  itemCount: basketList!.length,
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                        onTap: () async {
                                          if (basketList![index].AllowUse) {
                                            SharedPreferences pref =
                                                await SharedPreferences
                                                    .getInstance();
                                            pref.setString("basketId",
                                                basketList![index].BasketId);

                                            // ignore: use_build_context_synchronously
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const BasketDetailScreen(
                                                        null),
                                              ),
                                            );
                                          } else {
                                            showToast(
                                                "Bu sepeti kullanamazsınız");
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color:
                                                basketList![index].AllowUse ==
                                                        true
                                                    ? Colors.white
                                                    : Color.fromARGB(
                                                        255, 224, 224, 224),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: const Offset(0, 1),
                                                blurRadius: 5,
                                                color: Colors.black
                                                    .withOpacity(0.3),
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
                                                      "#",
                                                      style: tableHeader,
                                                    ),
                                                    Text(basketList![index]
                                                        .BasketNo),
                                                    Text("    "),
                                                    Text(basketList![index]
                                                        .BasketStatusDesc
                                                        .toString()),
                                                    Spacer(),
                                                    Text(basketList![index]
                                                        .UserTitle)
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Son Paket No",
                                                      style: tableHeader,
                                                    ),
                                                    Text(" "),
                                                    Text(basketList![index]
                                                        .LastItemIndex
                                                        .toString()),
                                                    Spacer(),
                                                    Text(
                                                      "Sepet Satırları",
                                                      style: tableHeader,
                                                    ),
                                                    Text("  "),
                                                    Text(basketList![index]
                                                        .TotalItemCount
                                                        .toString()),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Brüt",
                                                      style: tableHeader,
                                                    ),
                                                    Spacer(),
                                                    Text("  "),
                                                    Text(basketList![index]
                                                                .TotalGrossWeight !=
                                                            null
                                                        ? basketList![index]
                                                            .TotalGrossWeight
                                                            .toString()
                                                        : "0"),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Dara",
                                                      style: tableHeader,
                                                    ),
                                                    Spacer(),
                                                    Text("  "),
                                                    Text(basketList![index]
                                                                .TotalTareWeight !=
                                                            null
                                                        ? basketList![index]
                                                            .TotalTareWeight
                                                            .toString()
                                                        : "0"),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "N. Ağırlık",
                                                      style: tableHeader,
                                                    ),
                                                    Spacer(),
                                                    Text("  "),
                                                    Text(basketList![index]
                                                                .TotalNetWeight !=
                                                            null
                                                        ? basketList![index]
                                                            .TotalNetWeight
                                                            .toString()
                                                        : "0"),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ));
                                  })
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                        "assets/images/no-data-found.png",
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.fill),
                                    Text(
                                      "Müşterinin sepeti yok",
                                      style: labelText,
                                    )
                                  ],
                                ),
                        ),
                      )
                    : Center(
                        child: SpinKitCircle(
                          color: Colors.black,
                          size: 50.0,
                        ),
                      ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  children: [
                    Text(
                      "Müşteri ${accountTitle}",
                      style: labelText,
                    ),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          pref.setString("searchProductResource", "basket");

                          Apis api = Apis();
                          api
                              .createBasket(pref.getString("accountId"))
                              .then((value) {
                            print(value);
                            pref.setString("basketId", value[0]['BasketId']);
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchStockScreen()));
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                            backgroundColor: Colors.red),
                        child: const Text("Yeni Sepet Oluştur"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
