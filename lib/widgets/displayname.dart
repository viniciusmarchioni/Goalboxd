import 'package:flutter/material.dart';
import 'package:goalboxd/obj/user.dart';

class DisplayName extends StatefulWidget {
  final String username;
  const DisplayName({super.key, required this.username});

  @override
  State<StatefulWidget> createState() => _DisplayNameState();
}

class _DisplayNameState extends State<DisplayName> {
  late String username;
  final TextEditingController _textEditingController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    username = widget.username;
  }

  Future editName(String newName) async {
    User user = User();
    await user.editUsername(sanitizeAndTrim(newName));
    setState(() {
      username = user.username;
    });
  }

  String sanitizeAndTrim(String input) {
    String sanitized = input.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '');
    if (sanitized.length > 45) {
      sanitized = sanitized.substring(0, 45);
    }

    return sanitized;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isEditing)
          Text(username)
        else
          SizedBox(
              width: 100,
              child: TextField(
                onSubmitted: (value) async {
                  if (value.isNotEmpty) {
                    await editName(value);
                    setState(() {
                      isEditing = false;
                    });
                  }
                  setState(() {
                    isEditing = false;
                  });
                },
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  hintText: username,
                ),
                controller: _textEditingController,
              )),
        !isEditing
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isEditing = true;
                  });
                },
                icon: const Icon(Icons.edit))
            : Container()
      ],
    );
  }
}
