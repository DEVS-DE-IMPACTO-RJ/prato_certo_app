import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:prato_certo/core/di/di.dart';
import 'package:prato_certo/core/router/app_router.dart'; // Importe seu router

void main() {
  // 1. Remove o '#' da URL na Web
  usePathUrlStrategy();

  setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Prato Certo',
      debugShowCheckedModeBanner: false,

      // --- ADICIONE ESTE BLOCO AQUI ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Português do Brasil
      ],

      // ---------------------------------
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF97316),
          primary: const Color(0xFFF97316),
        ),
        useMaterial3: true,
      ),
      routerConfig: goRouter,
    );
  }
}
