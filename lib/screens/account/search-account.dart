import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../colors/constant_colors.dart';
import '../../model/header.dart';
import 'account-list.dart';
import 'new-account.dart';

class SearchAccountScreen extends StatefulWidget {
  const SearchAccountScreen(Key? key) : super(key: key);
  SearchAccountState createState() => SearchAccountState();
}

class SearchAccountState extends State<SearchAccountScreen> {
  TextEditingController searchAccount = new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Cari Arama"),
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
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      pref.setString("searchText", searchAccount.text);

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
    );
  }
}
