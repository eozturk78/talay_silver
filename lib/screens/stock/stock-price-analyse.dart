import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/colors/constant_colors.dart';
import 'package:talay_mobile/model/currency.dart';
import 'package:talay_mobile/model/header.dart';
import 'package:talay_mobile/model/stock-price-analyse.dart';
import 'package:talay_mobile/shared/shared.dart';
import 'package:talay_mobile/apis/apis.dart';
import '../../model/file.dart';
import '../../style-model/style-model.dart';

class StockPriceAnalyseScreen extends StatefulWidget {
  const StockPriceAnalyseScreen({Key? key}) : super(key: key);
  @override
  StockPriceAnalyseScreenState createState() => StockPriceAnalyseScreenState();
}

class StockPriceAnalyseScreenState extends State<StockPriceAnalyseScreen> {
  bool remeberMeState = false;
  final _formKey = GlobalKey<FormState>();
  Shared sh = new Shared();
  Apis apis = Apis();
  StockAnalyse? stockDetail;
  List<File>? stockFiles;
  List<CurrencyModel>? currencyList;
  CurrencyModel? _selectedCurrency;
  String? _selectedCurrencyId;
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
    setState(() {
      setState(() {
        FocusScope.of(context).requestFocus(f1);
      });
      var d = null;
      String bodyString = pref.getString('stockInfo')!;
      if (bodyString != null) {
        var bodyJson = jsonDecode(bodyString);
        stockDetail = StockAnalyse.fromJson(bodyJson['Records'][0]);
        currencyList = (bodyJson['Currencies'] as List)
            .map(
              (e) => CurrencyModel.fromJson(e),
            )
            .toList();
        _selectedCurrency = stockDetail!.Currency;
        _selectedCurrencyId = stockDetail!.Currency!.CurrencyId;
      }
    });
  }

  onChangePriceByCurrencyPriceType() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Apis apis = Apis();
    await apis
        .getStockPriceAnalysis(
            stockDetail!.StockCode, _selectedCurrency?.CurrencyId)
        .then(
      (value) {
        setState(
          () {
            setState(() {
              FocusScope.of(context).requestFocus(f1);
            });
            String? cid = _selectedCurrency?.CurrencyId;
            if (cid != null) pref.setString("currencyId", cid);
            stockDetail = StockAnalyse.fromJson(value['Records'][0]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fiyat Analizi"),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Center(
                child: Column(
              children: [
                SizedBox(
                  height: 1,
                  child: TextFormField(
                    controller: txtSearchStock,
                    focusNode: f1,
                    showCursor: false,
                    keyboardType: TextInputType.none,
                    onChanged: (value) {
                      if (value.length > 11) {
                        result = value.toString().substring(11);
                      } else {
                        result = value;
                      }
                      FocusScope.of(context).unfocus();

                      txtSearchStock.text = "";
                      getStockInfo();
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                stockDetail != null
                    ? Column(
                        children: [
                          Center(
                            child: Text(
                              stockDetail!.StockName,
                              style: headerTitleText,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownButton<String>(
                            hint: const Text("Döviz seç"),
                            focusNode: null,
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
                          SizedBox(
                            height: 30,
                          ),
                          Center(
                            child: Text(
                              "Alış Fiyatları",
                              style: labelText,
                            ),
                          ),
                          DataTable(
                            columns: const [
                              DataColumn(
                                label: SizedBox(
                                  child: Text('Fiyat Tipi'),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  child: Text('Ayar'),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  child: Text('Fiyat'),
                                ),
                              ),
                            ],
                            rows: stockDetail!.Prices != null
                                ? stockDetail!.Prices
                                    .where((element) =>
                                        element.PriceTypeGroup == 10)
                                    .map(
                                      (e) => DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text(e.PriceTypeName)),
                                          DataCell(Text(e.Carat.toString())),
                                          DataCell(Text(
                                              sh.numberFormatter(e.Price))),
                                        ],
                                      ),
                                    )
                                    .toList()
                                : [],
                          ),
                          Center(
                            child: Text(
                              "Satış Fiyatları",
                              style: labelText,
                            ),
                          ),
                          DataTable(
                            columns: const [
                              DataColumn(
                                label: SizedBox(
                                  child: Text('Fiyat Tipi'),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  child: Text('Ayar'),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  child: Text('Fiyat'),
                                ),
                              ),
                            ],
                            rows: stockDetail!.Prices != null
                                ? stockDetail!.Prices
                                    .where((element) =>
                                        element.PriceTypeGroup == 20)
                                    .map(
                                      (e) => DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text(e.PriceTypeName)),
                                          DataCell(Text(e.Carat.toString())),
                                          DataCell(Text(
                                              sh.numberFormatter(e.Price))),
                                        ],
                                      ),
                                    )
                                    .toList()
                                : [],
                          ),
                        ],
                      )
                    : Text("Veri Bulunamadi"),
              ],
            )),
          ),
        ),
      ),
    );
  }

  getStockInfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (result != null) {
      String code = result ?? "";
      Apis apis = Apis();
      String? cid = pref.getString("currencyId");
      await apis.getStockPriceAnalysis(code, cid).then(
        (value) {
          setState(() {
            setState(() {
              FocusScope.of(context).requestFocus(f1);
            });
            print(value);
            stockDetail = StockAnalyse.fromJson(value['Records'][0]);
          });
        },
      );
    }
  }
}
