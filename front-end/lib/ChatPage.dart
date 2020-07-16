import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  IO.Socket socket;
  List<String> messages;
  double height, width;
  TextEditingController textController;
  ScrollController scrollController;

  String url = 'http://localhost';
  int port = 3000;
  @override
  void initState() {
    //Initializing the message list
    messages = List<String>();
    //Initializing the TextEditingController and ScrollController
    textController = TextEditingController();
    scrollController = ScrollController();
    //Creating the socket
    print("tentando conectar...");
    socket =
        IO.io('https://aqueous-bayou-63340.herokuapp.com/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    print("conectou sem erros...ou com..n sabemos");
    //Call init before doing anything with socket
    socket.on('send_message', (jsonData) {
      //Convert the JSON data received into a Map
      Map<String, dynamic> data = json.decode(jsonData);
      this.setState(() => messages.add(data['message']));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 600),
        curve: Curves.ease,
      );
    });
    socket.on('connection', (jsonData) {
      print("chamou evento: connection");
      //Convert the JSON data received into a Map
      this.setState(() => messages.add(jsonData.toString()));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 600),
        curve: Curves.ease,
      );
    });
    //Subscribe to an event to listen to
    socket.connect();
    super.initState();
  }

  Widget buildSingleMessage(int index) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.only(bottom: 20.0, left: 20.0),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          messages[index],
          style: TextStyle(color: Colors.white, fontSize: 15.0),
        ),
      ),
    );
  }

  Widget buildMessageList() {
    return Container(
      height: height * 0.8,
      width: width,
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      width: width * 0.7,
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(left: 40.0),
      child: TextField(
        decoration: InputDecoration.collapsed(
          hintText: 'Send a message...',
        ),
        controller: textController,
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      onPressed: () async {
        //Check if the textfield has text or not
        if (textController.text.isNotEmpty) {
          //Send the message as JSON data to send_message event
//          String urlSendMessage = '$url:$port/chat/sendMsg';
//          String jobId = 'f987dc29-7d55-4d94-9b7f-883fdd4c0263';
//          String customerId = '5c0822a2-2fc1-49fb-af85-78e71beaad6f';
//          String serviceProviderId = 'c237a43d-6b4a-42d6-8e0d-f19b52aaeb2b';
//          var response = await http.post(urlSendMessage, body: {
//            'text': textController.text,
//            'jobId': jobId,
//            'from': customerId,
//            'to': serviceProviderId
//          });
//          print("response: ${response.body}");
          socket.emit(
              'receive_message', json.encode({'message': textController.text}));
          //Add the message to the list
          this.setState(() => messages.add(textController.text));
          textController.text = '';
          //Scrolldown the list to show the latest message
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        }
      },
      child: Icon(
        Icons.send,
        size: 30,
      ),
    );
  }

  Widget buildInputArea() {
    return Container(
      height: height * 0.1,
      width: width,
      child: Row(
        children: <Widget>[
          buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: height * 0.1),
            buildMessageList(),
            buildInputArea(),
          ],
        ),
      ),
    );
  }
}
