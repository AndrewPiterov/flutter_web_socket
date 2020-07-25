import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebSocketChannel _channel;
  TextEditingController _controller;

  final List<String> _list = [];

  @override
  void initState() {
    super.initState();
    _channel = IOWebSocketChannel.connect('ws://echo.websocket.org');
    _channel.stream.listen((data) => setState(() => _list.add(data)));
    _controller = TextEditingController();
  }

  void _sendData() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(_controller.text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Column(
            children: <Widget>[
              Form(
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: 'Send to WebSocket'),
                ),
              ),
              Column(
                children: _list.map((e) => Text(e)).toList(),
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          _sendData();
        },
      ),
    );
  }
}
