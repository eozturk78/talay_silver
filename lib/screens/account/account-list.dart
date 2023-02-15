import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/apis/apis.dart';
import 'package:talay_mobile/model/account.dart';
import 'package:talay_mobile/screens/account-basket/account-basket.dart';
import 'package:talay_mobile/screens/account/search-account-detailed.dart';
import 'package:talay_mobile/style-model/style-model.dart';
import '../../colors/constant_colors.dart';
import '../../model/header.dart';
import 'new-account.dart';

class AccountListScreen extends StatefulWidget {
  const AccountListScreen(Key? key) : super(key: key);
  AccountListState createState() => AccountListState();
}

class AccountListState extends State<AccountListScreen> {
  TextEditingController searchAccount = new TextEditingController();
  List<Account>? accountList = [];
  bool? loader = true;
  @override
  void initState() {
    // TODO: implement initState
    getAccountList();
    super.initState();
  }

  getAccountList() async {
    Apis apis = new Apis();
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString("countryId") == null) {
      String searchText = pref.getString("searchText") ?? "";
      apis.getAccountList(searchText).then((value) {
        setState(() {
          if (value != null)
            accountList =
                (value as List).map((e) => Account.fromJson(e)).toList();
          loader = false;
        });
      });
    } else {
      String searchText = pref.getString("searchText") ?? "";
      var countryId = pref.getString("countryId");
      var cityId = pref.getString("cityId");
      apis.searchCustomer(searchText, countryId, cityId).then((value) {
        setState(() {
          print(value);
          if (value != null)
            accountList =
                (value as List).map((e) => Account.fromJson(e)).toList();
          loader = false;
        });
      });
      await pref.remove("countryId");
      await pref.remove("cityId");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text("Cari Listesi"),
          leading: leadingWithBack(context),
          shadowColor: null,
          elevation: 0.0,
          bottomOpacity: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: headerAction(context),
        ),
        backgroundColor: splashBackGroundColor,
        body: Column(
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
                      padding: EdgeInsets.all(10.0),
                      child: accountList != null && accountList!.length != 0
                          ? ListView.builder(
                              itemCount: accountList?.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () async {
                                    SharedPreferences pref =
                                        await SharedPreferences.getInstance();

                                    pref.setString("accountTitle",
                                        accountList![index].Title);
                                    pref.setString(
                                        "accountId",
                                        accountList![index]
                                            .AccountId
                                            .toString());

                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AccountBasketScreen(
                                                    null)));
                                  },
                                  child: Container(
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
                                              accountList![index].Title,
                                              style: labelText,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(accountList![index].Email ??
                                                  ""),
                                              Spacer(
                                                flex: 1,
                                              ),
                                              Text(accountList![index]
                                                      .PhoneNumber ??
                                                  "")
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(accountList![index]
                                                      .CountryName ??
                                                  ""),
                                              Spacer(
                                                flex: 1,
                                              ),
                                              Text(accountList![index]
                                                      .CityName ??
                                                  "")
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
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
              height: MediaQuery.of(context).size.height * 0.192,
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    NewAccountScreen(null))));
                      },
                      child: const Text("Yeni Müşteri Adayı"),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                          backgroundColor: Colors.red),
                    ),
                    TextButton(
                        onPressed: () {
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) =>
                                      const SearchAccountDetailedScreen(
                                          null))));
                        },
                        child: Text("Detaylı Arama")),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
