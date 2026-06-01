import 'package:adescrow_app/routes/routes.dart';
import 'package:adescrow_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'backend/backend_utils/network_check/dependency_injection.dart';
import 'language/language_controller.dart';

void main() async {
  // Locking Device Orientation
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  // Initialise GetStorage before any controller reads/writes it.
  // Without this, concurrent onInit() calls race on the same .gs file.
  await GetStorage.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
   ]);

  
  InternetCheckDependencyInjection.init();
  // main app
  runApp(const MyApp());
}

// This widget is the root of your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (_, child) => GetMaterialApp(
        title: 'Flexbills',
        debugShowCheckedModeBanner: false,
        theme: Themes.light,
        darkTheme: Themes.dark,
        themeMode: Themes.theme,

        navigatorKey: Get.key,
        initialRoute: Routes.splashScreen,
        getPages: Routes.list,
        locale: const Locale('en'),
        initialBinding: BindingsBuilder(
              () {
            Get.put(LanguageSettingController(),permanent: true);
          },
        ),
        builder: (context, widget) {
          ScreenUtil.init(context);
          return Obx(() => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Directionality(
              textDirection: Get.find<LanguageSettingController>().isLoading
                  ? TextDirection.ltr
                  // : TextDirection.ltr,
                  : Get.find<LanguageSettingController>().languageDirection,
              child: widget!,
            ),
          ));
        },
      ),
    );
  }
}
