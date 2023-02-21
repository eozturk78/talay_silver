import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talay_mobile/colors/constant_colors.dart';
import 'package:talay_mobile/screens/menu.dart';
import 'package:talay_mobile/screens/search-stock/search-stock-price/search-stock-price.dart';
import 'package:talay_mobile/shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:talay_mobile/apis/apis.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool remeberMeState = false;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Shared sh = new Shared();
  Apis apis = Apis();
  @override
  void initState() {
    // TODO: implement initState
    checkRemeberMe();
    super.initState();
  }

  checkRemeberMe() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString("rememberMe") == true.toString()) {
      remeberMeState = true;
      emailController.text = pref.getString("email")!;
      passwordController.text = pref.getString("password")!;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("Oturum Aç"),
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
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        controller: emailController,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: 'E-Posta',
                        ),
                        validator: (text) => sh.emailValidator(text),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Şifre',
                        ),
                        validator: (text) => sh.textValidator(text),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          const Text("Beni hatırla"),
                          Checkbox(
                              value: remeberMeState,
                              onChanged: ((value) => setState(() {
                                    remeberMeState = !remeberMeState;
                                  }))),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () async {
                          const url = 'https://talayerp.com';
                          await launch(url);
                        },
                        child: const Text('Şifremi unuttum'),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40)),
                          onPressed: () async {
                            final isValid = _formKey.currentState?.validate();
                            if (!isValid!) return;
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            if (remeberMeState) {
                              pref.setString("rememberMe", true.toString());
                              pref.setString("email", emailController.text);
                              pref.setString(
                                  "password", passwordController.text);
                            } else {
                              pref.clear();
                            }
                          await apis
                                .login(emailController.text,
                                    passwordController.text)
                                .then((value) {
                              if (value != null) {
                                pref.setString('token', value['Token']);
                                if (value['MobilePriceAnalysisAuth'] != null)
                                  pref.setString(
                                      'mobilePriceAnalysisAuth',
                                      value['MobilePriceAnalysisAuth']
                                          .toString());
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MenuScreen()));
                              }
                            });
                          },
                          child: Text('Giriş'))
                    ],
                  ),
                )),
          ),
        ));
  }
}
