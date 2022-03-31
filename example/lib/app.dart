import 'package:example/model/service/authenticator.dart';
import 'package:example/router.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:hooks_riverpod/hooks_riverpod.dart';

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(signInAnonymouslyProvider);
    final isSignedIn = ref.watch(isSignedInProvider).value ?? false;
    final router = ref.watch(routerProvider);
    return !isSignedIn
        ? const Center(child: CircularProgressIndicator())
        : MaterialApp.router(
            title: ref.watch(appInfo).title,
            theme: ThemeData(
              colorSchemeSeed: Colors.green,
              useMaterial3: true,
            ).copyWith(
              dividerColor: Colors.black54,
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: Colors.green,
              useMaterial3: true,
              brightness: Brightness.dark,
            ),
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
          );
  }
}

final appInfo = Provider((_) => AppInfo());

class AppInfo {
  String get title => 'firestore_ref example';
}
