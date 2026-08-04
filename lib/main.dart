import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/firebase_options.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:layerbase/utils/shared_prefs_service.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "secret.env");
  if (defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  await SharedPrefsService().init();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await Hive.openBox<dynamic>(
    AppKeys.imageLayerBox,
    compactionStrategy: (entries, deletedEntries) => false,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      initialRoute: Routes.splash,
      getPages: routes(),
      theme: ThemeData(
        useMaterial3: true,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        fontFamily: appFontFamily,
        scaffoldBackgroundColor: AppColors.blackColor,
      ),
    );
  }
}
