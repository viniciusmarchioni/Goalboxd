import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:goalboxd/aboutpage.dart';
import 'package:goalboxd/menu.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:goalboxd/settingspage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await dotenv.load(fileName: ".env");

  if (prefs.getInt('id') != null) {
    runApp(ChangeNotifierProvider(
      create: (context) => GamesRepository(),
      child: MaterialApp(
        home: const Menu(),
        theme: ThemeData(useMaterial3: true),
        title: 'Goalboxd',
        routes: {
          '/about': (context) => const About(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const Menu(),
          '/settings': (context) => const Settings()
        },
      ),
    ));
  } else {
    runApp(ChangeNotifierProvider(
      create: (context) => GamesRepository(),
      child: MaterialApp(
        home: const LoginPage(),
        theme: ThemeData(useMaterial3: true),
        title: 'Goalboxd',
        routes: {
          '/about': (context) => const About(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const Menu(),
          '/settings': (context) => const Settings()
        },
      ),
    ));
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue, Colors.white],
                  begin: Alignment.topCenter,
                  end: AlignmentDirectional.bottomCenter)),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Goalboxd",
                      style: TextStyle(color: Colors.white, fontSize: 35)),
                  Container(
                    padding: const EdgeInsets.all(2),
                    height: 60,
                    child: Image.asset('assets/icon_branco.png'),
                  )
                ],
              ),
              SignInButton(Buttons.google, text: 'Entrar com Google',
                  onPressed: () async {
                try {
                  final userGoogle = await _GoogleSignInApi.login();
                  User user = User.toLogin(userGoogle!.displayName!,
                      userGoogle.email, userGoogle.photoUrl);
                  await user.login();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                } catch (e) {
                  debugPrint('Erro MAIN: $e');
                }
              }),
              Container(),
            ],
          ),
        ),
      ]),
    );
  }
}

class _GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
}
