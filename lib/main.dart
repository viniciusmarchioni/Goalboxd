import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:goalboxd/menu.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:goalboxd/settingspage.dart';
import 'package:goalboxd/userprofile.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getInt('id') != null) {
    runApp(const MaterialApp(
      home: Menu(),
    ));
  } else {
    runApp(const MaterialApp(home: MyApp()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goalboxd',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/user': (context) => const UserProfile(),
        '/settings': (context) => const Settings()
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<User> login(User user) async {
    User userJson =
        await User.login(User(user.name, user.email, user.image, user.id));
    return userJson;
  }

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
                final userGoogle = await _GoogleSignInApi.login();
                try {
                  User user = await login(User(userGoogle!.displayName!,
                      userGoogle.email, userGoogle.photoUrl, 0));

                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('email', user.email);
                  await prefs.setString('username', user.name);
                  await prefs.setString(
                      'image',
                      user.image ??
                          'https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png');
                  await prefs.setInt('id', user.id!);
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (_) {
                      return const Menu();
                    }));
                  }
                } catch (e) {
                  debugPrint('Erro: $e');
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
