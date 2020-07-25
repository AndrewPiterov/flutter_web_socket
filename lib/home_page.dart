import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ws/blocs/chat_bloc.dart';
import 'package:web_socket_channel/io.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller;

  final List<String> _list = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: chatBloc.close()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatBloc = BlocProvider.of<ChatBloc>(context);

    chatBloc.add(LoadChat());

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child:
              // Form(
              //   child: TextFormField(
              //     controller: _controller,
              //     decoration: InputDecoration(labelText: 'Send to WebSocket'),
              //   ),
              // ),
              BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatIsNotLoaded) {
                return Text("Start converation");
              } else if (state is ChatIsLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ChatIsLoaded) {
                return StreamBuilder(
                  stream: chatBloc.newMessage,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data.toString());
                    }

                    return CircularProgressIndicator();

                    // return Column(
                    //   children: _list.map((e) => Text(e)).toList(),
                    // );
                  },
                );
              }
              return Text("Some error happened");
            },
          ),
          // StreamBuilder(
          //   stream: _channel.stream,
          //   builder: (context, snapshot) {
          //     return Container(
          //       child:
          //           Text(snapshot.hasData ? snapshot.data.toString() : ''),
          //     );
          //   },
          // ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          chatBloc.add(AddMessage(_controller.text.isEmpty
              ? 'No message on ${DateTime.now().toIso8601String()}'
              : _controller.text));
          _controller.clear();
        },
      ),
    );
  }
}
