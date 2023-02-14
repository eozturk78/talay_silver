import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/colors/constant_colors.dart';
import 'package:talay_mobile/model/currency.dart';
import 'package:talay_mobile/model/header.dart';
import 'package:talay_mobile/model/price-type.dart';
import 'package:talay_mobile/model/stock-detail.dart';
import 'package:talay_mobile/shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:talay_mobile/apis/apis.dart';

import '../../model/file.dart';
import '../../style-model/style-model.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({Key? key}) : super(key: key);
  @override
  StockDetailScreenState createState() => StockDetailScreenState();
}

class StockDetailScreenState extends State<StockDetailScreen> {
  bool remeberMeState = false;
  final _formKey = GlobalKey<FormState>();
  Shared sh = new Shared();
  Apis apis = Apis();
  StockDetail? stockDetail;
  List<File>? stockFiles;
  List<CurrencyModel>? currencyList;
  List<PriceType>? priceTypeList;
  CurrencyModel? _selectedCurrency;
  PriceType? _selectedPriceType;
  String? _selectedCurrencyId;
  @override
  void initState() {
    // TODO: implement initState
    getStockDetailDetailFromLocal();
    super.initState();
  }

  getStockDetailDetailFromLocal() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var d = null;
    String bodyString = pref.getString('stockInfo')!;
    if (bodyString != null) {
      setState(() {
        var bodyJson = jsonDecode(bodyString);
        stockDetail = StockDetail.fromJson(bodyJson['Records'][0]);

        currencyList = (bodyJson['Currencies'] as List)
            .map(
              (e) => CurrencyModel.fromJson(e),
            )
            .toList();

        String? cid = stockDetail!.Currency.CurrencyId;
        if (pref.getString('currencyId') != null) {
          cid = pref.getString("currencyId");
        }
        _selectedCurrencyId = currencyList
            ?.where((element) => element.CurrencyId == cid)
            .first
            .CurrencyId;

        priceTypeList = (bodyJson['PriceTypes'] as List)
            .map(
              (e) => PriceType.fromJson(e),
            )
            .toList();
      });
    }
  }

  onChangePriceByCurrencyPriceType() async {
    Apis apis = Apis();
    await apis
        .getStockInfo(stockDetail!.StockCode, _selectedCurrency?.CurrencyId,
            _selectedPriceType?.PriceTypeId)
        .then(
      (value) {
        setState(
          () {
            stockDetail = StockDetail.fromJson(value['Records'][0]);
          },
        );
      },
    );
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
              child: stockDetail != null
                  ? Column(
                      children: [
                        Center(
                          child: Text(
                            stockDetail!.StockName,
                            style: headerTitleText,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            DropdownButton<String>(
                              hint: const Text("Döviz seç"),
                              items: currencyList?.map((e) {
                                return DropdownMenuItem<String>(
                                  value: e.CurrencyId,
                                  child: Text(e.Symbol),
                                );
                              }).toList(),
                              onChanged: (String? value) async {
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                setState(
                                  () {
                                    if (value != null) {
                                      pref.setString("currencyId", value);
                                    }
                                    _selectedCurrency = currencyList
                                        ?.where((element) =>
                                            element.CurrencyId == value)
                                        .first;
                                    _selectedCurrencyId = value;
                                    onChangePriceByCurrencyPriceType();
                                  },
                                );
                              },
                              value: _selectedCurrencyId,
                            ),
                            Spacer(),
                            DropdownButton<PriceType>(
                              hint: Text("Fiyat tipi seç"),
                              items: priceTypeList?.map((e) {
                                return DropdownMenuItem<PriceType>(
                                  value: e,
                                  child: Text(e.PriceTypeName),
                                );
                              }).toList(),
                              onChanged: (PriceType? e) {
                                setState(
                                  () {
                                    _selectedPriceType = e;
                                    onChangePriceByCurrencyPriceType();
                                  },
                                );
                              },
                              value: _selectedPriceType,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 60),
                          child: Column(
                            children: [
                              Text(
                                stockDetail!.Price.toString() +
                                    ' ' +
                                    stockDetail!.Currency.Symbol,
                                style: priceText,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              if (stockDetail!.WorkmanshipPriceAuth)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "İşçilik Tutarı",
                                      style: setText,
                                      textAlign: TextAlign.center,
                                    ),
                                    Spacer(),
                                    Text(
                                      stockDetail!.WorkmanshipPrice.toString(),
                                      style: labelText,
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              SizedBox(
                                height: 5,
                              ),
                              if (stockDetail!.MetalGRPriceAuth)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Maden Tutarı",
                                      style: setText,
                                      textAlign: TextAlign.center,
                                    ),
                                    Spacer(),
                                    Text(
                                      stockDetail!.MetalGRPrice.toString(),
                                      style: labelText,
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Ayar",
                                    style: setText,
                                    textAlign: TextAlign.center,
                                  ),
                                  Spacer(),
                                  Text(
                                    stockDetail!.Carat.toString(),
                                    style: labelText,
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20,
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
                        if (stockDetail!.StockVariants != null &&
                            stockDetail!.StockVariants?.length != 0)
                          Text("Stock Varyantları"),
                        if (stockDetail!.StockVariants != null)
                          Expanded(
                            child: GridView.count(
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              crossAxisCount: 3,
                              children: List.generate(
                                stockDetail!.StockVariants!.length,
                                (index) {
                                  return Column(
                                    children: [
                                      stockDetail!.StockVariants![index]
                                                  .Files !=
                                              null
                                          ? Image(
                                              width: 90,
                                              height: 90,
                                              fit: BoxFit.fill,
                                              image: NetworkImage(
                                                stockDetail!
                                                    .StockVariants![index]
                                                    .Files![0]
                                                    .FileName,
                                              ),
                                            )
                                          : Image.asset(
                                              "assets/images/image-ph.jpg",
                                              width: 90,
                                              height: 90,
                                              fit: BoxFit.fill,
                                            ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        stockDetail!.StockVariants![index]
                                            .StockVariantName,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          )
                      ],
                    )
                  : Text("Veri Bulunamadi"),
            )),
      ),
    );
  }
}
