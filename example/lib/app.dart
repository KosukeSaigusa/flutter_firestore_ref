import 'package:example/model/service/authenticator.dart';
import 'package:example/router.dart';
import 'package:example/util/util.dart';
import 'package:flutter/material.dart' hide Router;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return context.select((Authenticator a) => a.user == null)
        ? const Center(child: CircularProgressIndicator())
        : MaterialApp(
            title: context.select((AppInfo info) => info.title),
            onGenerateRoute: context.watch<Router>().onGenerateRoute,
            theme: ThemeData.from(
              colorScheme: const ColorScheme.light(),
            ).copyWith(
              dividerColor: Colors.black54,
            ),
            darkTheme: ThemeData.from(
              colorScheme: const ColorScheme.dark(),
            ),
          );
  }
}

class AppInfo {
  String get title => 'firestore_ref example';
}
