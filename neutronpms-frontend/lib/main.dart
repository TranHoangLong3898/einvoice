// ignore_for_file: prefer_const_constructors
// import 'package:cloud_functions/cloud_functions.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'ui/page/landingpage.dart';
import 'ui/page/loadingpage.dart';
import 'ui/page/mainpage.dart';
import 'ui/page/pagenotfound.dart';
import 'ui/page/selecthotelpage.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

  //get language with user configuration
  final GeneralManager generalManager = GeneralManager();
  await generalManager.loadLocalStorage();

  //show app fullscreen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  //preload OnePMSLogo for pdf
  GeneralManager.onepmsLogo =
      (await rootBundle.load(GeneralManager.partnerHotel.logobackground!))
          .buffer
          .asUint8List();

  runApp(
    ChangeNotifierProvider(
      create: (context) => generalManager,
      child: Consumer<GeneralManager>(
        builder: (context, generalManager, _) {
          return GestureDetector(
            onTap: () => GeneralManager().unfocus(context),
            child: MaterialApp(
                routes: {
                  'landing': (context) => LandingPage(),
                  'selecthotel': (context) => SelectHotelPage(),
                  'loading': (context) => LoadingPage(),
                  'main': (context) => MainPage()
                },
                onUnknownRoute: (settings) {
                  return MaterialPageRoute(builder: (_) => PageNotFound());
                },
                onGenerateInitialRoutes: (String value) {
                  return [MaterialPageRoute(builder: (_) => LandingPage())];
                },
                debugShowCheckedModeBanner: false,
                title: GeneralManager.partnerHotel.name!,
                theme: initializeTheme,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en', ''), Locale('vi', '')],
                locale: GeneralManager.locale),
          );
        },
      ),
    ),
  );
}

ThemeData get initializeTheme {
  const MaterialColor kPrimaryColor = MaterialColor(
    0xff303136,
    <int, Color>{
      50: Color(0xff303136),
      100: Color(0xff303136),
      200: Color(0xff303136),
      300: Color(0xff303136),
      400: Color(0xff303136),
      500: Color(0xff303136),
      600: Color(0xff303136),
      700: Color(0xff303136),
      800: Color(0xff303136),
      900: Color(0xff303136),
    },
  );
  return ThemeData(
    primarySwatch: kPrimaryColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      labelLarge: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white),
      displayLarge: TextStyle(color: Colors.white),
      displayMedium: TextStyle(color: Colors.white),
      displaySmall: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      headlineSmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      labelSmall: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: ColorManagement.mainBackground),
      titleSmall: TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    primaryIconTheme: const IconThemeData(color: Colors.white),
    hintColor: const Color(0xffeddcd2),
    inputDecorationTheme: const InputDecorationTheme(),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Color(0xff9799a1),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
