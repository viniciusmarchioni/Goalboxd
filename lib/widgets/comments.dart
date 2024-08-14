import 'package:flutter/material.dart';
import 'package:goalboxd/obj/comment.dart';
import 'package:goalboxd/obj/games.dart';
import 'package:goalboxd/obj/user.dart';
import 'package:goalboxd/otheruserprofile.dart';

class CommentWidget extends StatefulWidget {
  final Games game;
  const CommentWidget({super.key, required this.game});

  @override
  State<StatefulWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  late Games game;
  final controller = TextEditingController();
  List<Comments> comments = [];
  int commentPage = 0;
  bool endOfComments = false;

  Future<void> _refreshComments() async {
    List<Comments> newComments =
        await Comments.getComments(game.id!, commentPage);
    setState(() {
      comments.addAll(newComments);
      endOfComments = newComments.length < 10;
      commentPage += 10;
    });
  }

  @override
  void initState() {
    game = widget.game;
    _refreshComments();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.8,
      minChildSize: MediaQuery.sizeOf(context).width >= 800 ? 0.38 : 0.3,
      initialChildSize: MediaQuery.sizeOf(context).width >= 800 ? 0.38 : 0.3,
      builder: (context, scrollController) {
        scrollController.addListener(() {
          if (scrollController.position.pixels ==
                  scrollController.position.maxScrollExtent &&
              !endOfComments) {
            _refreshComments();
          }
        });

        return Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Colors.blue),
          child: Column(
            children: [
              const Text("Comentários",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return _ComentarioPlaceholder(comment: comments[index]);
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: controller,
                    maxLines: 2,
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(),
                        border: OutlineInputBorder(),
                        hintText: "Comentario"),
                  )),
                  ElevatedButton(
                    onPressed: () async {
                      if (controller.text.isNotEmpty) {
                        await Comments.postComment(game.id!, controller.text);
                        controller.clear();
                      }
                    },
                    style: const ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(Colors.blue)),
                    child: const Text("Enviar"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class _ComentarioPlaceholder extends StatelessWidget {
  final Comments comment;
  const _ComentarioPlaceholder({
    required this.comment,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RawMaterialButton(
              onPressed: () async {
                User user = User();
                await user.getProfile(comment.userid);
                if (context.mounted) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return OtherUserProfile(
                      user: user,
                    );
                  }));
                }
              },
              child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(comment.urlImage ??
                      'https://pbs.twimg.com/media/GGxpGBKXAAAkdwf?format=jpg&name=small'))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.username,
                  overflow: TextOverflow.fade,
                ),
                Text(
                  comment.comment,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
