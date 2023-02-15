import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/apis/apis.dart';
import 'package:talay_mobile/toast.dart';

import '../../colors/constant_colors.dart';
import '../../model/city.dart';
import '../../model/country.dart';
import '../../model/currency.dart';
import '../../model/header.dart';
import '../../shared/shared.dart';
import '../account-basket/account-basket.dart';

class NewAccountScreen extends StatefulWidget {
  const NewAccountScreen(Key? key) : super(key: key);
  NewAccountState createState() => NewAccountState();
}

class NewAccountState extends State<NewAccountScreen> {
  TextEditingController titleController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneCodeController = new TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();
  TextEditingController countryController = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController currencyController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Shared sh = new Shared();
  List<String> list = ['test 1 ', 'test 2'];
  List<Country>? countries;
  List<CurrencyModel>? currencies;
  List<City>? cities;
  Country? _selectedCountry;
  Country? _selectedCountryCode;
  CurrencyModel? _selectedCurrency;
  City? _selectedCity;
  @override
  void initState() {
    // TODO: implement initState

    getCustomerLookUpData();
    super.initState();
  }

  getCustomerLookUpData() {
    Apis apis = new Apis();
    apis.getCreateCustomerLookUpData().then((value) {
      setState(() {
        countries = (value['Countries'] as List)
            .map((e) => Country.fromJson(e))
            .toList();
        _selectedCountry = countries![0];
        _selectedCountryCode = countries![0];
        currencies = (value['Currencies'] as List)
            .map((e) => CurrencyModel.fromJson(e))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Yeni Müşteri Adayı"),
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
            child: countries != null
                ? Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Cari ünvanı',
                            ),
                            validator: (text) => sh.textValidator(text),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'E-Posta',
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Wrap(
                            children: <Widget>[
                              Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 1,
                                            color: Color.fromARGB(
                                                255, 183, 183, 184)))),
                                child: Row(
                                  children: <Widget>[
                                    PopupMenuButton(
                                      onSelected: (c) {
                                        setState(() {
                                          _selectedCountryCode = c;
                                        });
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            "+ ${_selectedCountryCode!.AreaCode}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Icon(Icons.arrow_drop_down)
                                        ],
                                      ),
                                      itemBuilder: (context) => countries!
                                          .map((c) => PopupMenuItem(
                                              value: c,
                                              child: Text("+ ${c.AreaCode}")))
                                          .toList(),
                                    ),
                                    Flexible(
                                      child: TextFormField(
                                        controller: phoneNumberController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                            height: 15,
                          ),
                          DropdownButtonFormField<CurrencyModel>(
                            isExpanded: true,
                            hint: const Text("Cari Döviz seç"),
                            items: currencies?.map((e) {
                              return DropdownMenuItem<CurrencyModel>(
                                value: e,
                                child: Text(e.Symbol),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCurrency = value;
                              });
                            },
                            value: _selectedCurrency,
                            validator: (text) => sh.textValidator(text?.Symbol),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final isValid = _formKey.currentState?.validate();
                              if (!isValid!) return;

                              Apis apis = new Apis();

                              apis
                                  .createCustomer(
                                      titleController.text,
                                      emailController.text,
                                      _selectedCountryCode?.CountryId,
                                      phoneNumberController.text,
                                      _selectedCountry?.CountryId,
                                      _selectedCity?.CityId,
                                      _selectedCurrency?.CurrencyId)
                                  .then((value) async {
                                showToast(
                                    " Müşteri Adayı Başarıyla Kaydedildi");
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                print(value);
                                pref.setString(
                                    "accountId", value[0]['CustomerId']);
                                pref.setString(
                                    "accountTitle", titleController.text);

                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AccountBasketScreen(null)));
                              });
                            },
                            child: Text("Gönder"),
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                                backgroundColor: Colors.red),
                          ),
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
        ),
      ),
    );
  }
}
