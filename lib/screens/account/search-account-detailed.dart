import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/screens/account/new-account.dart';

import '../../apis/apis.dart';
import '../../colors/constant_colors.dart';
import '../../model/city.dart';
import '../../model/country.dart';
import '../../model/header.dart';
import 'account-list.dart';

class SearchAccountDetailedScreen extends StatefulWidget {
  const SearchAccountDetailedScreen(Key? key) : super(key: key);
  SearchAccountDetailedState createState() => SearchAccountDetailedState();
}

class SearchAccountDetailedState extends State<SearchAccountDetailedScreen> {
  TextEditingController SearchAccountDetailed = new TextEditingController();
  TextEditingController searchAccount = new TextEditingController();
  List<Country>? countries;
  List<City>? cities;
  Country? _selectedCountry;
  Country? _selectedCountryCode;
  City? _selectedCity;

  @override
  void initState() {
    // TODO: implement initState

    getCustomerLookUpData();
    super.initState();
  }

  getCustomerLookUpData() {
    Apis apis = new Apis();
    apis.getSearchCustomerLookUpData().then((value) {
      setState(() {
        countries = (value['Countries'] as List)
            .map((e) => Country.fromJson(e))
            .toList();
        print(countries);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Detaylı Cari Arama"),
        leading: leadingWithBack(context),
        shadowColor: null,
        elevation: 0.0,
        bottomOpacity: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
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
              padding: EdgeInsets.all(30.0),
              child: Center(
                child: Column(
                  children: [
                    TextFormField(
                      controller: searchAccount,
                      obscureText: false,
                      decoration: const InputDecoration(
                        labelText:
                            'Aramak için, cari ünvanına göre birşeyler yaz',
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    DropdownButton<Country>(
                      isExpanded: true,
                      hint: const Text("Ülke"),
                      items: countries?.map((e) {
                        return DropdownMenuItem<Country>(
                          value: e,
                          child: Text(e.CountryName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                        });
                      },
                      value: _selectedCountry,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    DropdownButton<City>(
                      isExpanded: true,
                      hint: const Text("Şehir"),
                      items: _selectedCountry?.Cities?.map((e) {
                        return DropdownMenuItem<City>(
                          value: e,
                          child: Text(e.CityName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                      value: _selectedCity,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        pref.setString("searchText", searchAccount.text);
                        if (_selectedCountry != null) {
                          pref.setString(
                              "countryId", _selectedCountry!.CountryId);
                        }
                        if (_selectedCity != null) {
                          pref.setString("cityId", _selectedCity!.CityId);
                        }

                        // ignore: use_build_context_synchronously
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    const AccountListScreen(null))));
                      },
                      child: Text("Ara"),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40)),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    const NewAccountScreen(null))));
                      },
                      child: Text("Yeni Müşteri Adayı"),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                          backgroundColor: Colors.red),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
