import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Ignores do zachowania kompatybilności wersji
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BuyCoffeeApp());
}

class BuyCoffeeApp extends StatelessWidget {
  const BuyCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BuyCoffee',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
      ),
      home: const BuyCoffeeScreen(),
    );
  }
}

class BuyCoffeeScreen extends StatefulWidget {
  const BuyCoffeeScreen({super.key});

  @override
  State<BuyCoffeeScreen> createState() => _BuyCoffeeScreenState();
}

class _BuyCoffeeScreenState extends State<BuyCoffeeScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final WebViewController controller = WebViewController();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse('https://buycoffee.to'));

    // Włączenie natywnego zapisywania ciasteczek i LocalStorage na Androidzie
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (controller.platform as AndroidWebViewController)
          .setDomStorageEnabled(true);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}