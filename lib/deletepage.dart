import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeletePage extends StatefulWidget {
  const DeletePage({super.key});

  @override
  State<StatefulWidget> createState() => DeletePageState();
}

class DeletePageState extends State {
  bool check = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adeus :(')),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                activeColor: Colors.blue,
                value: check,
                onChanged: (value) {
                  setState(() {
                    check = value ?? false;
                  });
                },
              ),
              const Text('Estou Ciente que não tem como para recuperar')
            ],
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Voltar",
                style: TextStyle(color: Colors.white),
              )),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: !check
                  ? null
                  : () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      try {
                        int userid = prefs.getInt('id')!;
                        final response = await http.delete(Uri.parse(
                            '${dotenv.env['API_URL']}/users/$userid'));
                        prefs.clear();
                        if (response.statusCode == 200) {
                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                "/login", (route) => false);
                          }
                        } else {
                          debugPrint("Erro ${response.statusCode}");
                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                "/login", (route) => false);
                          }
                        }
                      } catch (e) {
                        prefs.clear();
                        if (mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              "/login", (route) => false);
                        }
                      }

                      //deletar conta
                    },
              child: const Text(
                "Apagar",
                style: TextStyle(color: Colors.white),
              ))
        ]),
      ),
    );
  }
}
