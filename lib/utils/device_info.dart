import 'package:ecrumedia/utils/navigation_service.dart';
import 'package:flutter/cupertino.dart';

class DeviceInfo {
  static  bool isMobile = MediaQuery.of(getContext()).size.height <= 600;
}
