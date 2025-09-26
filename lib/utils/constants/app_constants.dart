import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

var deviceWidth = MediaQuery.of(Get.context!).size.width;
var deviceHeight = MediaQuery.of(Get.context!).size.height;

final passwordRegExp = RegExp(
  r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>]).{8,}$',
);
final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

const double fontSize13 = 13;
const double fontSize14 = 14;
const double fontSize16 = 16;
const double fontSize18 = 18;
const double fontSize20 = 20;
const double fontSize22 = 22;
const double fontSize24 = 24;
const double fontSize30 = 30;

/*Size*/

const double spacerSize0 = 0;
const double spacerSize3 = 2;
const double spacerSize2 = 3;
const double spacerSize4 = 4;
const double spacerSize5 = 5;
const double spacerSize8 = 8;
const double spacerSize10 = 10;
const double spacerSize12 = 12;
const double spacerSize15 = 15;
const double spacerSize16 = 16;
const double spacerSize18 = 18;
const double spacerSize20 = 20;
const double spacerSize24 = 24;
const double spacerSize25 = 25;
const double spacerSize30 = 30;
const double spacerSize35 = 35;
const double spacerSize40 = 40;
const double spacerSize45 = 45;
const double spacerSize48 = 48;
const double spacerSize50 = 50;
const double spacerSize53 = 53;
const double spacerSize55 = 55;
const double spacerSize60 = 60;
const double spacerSize65 = 65;
const double spacerSize70 = 70;
const double spacerSize75 = 75;
const double spacerSize80 = 80;
const double spacerSize85 = 85;
const double spacerSize90 = 90;
const double spacerSize95 = 95;
const double spacerSize100 = 100;
const double spacerSize105 = 105;
const double spacerSize110 = 110;
const double spacerSize115 = 115;
const double spacerSize120 = 120;
const double spacerSize125 = 125;
const double spacerSize130 = 130;
const double spacerSize135 = 135;
const double spacerSize140 = 140;
const double spacerSize145 = 145;
const double spacerSize150 = 150;
const double spacerSize155 = 155;
const double spacerSize160 = 160;
const double spacerSize165 = 165;
const double spacerSize200 = 200;
const double spacerSize250 = 250;
const double spacerSize300 = 300;
const double spacerSize350 = 350;
const double spacerSize400 = 400;
const double spacerSize500 = 500;
const double spacerSize600 = 600;

var extensions = [
  'png',
  'jpg',
  'jpeg',
  'gif',
  'cr2',
  'tiff',
  'psd',
  'dng',
  'NEF',
  'nrw',
  'cr3',
  'arw',
  'srf',
  'sr2',
  'orf',
  'raw',
  'rw2',
  'raf',
  'dcr',
  'k25',
  'kdc',
];

const String appFontFamily = "Outfit";

extension ToCapitalized on String {
  String toCapitalized() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
