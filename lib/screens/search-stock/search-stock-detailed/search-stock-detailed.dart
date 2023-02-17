import 'dart:convert';

import 'package:dropdown_search2/dropdown_search2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/colors/constant_colors.dart';
import 'package:talay_mobile/model/account.dart';
import 'package:talay_mobile/model/currency.dart';
import 'package:talay_mobile/model/header.dart';
import 'package:talay_mobile/model/price-type.dart';
import 'package:talay_mobile/model/stock-detail.dart';
import 'package:talay_mobile/model/tags-group.dart';
import 'package:talay_mobile/shared/shared.dart';
import 'package:talay_mobile/style-model/style-model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:talay_mobile/apis/apis.dart';

import '../../stock/stock-list.dart';

class SearchStockDetailedScreen extends StatefulWidget {
  const SearchStockDetailedScreen({Key? key}) : super(key: key);
  @override
  StockDetailScreenState createState() => StockDetailScreenState();
}

class StockDetailScreenState extends State<SearchStockDetailedScreen> {
  TextEditingController producerController = new TextEditingController();
  TextEditingController searchTextController = new TextEditingController();

  bool remeberMeState = false;
  final _formKey = GlobalKey<FormState>();
  Shared sh = new Shared();
  Apis apis = Apis();
  List<Account>? accountList;
  List<TagGroup>? tagGroupList;
  TagGroup? _selectedTagGroup;
  List<String>? selectedTags = [];
  Account? _account;
  bool loaderButton = false;
  bool loaderTags = true;
  @override
  void initState() {
    // TODO: implement initState
    getSearchStockLoockUpData();
    super.initState();
  }

  getSearchStockLoockUpData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      Apis apis = new Apis();
      apis.getSearchStockLookUpData().then((value) {
        setState(() {
          loaderTags = false;
          tagGroupList =
              (value['Tags'] as List).map((e) => TagGroup.fromJson(e)).toList();
          accountList = (value['Accounts'] as List)
              .map((e) => Account.fromJson(e))
              .toList();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stok Detaylı Ara"),
        shadowColor: null,
        leading: leadingWithBack(context),
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
              height: MediaQuery.of(context).size.height * 0.78,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    DropdownSearch<String>(
                      showSearchBox: true,
                      items: accountList?.map((e) => e.Title).toList(),
                      onChanged: (value) {
                        setState(() {
                          _account = accountList
                              ?.where((element) => element.Title == value)
                              .first;
                        });
                      },
                      label: "Atölye",
                      selectedItem: _account?.CityName,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        Text(
                          "Etiketler :",
                          style: labelText,
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Text("")
                      ],
                    ),
                    if (loaderTags)
                      SpinKitCircle(
                        color: Colors.black,
                        size: 30.0,
                      ),
                    if (!loaderTags)
                      tagGroupList != null
                          ? ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(8),
                              itemCount: tagGroupList?.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  height: 50,
                                  child: Row(
                                    children: [
                                      Text(tagGroupList![index].TagGroupName),
                                      const Spacer(
                                        flex: 1,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _selectedTagGroup =
                                              tagGroupList![index];
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                showTags(context),
                                          ).then(
                                            (value) => setState(
                                              () {},
                                            ),
                                          );
                                        },
                                        child: tagGroupList![index]
                                                    .Tags!
                                                    .where((element) =>
                                                        element.selectedTag ==
                                                        true)
                                                    .length !=
                                                0
                                            ? Text(
                                                "(" +
                                                    tagGroupList![index]
                                                        .Tags!
                                                        .where((element) =>
                                                            element
                                                                .selectedTag ==
                                                            true)
                                                        .length
                                                        .toString() +
                                                    ")",
                                              )
                                            : Text("Seç"),
                                      )
                                    ],
                                  ),
                                );
                              })
                          : const Text("Etiket yok"),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.13,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 68, 68, 68)),
                  onPressed: () async {
                    setState(() {
                      loaderButton = true;
                    });
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    apis
                        .searchStock(_account?.AccountId, selectedTags)
                        .then((value) async {
                      setState(() {
                        loaderButton = false;
                      });
                      pref.setString("stockList", jsonEncode(value));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => StockListScreen())));
                    });
                  },
                  child: loaderButton == false
                      ? const Text("Ara")
                      : SpinKitCircle(
                          color: Colors.white,
                          size: 30.0,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showTags(BuildContext context) {
    var tagGroupName = _selectedTagGroup?.TagGroupName;
    return AlertDialog(
      title: Text(tagGroupName!),
      content: StatefulBuilder(builder: (BuildContext context, setState) {
        return Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 1,
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 600.0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: _selectedTagGroup?.Tags?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 50,
                              child: GestureDetector(
                                child: Row(
                                  children: [
                                    if (_selectedTagGroup!
                                        .Tags![index].selectedTag)
                                      const Icon(
                                        Icons.check,
                                        size: 20.0,
                                        color: Color.fromARGB(255, 0, 134, 69),
                                      ),
                                    Text(
                                      _selectedTagGroup!.Tags![index].TagName,
                                      style: _selectedTagGroup!
                                                  .Tags![index].selectedTag ==
                                              true
                                          ? const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 0, 134, 69),
                                              fontWeight: FontWeight.bold)
                                          : const TextStyle(
                                              color: Colors.black),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _selectedTagGroup!.Tags![index].selectedTag =
                                      !_selectedTagGroup!
                                          .Tags![index].selectedTag;
                                  if (!_selectedTagGroup!
                                      .Tags![index].selectedTag) {
                                    var i = 0;
                                    selectedTags?.forEach((element) {
                                      if (_selectedTagGroup!
                                              .Tags![index].TagId ==
                                          element) {
                                        setState(() {
                                          selectedTags?.removeAt(i);
                                        });
                                      }
                                      i++;
                                    });
                                  } else {
                                    setState(() {
                                      selectedTags?.add(_selectedTagGroup!
                                          .Tags![index].TagId);
                                    });
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40)),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
                child: const Text("Tamam"),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget showAccount(BuildContext context) {
    return AlertDialog(
        title: Text("Atölye"),
        content: StatefulBuilder(builder: (BuildContext context, setState) {
          return FittedBox(
              fit: BoxFit.none,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 400.0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: accountList?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 50,
                            child: GestureDetector(
                              child: Row(
                                children: [
                                  Text(
                                    accountList![index].Title,
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _account = accountList![index];
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog');
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ));
        }));
  }
}
