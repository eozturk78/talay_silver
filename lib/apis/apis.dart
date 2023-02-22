import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/model/city.dart';

import '../model/detailed-dare.dart';
import '../shared/shared.dart';
import '../toast.dart';

class Apis {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Shared sh = new Shared();
  String lang = 'tr-TR';
  String baseUrl = 'https://talay-api.flepron.com', serviceName = 'Mobile.svc';
  Future login(String email, String password) async {
    String finalUrl = '$baseUrl/$serviceName/Login';
    var params = {'UserId': email.toString(), 'Password': password.toString()};
    var result = await http.post(Uri.parse(finalUrl),
        body: jsonEncode(params),
        headers: {'Content-Type': 'application/text', 'lang': lang});
    return getResponseFromApi(result);
  }

  Future getStockInfo(
      String? barcode, String? currencyId, String? priceTypeId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/GetStockPriceInfo?c0=$barcode';
    if (priceTypeId != null) finalUrl += '&c1=$priceTypeId';
    if (currencyId != null) finalUrl += '&c2=$currencyId';
    var result = await http.get(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future getBasketDetails(String? basketId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/GetBasketDetails/$basketId';
    var result = await http.get(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future getStockPriceAnalysis(String barcode, String? currencyId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/GetStockPriceAnalysis?c0=$barcode';
    if (currencyId != null) finalUrl += '&c1=$currencyId';
    var result = await http.get(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future getCurrencyList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/GetExchangeRates';
    var result = await http.get(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future renewToken(token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/RenewToken';
    var params = {"Token": token};
    var result = await http
        .post(Uri.parse(finalUrl), body: jsonEncode(params), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
    });
    return getResponseFromApi(result);
  }

  Future getSearchStockLookUpData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/GetSearchStockLookUpData';
    var result = await http.get(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future searchStock(String? accountId, List<String>? tags) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/SearchStock';
    var params = {"AccountId": accountId, "SelectedTags": tags};
    var result = await http
        .post(Uri.parse(finalUrl), body: jsonEncode(params), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future getAccountList(String searchText) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/GetCustomerList?c0=${searchText}';
    var result = await http.get(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future searchCustomer(
      String? searchText, String? countryId, String? cityId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/SearchCustomer';
    var params = {
      "SearchText": searchText,
      "CountryId": countryId,
      "CityId": cityId
    };
    var result = await http
        .post(Uri.parse(finalUrl), body: jsonEncode(params), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future getCreateCustomerLookUpData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/GetCreateCustomerLookUpData';
    var result = await http.get(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future getSearchCustomerLookUpData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/GetSearchCustomerLookUpData';
    var result = await http.get(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future createCustomer(
      String title,
      String email,
      String? phoneNumberCountryId,
      String? phoneNumber,
      String? countryId,
      String? cityId,
      String? currencyId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var params = {
      "Title": title,
      "Email": email,
      "PhoneCountryId": phoneNumberCountryId,
      "PhoneNumber": phoneNumber,
      "CountryId": countryId,
      "CityId": cityId,
      "CurrencyId": currencyId
    };
    String finalUrl = '$baseUrl/$serviceName/CreateCustomer';
    var result = await http
        .post(Uri.parse(finalUrl), body: jsonEncode(params), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future createBasket(String? accountId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/CreateBasket/$accountId';
    var result = await http.post(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future addToBasket(String? basketId, String? stockId, String? stockVariantId,
      int? offerCarat, double? offerUnitPrice) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl =
        '$baseUrl/$serviceName/AddToBasket?c0=$basketId&c1=$stockId';
    if (stockVariantId != null) finalUrl += '&c2=$stockVariantId';
    var params = {
      "BasketId": basketId,
      "Stock": stockId,
      "StockVariantId": stockVariantId,
      "OfferCarat": offerCarat,
      "OfferUnitPrice": offerUnitPrice
    };
    var result = await http
        .post(Uri.parse(finalUrl), body: jsonEncode(params), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future getCreateBasketLookUpData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/GetCreateBasketLookUpData';
    var result = await http.get(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future getStockBasketPrice(String? basketId, String? barcode) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl =
        '$baseUrl/$serviceName/GetStockBasketPrice?c0=$basketId&c1=$barcode';
    var result = await http.get(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future getCustomerBasketList(String? accountId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/$serviceName/GetCustomerBasketList/$accountId';
    var result = await http.get(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future deleteBasketDetail(String? basketDetailId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl =
        '$baseUrl/$serviceName/DeleteBasketDetail/$basketDetailId';
    var result = await http.delete(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future setBasketDetailOfferValues(
      String? basketDetailId, String caratOffer, String priceOffer) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var params = {
      "BasketDetailId": basketDetailId,
      "OfferCarat": caratOffer != "" ? caratOffer : null,
      "OfferUnitPrice":
          priceOffer != "" ? sh.prePareNumberForRequest(priceOffer) : null
    };
    String finalUrl = '$baseUrl/$serviceName/SetBasketDetailOfferValues';
    var result = await http
        .post(Uri.parse(finalUrl), body: jsonEncode(params), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future updateBasketCurrency(String? basketId, String? currencyId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var params = {"BasketId": basketId, "CurrencyId": currencyId};
    String finalUrl = '$baseUrl/$serviceName/UpdateBasketCurrency ';
    var result = await http
        .post(Uri.parse(finalUrl), body: jsonEncode(params), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future sendBasketToWaiting(
      String? basketId, bool? activeWaiting, double? grossWeight) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var params = {
      "BasketId": basketId,
      "ActiveWaiting": activeWaiting,
      "GrossWeight": grossWeight
    };
    String finalUrl = '$baseUrl/$serviceName/SendBasketToWaiting';
    var result = await http
        .post(Uri.parse(finalUrl), body: jsonEncode(params), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  Future updateBasketDetail(
      String? basketDetailId,
      double grossWeight,
      double tareWeight,
      double quantity,
      List<DetailedDare> detailedDare,
      int tareType) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var params = {};
    if (tareType == 10) {
      params = {
        "BasketDetailId": basketDetailId,
        "GrossWeight": grossWeight,
        "TareWeight": tareWeight,
        "Quantity": quantity
      };
    } else {
      params = {
        "BasketDetailId": basketDetailId,
        "GrossWeight": grossWeight,
        "Quantity": quantity,
      };
      params['DetailedTare'] = detailedDare.map((e) {
        return {
          "Weight": e.Weight,
          "Quantity": e.Quantity,
        };
      }).toList();
    }

    print(params);

    String finalUrl = '$baseUrl/$serviceName/UpdateBasketDetail';
    var result = await http
        .post(Uri.parse(finalUrl), body: jsonEncode(params), headers: {
      'Content-Type': 'application/text',
      'lang': lang,
      'token': pref.getString('token').toString()
    });
    return getResponseFromApi(result);
  }

  getResponseFromApi(Response result) {
    var body = jsonDecode(result.body);
    if (result.statusCode == 200) {
      try {
        return body['Data'] != null ? jsonDecode(body['Data']) : null;
      } on Exception catch (err) {
        showToast("something went wrong");
        throw Exception("Something went wrong");
      }
    } else {
      showToast(body['Status']['StatusText']);
      throw Exception(body['Status']['StatusText']);
    }
  }
}
