import 'package:example/model/service/authenticator.dart';
import 'package:example/router.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:hooks_riverpod/hooks_riverpod.dart';

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(isSignedInProvider).data?.value ?? false;
    return !isSignedIn
        ? const Center(child: CircularProgressIndicator())
        : MaterialApp(
            title: ref.watch(appInfo).title,
            onGenerateRoute: ref.watch(router).onGenerateRoute,
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

final appInfo = Provider((_) => AppInfo());

class AppInfo {
  String get title => 'firestore_ref example';
}
