import 'package:flutter/material.dart';

class FinuraChatPage extends StatefulWidget {
  const FinuraChatPage({Key? key}) : super(key: key);

  @override
  State<FinuraChatPage> createState() => _FinuraChatPageState();
}

class _FinuraChatPageState extends State<FinuraChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hi, I am Finura. I am here to give you financial advice...",
      isUser: false,
    ),
  ];

  get navigator => null;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _controller.clear();
      // In the future, here you can call your GPT-4/3.5 API and add the response as a new _ChatMessage with isUser: false
      // Example:
      // final response = await getGptResponse(text);
      // setState(() {
      //   _messages.add(_ChatMessage(text: response, isUser: false));
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 164, 245, 171),
        iconTheme: IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);

            },
            child: ClipOval(
              child: Image.asset(
                'assets/finura_icon.webp',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        title: const Text('Finura'),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.text),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          Container(
            color: const Color.fromARGB(
              255,
              164,
              245,
              171,
            ), // ✅ Background color here

            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                      isDense: true,
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

/*
  To connect this chat with GPT-4/3.5 in the future:
  1. When the user sends a message, call your backend or OpenAI API with the user's message.
  2. Await the response and add it to the _messages list as a new _ChatMessage with isUser: false.
  3. You can use packages like 'http' or 'dio' to make API requests.
  4. Make sure to handle loading states and errors as needed.
*/
