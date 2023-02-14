import 'package:flutter/material.dart';
import 'package:talay_mobile/screens/currency-list/currency-list.dart';
import 'package:talay_mobile/screens/menu.dart';

headerAction(context) {
  return <Widget>[
    Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/currency-list');
          },
          child: Icon(
            Icons.currency_exchange,
            size: 26.0,
          ),
        )),
  ];
}

leading(context) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).pushReplacementNamed('/menu');
    },
    child: Icon(
      Icons.menu, // add custom icons also
    ),
  );
}

leadingWithBack(context) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context, rootNavigator: true).pop('dialog');
    },
    child: Icon(
      Icons.arrow_back, // add custom icons also
    ),
  );
}
